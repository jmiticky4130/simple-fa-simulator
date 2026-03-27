module Pages.Editor exposing (Model, Msg(..), Tool(..), init, initWith, update, view)

import Html exposing (Html, div, input, button, text, label, span)
import Html.Attributes exposing (style, placeholder, value, autofocus, type_, checked)
import Html.Events exposing (onInput, on, onClick, onCheck)
import Json.Decode as Decode
import Components.Toolbar as Toolbar
import Components.Canvas as Canvas
import Components.Console as Console
import Components.AutomatonDisplay as AutomatonDisplay
import Utils.Theme as Theme
import Utils.Translations as Translations exposing (Language)
import UndoList exposing (UndoList)
import Shared exposing (State, Transition, AutomatonState, AutomatonType(..))
import Utils.AutomatonHelpers exposing
    ( getStateById
    , transitionExists
    , updateStatePosition
    , updateStateLabel
    , setStartState
    , toggleEndState
    , updateTransitionSymbol
    , isDFA
    , classifyAutomaton
    )
import Browser.Dom
import Task
import Process
import Set
import File
import File.Download
import File.Select
import Utils.AutomatonCodec


onEnterKey : msg -> Html.Attribute msg
onEnterKey msg =
    on "keydown"
        (Decode.field "key" Decode.string
            |> Decode.andThen
                (\key ->
                    if key == "Enter" then
                        Decode.succeed msg
                    else
                        Decode.fail "not Enter"
                )
        )


type Tool
    = BuildTool
    | DeleteTool


type alias Model =
    { automaton : UndoList AutomatonState
    , language : Language
    , currentTool : Tool
    , selectedState : Maybe Int
    , transitionFrom : Maybe Int
    , consoleMessages : List Console.Message
    , isDragging : Bool
    , draggedState : Maybe Int
    , dragStartX : Float
    , dragStartY : Float
    , editingTransition : Maybe { from : Int, to : Int, x : Float, y : Float }
    , editingTransitionOldSymbol : Maybe String
    , transitionInput : String
    , editingStateId : Maybe Int
    , stateLabelInput : String
    , stateModalIsStart : Bool
    , stateModalIsEnd : Bool
    , stateModalIsCompact : Bool
    , showLoadModal : Bool
    , showSaveModal : Bool
    , saveNameInput : String
    , showStorageSelectModal : Bool
    , storedAutomata : List { name : String, data : String }
    , panX : Float
    , panY : Float
    , zoom : Float
    , isPanning : Bool
    , panLastX : Float
    , panLastY : Float
    , hasPanned : Bool
    , copyDefSuccess : Bool
    , gridMode : Bool
    , bendingTransition : Maybe { from : Int, to : Int }
    , bendDragStartX : Float
    , bendDragStartY : Float
    , isBending : Bool
    , draggingStartArrow : Maybe Int
    , isDraggingStartArrow : Bool
    }


type Msg
    = ChangeTool Tool
    | CanvasClick Float Float
    | CanvasDoubleClick Float Float
    | StateClick Int
    | StateDoubleClick Int
    | StateRightClick Int
    | TransitionClick Int Int String
    | TransitionRightClick Int Int String
    | ArrowMouseDown Int Int Float Float
    | ArrowRightClick Int Int
    | StartArrowMouseDown Int Float Float
    | StartDrag Int Float Float
    | DragMove Float Float
    | EndDrag
    | DeleteState Int
    | DeleteTransition Int Int String
    | DeleteAllTransitionsBetween Int Int
    | SetStateLabel Int String
    | SetTransitionSymbol Int Int String String
    | UpdateTransitionInput String
    | ConfirmTransitionSymbol
    | UpdateStateLabelInput String
    | ConfirmStateLabel
    | ConfirmStateModal
    | DismissStateModal
    | SetStateModalIsStart Bool
    | SetStateModalIsEnd Bool
    | SetStateModalIsCompact Bool
    | ResetAutomaton
    | Undo
    | Redo
    | CancelAction
    | NoOp
    | SwitchToSimulator
    | CanvasMouseDown Float Float
    | ZoomIn
    | ZoomOut
    | RecenterCanvas Float Float
    | Wheel Float Float Float
    | ExportJson
    | ImportJsonRequested
    | ImportJsonLoaded File.File
    | ImportJsonContent String
    | ShareUrl
    | SaveRequested
    | UpdateSaveNameInput String
    | ConfirmSave
    | DismissSaveModal
    | LoadRequested
    | LoadFromStorage
    | StorageAutomataLoaded (List { name : String, data : String })
    | SelectStoredAutomaton String
    | DeleteStoredAutomaton String
    | DismissLoadModal
    | DismissStorageSelectModal
    | SwitchToConversion
    | AddDeadState
    | ShowGuide
    | ShowAboutGuide
    | ShowError String
    | ToggleConsole
    | ToggleSettings
    | ToggleDarkMode
    | ToggleLanguage
    | CopyDefinition
    | CopyDefReset
    | ToggleGridMode


init : Language -> Model
init language =
    { automaton = UndoList.fresh { states = [], transitions = [], nextStateId = 0 }
    , language = language
    , currentTool = BuildTool
    , selectedState = Nothing
    , transitionFrom = Nothing
    , consoleMessages =
        let
            t =
                Translations.getTranslations language
        in
        [ { text = t.editorWelcome, msgType = Console.InfoLink t.editorAboutProjectLink } ]
    , isDragging = False
    , draggedState = Nothing
    , dragStartX = 0
    , dragStartY = 0
    , editingTransition = Nothing
    , editingTransitionOldSymbol = Nothing
    , transitionInput = ""
    , editingStateId = Nothing
    , stateLabelInput = ""
    , stateModalIsStart = False
    , stateModalIsEnd = False
    , stateModalIsCompact = False
    , showLoadModal = False
    , showSaveModal = False
    , saveNameInput = ""
    , showStorageSelectModal = False
    , storedAutomata = []
    , panX = 0
    , panY = 0
    , zoom = 1.0
    , isPanning = False
    , panLastX = 0
    , panLastY = 0
    , hasPanned = False
    , copyDefSuccess = False
    , gridMode = False
    , bendingTransition = Nothing
    , bendDragStartX = 0
    , bendDragStartY = 0
    , isBending = False
    , draggingStartArrow = Nothing
    , isDraggingStartArrow = False
    }


initWith : Language -> Maybe AutomatonState -> Model
initWith language maybeAutomaton =
    case maybeAutomaton of
        Nothing ->
            init language

        Just automaton ->
            let
                initialModel =
                    init language

                t =
                    Translations.getTranslations language
            in
            { initialModel
                | automaton = UndoList.fresh automaton
                , consoleMessages = [ { text = t.editorLoadedFromUrl, msgType = Console.Info } ]
            }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        t =
            Translations.getTranslations model.language

        currentAutomaton = model.automaton.present
    in
    case msg of
        SwitchToSimulator ->
            ( model, Cmd.none )

        SwitchToConversion ->
            ( model, Cmd.none )

        AddDeadState ->
            let
                { states, transitions } = currentAutomaton
                alphabet =
                    transitions
                        |> List.filterMap (\tr -> if tr.symbol == "\u{03B5}" then Nothing else Just tr.symbol)
                        |> Set.fromList
                        |> Set.toList
                missingPairs =
                    states
                        |> List.concatMap (\state ->
                            alphabet
                                |> List.filter (\sym ->
                                    not (List.any (\tr -> tr.from == state.id && tr.symbol == sym) transitions)
                                )
                                |> List.map (\sym -> ( state.id, sym ))
                        )
                minY = List.map .y states |> List.minimum |> Maybe.withDefault 200
                avgX =
                    if List.isEmpty states then 300
                    else (List.map .x states |> List.sum) / toFloat (List.length states)
                existingIds = List.map .id states
                newDeadId = List.range 0 (List.length existingIds) |> List.filter (\i -> not (List.member i existingIds)) |> List.head |> Maybe.withDefault (List.length existingIds)
                deadState =
                    { id = newDeadId
                    , x = avgX
                    , y = minY - 150
                    , label = "dead state"
                    , isStart = False
                    , isEnd = False
                    , isCompact = False
                    , startAngle = pi
                    }
                deadTransitions =
                    List.map (\( fromId, sym ) -> { from = fromId, to = newDeadId, symbol = sym, bend = 0 }) missingPairs
                        ++ List.map (\sym -> { from = newDeadId, to = newDeadId, symbol = sym, bend = 0 }) alphabet
                newAutomaton =
                    { states = states ++ [ deadState ]
                    , transitions = transitions ++ deadTransitions
                    , nextStateId = newDeadId + 1
                    }
            in
            ( { model
                | automaton = UndoList.new newAutomaton model.automaton
                , consoleMessages = { text = t.editorDeadStateAdded, msgType = Console.Info } :: model.consoleMessages
              }
            , Cmd.none
            )

        ToggleConsole ->
            ( model, Cmd.none )

        ToggleSettings ->
            ( model, Cmd.none )

        ToggleDarkMode ->
            ( model, Cmd.none )

        ToggleLanguage ->
            ( { model | language = if model.language == Translations.Slovak then Translations.English else Translations.Slovak }, Cmd.none )

        ExportJson ->
            ( model, File.Download.string "automaton.json" "application/json"
                (Utils.AutomatonCodec.encode model.automaton.present) )

        ImportJsonRequested ->
            ( { model | showLoadModal = False }, File.Select.file [ "application/json" ] ImportJsonLoaded )

        ImportJsonLoaded file ->
            ( model, Task.perform ImportJsonContent (File.toString file) )

        ImportJsonContent content ->
            case Decode.decodeString Utils.AutomatonCodec.decoder content of
                Ok automaton ->
                    ( { model
                        | automaton = UndoList.fresh automaton
                                                , consoleMessages = { text = t.editorImportedFromFile, msgType = Console.Info } :: model.consoleMessages
                      }
                    , Cmd.none
                    )

                Err err ->
                    ( { model
                                                | consoleMessages = { text = t.editorImportErrorPrefix ++ Decode.errorToString err, msgType = Console.Error } :: model.consoleMessages
                      }
                    , Cmd.none
                    )

        ShareUrl ->
                        ( { model | consoleMessages = { text = t.editorUrlCopied, msgType = Console.Info } :: model.consoleMessages }
            , Cmd.none
            )

        CopyDefinition ->
            ( { model
                | copyDefSuccess = True
                                , consoleMessages = { text = t.editorDefinitionCopied, msgType = Console.Info } :: model.consoleMessages
              }
            , Task.perform (always CopyDefReset) (Process.sleep 2000)
            )

        CopyDefReset ->
            ( { model | copyDefSuccess = False }, Cmd.none )

        ToggleGridMode ->
            ( model, Cmd.none )

        SaveRequested ->
            ( { model | showSaveModal = True, saveNameInput = "" }, Cmd.none )

        UpdateSaveNameInput s ->
            ( { model | saveNameInput = s }, Cmd.none )

        ConfirmSave ->
            if String.isEmpty (String.trim model.saveNameInput) then
                ( { model | consoleMessages = { text = t.editorEnterName, msgType = Console.Error } :: model.consoleMessages }
                , Cmd.none
                )
            else
                ( { model
                    | showSaveModal = False
                    , saveNameInput = ""
                    , consoleMessages = { text = t.editorSavedPrefix ++ model.saveNameInput, msgType = Console.Info } :: model.consoleMessages
                  }
                , Cmd.none
                )

        DismissSaveModal ->
            ( { model | showSaveModal = False, saveNameInput = "" }, Cmd.none )

        LoadRequested ->
            ( { model | showLoadModal = True }
            , Cmd.none
            )

        LoadFromStorage ->
            ( model, Cmd.none )

        StorageAutomataLoaded list ->
            ( { model | storedAutomata = list, showLoadModal = True }, Cmd.none )

        SelectStoredAutomaton name ->
            let
                maybeEntry =
                    List.filter (\e -> e.name == name) model.storedAutomata |> List.head
            in
            case maybeEntry of
                Nothing ->
                    ( { model | showLoadModal = False }, Cmd.none )

                Just entry ->
                    case Decode.decodeString Utils.AutomatonCodec.decoder entry.data of
                        Ok automaton ->
                            ( { model
                                | automaton = UndoList.fresh automaton
                                , showLoadModal = False
                                                                , consoleMessages = { text = t.editorLoadedPrefix ++ name, msgType = Console.Info } :: model.consoleMessages
                              }
                            , Cmd.none
                            )

                        Err err ->
                            ( { model
                                | showLoadModal = False
                                                                , consoleMessages = { text = t.editorGenericErrorPrefix ++ Decode.errorToString err, msgType = Console.Error } :: model.consoleMessages
                              }
                            , Cmd.none
                            )

        DismissLoadModal ->
            ( { model | showLoadModal = False }, Cmd.none )

        DismissStorageSelectModal ->
            ( { model | showStorageSelectModal = False, storedAutomata = [] }, Cmd.none )

        DeleteStoredAutomaton name ->
            ( { model | storedAutomata = List.filter (\e -> e.name /= name) model.storedAutomata }, Cmd.none )

        Undo ->
            ( { model | automaton = UndoList.undo model.automaton }, Cmd.none )
        Redo ->
            ( { model | automaton = UndoList.redo model.automaton }, Cmd.none )

        CancelAction ->
            ( { model
                | editingTransition = Nothing
                , editingTransitionOldSymbol = Nothing
                , transitionInput = ""
                , transitionFrom = Nothing
                , editingStateId = Nothing
                , stateLabelInput = ""
                , stateModalIsStart = False
                , stateModalIsEnd = False
                                , consoleMessages = { text = t.editorActionCanceled, msgType = Console.Info } :: model.consoleMessages
              }
            , Cmd.none
            )

        ChangeTool tool ->
            let
                newTool =
                    case tool of
                        BuildTool ->
                            BuildTool
                        DeleteTool ->
                            if model.currentTool == DeleteTool then
                                BuildTool
                            else
                                DeleteTool
            in
            ( { model
                | currentTool = newTool
                , transitionFrom = Nothing
                , editingStateId = Nothing
                , stateLabelInput = ""
                , stateModalIsStart = False
                , stateModalIsEnd = False
                                , consoleMessages = { text = getToolMessage t newTool, msgType = Console.Info } :: model.consoleMessages
              }
            , Cmd.none
            )

        CanvasDoubleClick x y ->
            case model.currentTool of
                BuildTool ->
                    let
                        rawWorldX = (x - model.panX) / model.zoom
                        rawWorldY = (y - model.panY) / model.zoom
                        worldX = if model.gridMode then snapToGrid 60.0 rawWorldX else rawWorldX
                        worldY = if model.gridMode then snapToGrid 60.0 rawWorldY else rawWorldY
                        existingIds = List.map .id currentAutomaton.states
                        newId = List.range 0 (List.length existingIds) |> List.filter (\i -> not (List.member i existingIds)) |> List.head |> Maybe.withDefault (List.length existingIds)
                        newState =
                            { id = newId
                            , x = worldX
                            , y = worldY
                            , label = "q" ++ String.fromInt newId
                            , isStart = False
                            , isEnd = False
                            , isCompact = False
                            , startAngle = pi
                            }
                        message = t.editorStateAddedPrefix ++ newState.label
                        newAutomaton =
                            { currentAutomaton
                            | states = currentAutomaton.states ++ [ newState ]
                            , nextStateId = newId + 1
                            }
                    in
                    ( { model
                        | automaton = UndoList.new newAutomaton model.automaton
                        , transitionFrom = Nothing
                        , consoleMessages = { text = message, msgType = Console.Info } :: model.consoleMessages
                      }
                    , Cmd.none
                    )

                DeleteTool ->
                    ( model, Cmd.none )

        CanvasClick _ _ ->
            if model.hasPanned then
                ( { model | hasPanned = False }, Cmd.none )
            else
                ( { model
                    | selectedState = Nothing
                    , transitionFrom = Nothing
                    , editingStateId = Nothing
                    , stateLabelInput = ""
                    , stateModalIsStart = False
                    , stateModalIsEnd = False
                    , editingTransition = Nothing
                    , editingTransitionOldSymbol = Nothing
                    , transitionInput = ""
                  }
                , Cmd.none
                )

        StateClick stateId ->
            handleStateClick stateId model

        StateDoubleClick stateId ->
            case model.currentTool of
                BuildTool ->
                    let
                        fromState = getStateById stateId currentAutomaton.states
                        ( inputX, inputY ) =
                            case fromState of
                                Just fs -> selfLoopPopupPos fs.x fs.y (getGroupBend stateId stateId currentAutomaton.transitions)
                                Nothing -> ( 400, 300 )
                    in
                    ( { model
                        | editingTransition = Just { from = stateId, to = stateId, x = inputX, y = inputY }
                        , editingTransitionOldSymbol = Nothing
                        , transitionInput = ""
                        , transitionFrom = Nothing
                        , consoleMessages = { text = t.editorEnterTransitionSymbols, msgType = Console.Info } :: model.consoleMessages
                      }
                    , Task.attempt (\_ -> NoOp) (Browser.Dom.focus "transition-input")
                    )

                DeleteTool ->
                    ( model, Cmd.none )

        StateRightClick stateId ->
            case model.currentTool of
                BuildTool ->
                    let
                        maybeState = getStateById stateId currentAutomaton.states
                    in
                    case maybeState of
                        Just state ->
                            ( { model
                                | transitionFrom = Nothing
                                , editingTransition = Nothing
                                , editingTransitionOldSymbol = Nothing
                                , transitionInput = ""
                                , editingStateId = Just stateId
                                , stateLabelInput = state.label
                                , stateModalIsStart = state.isStart
                                , stateModalIsEnd = state.isEnd
                                , stateModalIsCompact = state.isCompact
                                , isDragging = False
                              }
                            , Task.attempt (\_ -> NoOp) (Browser.Dom.focus "state-modal-input")
                            )
                        Nothing ->
                            ( model, Cmd.none )

                DeleteTool ->
                    ( model, Cmd.none )

        StartDrag stateId x y ->
            case model.currentTool of
                BuildTool ->
                    let
                        worldX = (x - model.panX) / model.zoom
                        worldY = (y - model.panY) / model.zoom
                    in
                    ( { model
                        | draggedState = Just stateId
                        , dragStartX = worldX
                        , dragStartY = worldY
                        , isDragging = False
                        , isPanning = False
                      }
                    , Cmd.none
                    )

                DeleteTool ->
                    ( model, Cmd.none )

        DragMove x y ->
            if model.isPanning then
                ( { model
                    | panX = model.panX + (x - model.panLastX)
                    , panY = model.panY + (y - model.panLastY)
                    , panLastX = x
                    , panLastY = y
                    , hasPanned = True
                  }
                , Cmd.none
                )
            else
                case model.bendingTransition of
                    Just bt ->
                        let
                            worldX = (x - model.panX) / model.zoom
                            worldY = (y - model.panY) / model.zoom
                            dx = worldX - model.bendDragStartX
                            dy = worldY - model.bendDragStartY
                            dist = sqrt (dx * dx + dy * dy)
                        in
                        if not model.isBending && dist > 5 then
                            let
                                bendVal = computeBend bt.from bt.to worldX worldY currentAutomaton.states
                                newTransitions = updateTransitionBend bt.from bt.to bendVal currentAutomaton.transitions
                                newAutomaton = { currentAutomaton | transitions = newTransitions }
                                newHistory = UndoList.new currentAutomaton model.automaton
                            in
                            ( { model
                                | automaton = { newHistory | present = newAutomaton }
                                , isBending = True
                              }
                            , Cmd.none
                            )
                        else if model.isBending then
                            let
                                bendVal = computeBend bt.from bt.to worldX worldY currentAutomaton.states
                                newTransitions = updateTransitionBend bt.from bt.to bendVal currentAutomaton.transitions
                                newAutomaton = { currentAutomaton | transitions = newTransitions }
                                undoList = model.automaton
                            in
                            ( { model
                                | automaton = { undoList | present = newAutomaton }
                              }
                            , Cmd.none
                            )
                        else
                            ( model, Cmd.none )

                    Nothing ->
                        case model.draggingStartArrow of
                            Just saId ->
                                let
                                    worldX = (x - model.panX) / model.zoom
                                    worldY = (y - model.panY) / model.zoom
                                    dx = worldX - model.bendDragStartX
                                    dy = worldY - model.bendDragStartY
                                    dist = sqrt (dx * dx + dy * dy)
                                in
                                if not model.isDraggingStartArrow && dist > 5 then
                                    let
                                        angle = computeStartArrowAngle saId worldX worldY currentAutomaton.states
                                        newStates = updateStartAngle saId angle currentAutomaton.states
                                        newAutomaton = { currentAutomaton | states = newStates }
                                        newHistory = UndoList.new currentAutomaton model.automaton
                                    in
                                    ( { model
                                        | automaton = { newHistory | present = newAutomaton }
                                        , isDraggingStartArrow = True
                                      }
                                    , Cmd.none
                                    )
                                else if model.isDraggingStartArrow then
                                    let
                                        angle = computeStartArrowAngle saId worldX worldY currentAutomaton.states
                                        newStates = updateStartAngle saId angle currentAutomaton.states
                                        newAutomaton = { currentAutomaton | states = newStates }
                                        undoList = model.automaton
                                    in
                                    ( { model
                                        | automaton = { undoList | present = newAutomaton }
                                      }
                                    , Cmd.none
                                    )
                                else
                                    ( model, Cmd.none )

                            Nothing ->
                                case model.draggedState of
                                    Just stateId ->
                                        let
                                            rawWorldX = (x - model.panX) / model.zoom
                                            rawWorldY = (y - model.panY) / model.zoom
                                            worldX = if model.gridMode then snapToGrid 60.0 rawWorldX else rawWorldX
                                            worldY = if model.gridMode then snapToGrid 60.0 rawWorldY else rawWorldY
                                            dxr = rawWorldX - model.dragStartX
                                            dyr = rawWorldY - model.dragStartY
                                            dist = sqrt (dxr * dxr + dyr * dyr)
                                        in
                                        if not model.isDragging && dist > 5 then
                                            let
                                                newStates = updateStatePosition stateId worldX worldY currentAutomaton.states
                                                newAutomaton = { currentAutomaton | states = newStates }
                                                newHistory = UndoList.new currentAutomaton model.automaton
                                            in
                                            ( { model
                                                | automaton = { newHistory | present = newAutomaton }
                                                , isDragging = True
                                              }
                                            , Cmd.none
                                            )
                                        else if model.isDragging then
                                            let
                                                newStates = updateStatePosition stateId worldX worldY currentAutomaton.states
                                                newAutomaton = { currentAutomaton | states = newStates }
                                                undoList = model.automaton
                                            in
                                            ( { model
                                                | automaton = { undoList | present = newAutomaton }
                                              }
                                            , Cmd.none
                                            )
                                        else
                                            ( model, Cmd.none )

                                    Nothing ->
                                        ( model, Cmd.none )

        EndDrag ->
            ( { model | draggedState = Nothing, isPanning = False, bendingTransition = Nothing, isBending = False, draggingStartArrow = Nothing, isDraggingStartArrow = False }, Cmd.none )

        DeleteState stateId ->
            let
                state = getStateById stateId currentAutomaton.states
                label = Maybe.map .label state |> Maybe.withDefault ""
                message = t.editorStateDeletedPrefix ++ label
                newAutomaton =
                    { currentAutomaton
                    | states = List.filter (\s -> s.id /= stateId) currentAutomaton.states
                    , transitions = List.filter (\transition -> transition.from /= stateId && transition.to /= stateId) currentAutomaton.transitions
                    }
            in
            ( { model
                | automaton = UndoList.new newAutomaton model.automaton
                , selectedState = Nothing
                , consoleMessages = { text = message, msgType = Console.Info } :: model.consoleMessages
              }
            , Cmd.none
            )

        DeleteTransition from to symbol ->
            let
                message = t.editorTransitionDeletedPrefix ++ symbol
                newAutomaton =
                    { currentAutomaton
                    | transitions = List.filter (\transition -> not (transition.from == from && transition.to == to && transition.symbol == symbol)) currentAutomaton.transitions
                    }
            in
            ( { model
                | automaton = UndoList.new newAutomaton model.automaton
                , consoleMessages = { text = message, msgType = Console.Info } :: model.consoleMessages
              }
            , Cmd.none
            )

        DeleteAllTransitionsBetween from to ->
            case model.currentTool of
                DeleteTool ->
                    let
                        newAutomaton =
                            { currentAutomaton
                            | transitions = List.filter (\transition -> not (transition.from == from && transition.to == to)) currentAutomaton.transitions
                            }
                    in
                    ( { model
                        | automaton = UndoList.new newAutomaton model.automaton
                        , consoleMessages = { text = t.editorTransitionDeletedAll, msgType = Console.Info } :: model.consoleMessages
                      }
                    , Cmd.none
                    )

                BuildTool ->
                    let
                        fromState = getStateById from currentAutomaton.states
                        toState = getStateById to currentAutomaton.states
                        ( inputX, inputY ) =
                            case ( fromState, toState ) of
                                ( Just fs, Just ts ) ->
                                    if from == to then
                                        selfLoopPopupPos fs.x fs.y (getGroupBend from to currentAutomaton.transitions)
                                    else
                                        ( (fs.x + ts.x) / 2, (fs.y + ts.y) / 2 )
                                _ ->
                                    ( 400, 300 )
                        allSymbols =
                            List.filter (\tr -> tr.from == from && tr.to == to) currentAutomaton.transitions
                                |> List.map .symbol
                                |> List.sort
                                |> String.join " "
                    in
                    ( { model
                        | editingTransition = Just { from = from, to = to, x = inputX, y = inputY }
                        , editingTransitionOldSymbol = Just "__ALL__"
                        , transitionInput = allSymbols
                        , consoleMessages = { text = t.editorEditTransitionSymbol, msgType = Console.Info } :: model.consoleMessages
                      }
                    , Task.attempt (\_ -> NoOp) (Browser.Dom.focus "transition-input")
                    )

        SetStateLabel stateId newLabel ->
            let
                newAutomaton = { currentAutomaton | states = updateStateLabel stateId newLabel currentAutomaton.states }
            in
            ( { model
                | automaton = UndoList.new newAutomaton model.automaton
              }
            , Cmd.none
            )

        SetTransitionSymbol from to oldSymbol newSymbol ->
            let
                newAutomaton = { currentAutomaton | transitions = updateTransitionSymbol from to oldSymbol newSymbol currentAutomaton.transitions }
            in
            ( { model
                | automaton = UndoList.new newAutomaton model.automaton
              }
            , Cmd.none
            )

        UpdateStateLabelInput inputVal ->
            ( { model | stateLabelInput = inputVal }, Cmd.none )

        ConfirmStateLabel ->
            case model.editingStateId of
                Just stateId ->
                    if String.isEmpty (String.trim model.stateLabelInput) then
                        ( { model
                            | editingStateId = Nothing
                            , stateLabelInput = ""
                                                        , consoleMessages = { text = t.editorEmptyName, msgType = Console.Error } :: model.consoleMessages
                          }
                        , Cmd.none
                        )
                    else
                        let
                            newLabel = String.trim model.stateLabelInput
                            isDuplicate = List.any (\s -> s.label == newLabel && s.id /= stateId) currentAutomaton.states
                        in
                        if isDuplicate then
                            ( { model
                                | consoleMessages = { text = t.editorStateExistsPrefix ++ newLabel ++ t.editorStateExistsSuffix, msgType = Console.Error } :: model.consoleMessages
                              }
                            , Cmd.none
                            )
                        else
                            let
                                message = t.editorStateRenamedPrefix ++ newLabel
                                newAutomaton = { currentAutomaton | states = updateStateLabel stateId newLabel currentAutomaton.states }
                            in
                            ( { model
                                | automaton = UndoList.new newAutomaton model.automaton
                                , editingStateId = Nothing
                                , stateLabelInput = ""
                                , consoleMessages = { text = message, msgType = Console.Info } :: model.consoleMessages
                              }
                            , Cmd.none
                            )

                Nothing ->
                    ( model, Cmd.none )

        ConfirmStateModal ->
            case model.editingStateId of
                Just stateId ->
                    if String.isEmpty (String.trim model.stateLabelInput) then
                        ( { model | consoleMessages = { text = t.editorEmptyName, msgType = Console.Error } :: model.consoleMessages }
                        , Cmd.none
                        )
                    else
                        let
                            newLabel = String.trim model.stateLabelInput
                            isDuplicate = List.any (\s -> s.label == newLabel && s.id /= stateId) currentAutomaton.states
                        in
                        if isDuplicate then
                            ( { model | consoleMessages = { text = t.editorStateExistsPrefix ++ newLabel ++ t.editorStateExistsSuffix, msgType = Console.Error } :: model.consoleMessages }
                            , Cmd.none
                            )
                        else
                            let
                                statesWithLabel = updateStateLabel stateId newLabel currentAutomaton.states
                                statesWithStart =
                                    if model.stateModalIsStart then
                                        setStartState stateId statesWithLabel
                                    else
                                        List.map (\s -> if s.id == stateId then { s | isStart = False } else s) statesWithLabel
                                statesWithEnd =
                                    List.map (\s -> if s.id == stateId then { s | isEnd = model.stateModalIsEnd } else s) statesWithStart
                                statesWithCompact =
                                    List.map (\s -> if s.id == stateId then { s | isCompact = model.stateModalIsCompact } else s) statesWithEnd
                                newAutomaton = { currentAutomaton | states = statesWithCompact }
                                message = t.editorStateUpdatedPrefix ++ newLabel
                            in
                            ( { model
                                | automaton = UndoList.new newAutomaton model.automaton
                                , editingStateId = Nothing
                                , stateLabelInput = ""
                                , stateModalIsStart = False
                                , stateModalIsEnd = False
                                , stateModalIsCompact = False
                                , consoleMessages = { text = message, msgType = Console.Info } :: model.consoleMessages
                              }
                            , Cmd.none
                            )

                Nothing ->
                    ( model, Cmd.none )

        DismissStateModal ->
            ( { model
                | editingStateId = Nothing
                , stateLabelInput = ""
                , stateModalIsStart = False
                , stateModalIsEnd = False
                , stateModalIsCompact = False
              }
            , Cmd.none
            )

        SetStateModalIsStart val ->
            ( { model | stateModalIsStart = val }, Cmd.none )

        SetStateModalIsEnd val ->
            ( { model | stateModalIsEnd = val }, Cmd.none )

        SetStateModalIsCompact val ->
            ( { model | stateModalIsCompact = val }, Cmd.none )

        ResetAutomaton ->
            let
                newAutomaton =
                    { states = []
                    , transitions = []
                    , nextStateId = 0
                    }
            in
            ( { model
                | automaton = UndoList.new newAutomaton model.automaton
                , currentTool = BuildTool
                , selectedState = Nothing
                , transitionFrom = Nothing
                , consoleMessages = { text = t.editorReset, msgType = Console.Info } :: model.consoleMessages
                , isDragging = False
                , draggedState = Nothing
                , editingTransition = Nothing
                , editingTransitionOldSymbol = Nothing
                , transitionInput = ""
                , editingStateId = Nothing
                , stateLabelInput = ""
                , stateModalIsStart = False
                , stateModalIsEnd = False
                , panX = 0
                , panY = 0
                , zoom = 1.0
                , isPanning = False
                , panLastX = 0
                , panLastY = 0
                , hasPanned = False
              }
            , Cmd.none
            )

        UpdateTransitionInput inputVal ->
            let
                allSegmentsValid =
                    String.split " " inputVal
                        |> List.filter (not << String.isEmpty)
                        |> List.all (\seg -> String.length seg <= 1)
            in
            if allSegmentsValid then
                ( { model | transitionInput = inputVal }, Cmd.none )
            else
                ( model, Cmd.none )

        ConfirmTransitionSymbol ->
            case model.editingTransition of
                Just { from, to } ->
                    case model.editingTransitionOldSymbol of
                        Just oldSymbol ->
                            -- Edit mode: remove old transition(s), add new (space-separated)
                            let
                                newInput = String.trim model.transitionInput
                                -- Preserve existing bend value
                                oldBend =
                                    List.filter (\tr -> tr.from == from && tr.to == to) currentAutomaton.transitions
                                        |> List.head
                                        |> Maybe.map .bend
                                        |> Maybe.withDefault 0
                                -- "__ALL__" sentinel means replace all transitions between from/to
                                filteredTransitions =
                                    if oldSymbol == "__ALL__" then
                                        List.filter (\transition -> not (transition.from == from && transition.to == to)) currentAutomaton.transitions
                                    else
                                        List.filter (\transition -> not (transition.from == from && transition.to == to && transition.symbol == oldSymbol)) currentAutomaton.transitions
                            in
                            if String.isEmpty newInput then
                                -- Empty → ε transition
                                if from == to then
                                    ( { model | consoleMessages = { text = t.editorLoopCannotBeEpsilon, msgType = Console.Error } :: model.consoleMessages }
                                    , Cmd.none
                                    )
                                else if List.any (\tr -> tr.from == from && tr.to == to && tr.symbol == "ε") filteredTransitions then
                                    ( { model | consoleMessages = { text = t.editorEpsilonTransitionExists, msgType = Console.Error } :: model.consoleMessages }
                                    , Cmd.none
                                    )
                                else
                                    let
                                        newAutomaton = { currentAutomaton | transitions = filteredTransitions ++ [ { from = from, to = to, symbol = "ε", bend = oldBend } ] }
                                    in
                                    ( { model
                                        | automaton = UndoList.new newAutomaton model.automaton
                                        , editingTransition = Nothing
                                        , editingTransitionOldSymbol = Nothing
                                        , transitionInput = ""
                                        , transitionFrom = Nothing
                                        , selectedState = Nothing
                                        , consoleMessages = { text = t.editorTransitionAddedPrefix ++ "ε", msgType = Console.Info } :: model.consoleMessages
                                      }
                                    , Cmd.none
                                    )
                            else
                                -- Parse space-separated symbols
                                let
                                    rawSymbols =
                                        String.split " " newInput
                                            |> List.filter (not << String.isEmpty)

                                    symbols =
                                        Set.fromList rawSymbols
                                            |> Set.toList
                                            |> List.sort

                                    duplicates =
                                        List.filter (\sym -> transitionExists from to sym filteredTransitions) symbols

                                    uniqueSymbols =
                                        List.filter (\sym -> not (transitionExists from to sym filteredTransitions)) symbols
                                in
                                if from == to && List.member "ε" symbols then
                                    ( { model | consoleMessages = { text = t.editorLoopCannotBeEpsilon, msgType = Console.Error } :: model.consoleMessages }
                                    , Cmd.none
                                    )
                                else if not (List.isEmpty duplicates) then
                                    ( { model | consoleMessages = { text = t.editorTransitionsExistPrefix ++ String.join ", " duplicates, msgType = Console.Error } :: model.consoleMessages }
                                    , Cmd.none
                                    )
                                else
                                    let
                                        newTransitions =
                                            List.foldl
                                                (\symbol acc -> acc ++ [ { from = from, to = to, symbol = symbol, bend = oldBend } ])
                                                filteredTransitions
                                                uniqueSymbols

                                        addedCount = List.length newTransitions - List.length filteredTransitions

                                        message =
                                            if addedCount == 1 then
                                                t.editorTransitionAddedPrefix ++ String.join ", " uniqueSymbols
                                            else
                                                t.editorTransitionsAddedPrefix ++ String.fromInt addedCount ++ t.editorTransitionsAddedSuffix

                                        newAutomaton = { currentAutomaton | transitions = newTransitions }
                                    in
                                    ( { model
                                        | automaton = UndoList.new newAutomaton model.automaton
                                        , editingTransition = Nothing
                                        , editingTransitionOldSymbol = Nothing
                                        , transitionInput = ""
                                        , transitionFrom = Nothing
                                        , selectedState = Nothing
                                        , consoleMessages = { text = message, msgType = Console.Info } :: model.consoleMessages
                                      }
                                    , Cmd.none
                                    )

                        Nothing ->
                            -- Create mode: existing behavior
                            if String.isEmpty (String.trim model.transitionInput) then
                                if from == to then
                                    ( { model | consoleMessages = { text = t.editorLoopCannotBeEpsilon, msgType = Console.Error } :: model.consoleMessages }
                                    , Cmd.none
                                    )
                                else if transitionExists from to "ε" currentAutomaton.transitions then
                                    ( { model
                                        | consoleMessages = { text = t.editorEpsilonTransitionExists, msgType = Console.Error } :: model.consoleMessages
                                      }
                                    , Cmd.none
                                    )

                                else
                                    let
                                        newAutomaton =
                                            { currentAutomaton | transitions = currentAutomaton.transitions ++ [ { from = from, to = to, symbol = "ε", bend = 0 } ] }
                                    in
                                    ( { model
                                        | automaton = UndoList.new newAutomaton model.automaton
                                        , editingTransition = Nothing
                                        , transitionInput = ""
                                        , transitionFrom = Nothing
                                        , selectedState = Nothing
                                        , consoleMessages = { text = t.editorEpsilonTransitionAdded, msgType = Console.Info } :: model.consoleMessages
                                      }
                                    , Cmd.none
                                    )

                            else
                                let
                                    rawSymbols =
                                        String.split " " model.transitionInput
                                            |> List.filter (not << String.isEmpty)

                                    symbols =
                                        Set.fromList rawSymbols
                                            |> Set.toList
                                            |> List.sort

                                    duplicates =
                                        List.filter (\sym -> transitionExists from to sym currentAutomaton.transitions) symbols

                                    uniqueSymbols =
                                        List.filter (\sym -> not (transitionExists from to sym currentAutomaton.transitions)) symbols
                                in
                                if from == to && List.member "ε" symbols then
                                    ( { model | consoleMessages = { text = t.editorLoopCannotBeEpsilon, msgType = Console.Error } :: model.consoleMessages }
                                    , Cmd.none
                                    )
                                else if not (List.isEmpty duplicates) then
                                    let
                                        errorMsg = t.editorTransitionsExistPrefix ++ String.join ", " duplicates
                                    in
                                    ( { model
                                        | consoleMessages = { text = errorMsg, msgType = Console.Error } :: model.consoleMessages
                                       }
                                    , Cmd.none
                                    )
                                else
                                    let
                                        newTransitions =
                                            List.foldl
                                                (\symbol acc ->
                                                    acc ++ [ { from = from, to = to, symbol = symbol, bend = 0 } ]
                                                )
                                                currentAutomaton.transitions
                                                uniqueSymbols

                                        addedCount =
                                            List.length newTransitions - List.length currentAutomaton.transitions

                                        message =
                                            if addedCount == 0 then
                                                t.editorAllTransitionsExist
                                            else if addedCount == 1 then
                                                t.editorTransitionAddedPrefix ++ String.join ", " uniqueSymbols
                                            else
                                                t.editorTransitionsAddedPrefix ++ String.fromInt addedCount ++ t.editorTransitionsAddedSuffix

                                        newAutomaton = { currentAutomaton | transitions = newTransitions }
                                    in
                                    ( { model
                                        | automaton = UndoList.new newAutomaton model.automaton
                                        , editingTransition = Nothing
                                        , transitionInput = ""
                                        , transitionFrom = Nothing
                                        , selectedState = Nothing
                                        , consoleMessages = { text = message, msgType = Console.Info } :: model.consoleMessages
                                      }
                                    , Cmd.none
                                    )

                Nothing ->
                    ( model, Cmd.none )

        TransitionClick from to _ ->
            case model.currentTool of
                DeleteTool ->
                    let
                        newAutomaton =
                            { currentAutomaton
                            | transitions = List.filter (\transition -> not (transition.from == from && transition.to == to)) currentAutomaton.transitions
                            }
                    in
                    ( { model
                        | automaton = UndoList.new newAutomaton model.automaton
                        , consoleMessages = { text = t.editorTransitionDeletedAll, msgType = Console.Info } :: model.consoleMessages
                      }
                    , Cmd.none
                    )

                BuildTool ->
                    ( model, Cmd.none )

        TransitionRightClick from to _ ->
            let
                fromState = getStateById from currentAutomaton.states
                toState = getStateById to currentAutomaton.states
                ( inputX, inputY ) =
                    case ( fromState, toState ) of
                        ( Just fs, Just ts ) ->
                            if from == to then
                                selfLoopPopupPos fs.x fs.y (getGroupBend from to currentAutomaton.transitions)
                            else
                                ( (fs.x + ts.x) / 2, (fs.y + ts.y) / 2 )
                        _ ->
                            ( 400, 300 )
                allSymbols =
                    List.filter (\tr -> tr.from == from && tr.to == to) currentAutomaton.transitions
                        |> List.map .symbol
                        |> List.sort
                        |> String.join " "
            in
            ( { model
                | editingTransition = Just { from = from, to = to, x = inputX, y = inputY }
                , editingTransitionOldSymbol = Just "__ALL__"
                , transitionInput = allSymbols
                , consoleMessages = { text = t.editorEditTransitionSymbol, msgType = Console.Info } :: model.consoleMessages
              }
            , Task.attempt (\_ -> NoOp) (Browser.Dom.focus "transition-input")
            )

        ArrowMouseDown from to x y ->
            case model.currentTool of
                BuildTool ->
                    let
                        worldX = (x - model.panX) / model.zoom
                        worldY = (y - model.panY) / model.zoom
                    in
                    ( { model
                        | bendingTransition = Just { from = from, to = to }
                        , bendDragStartX = worldX
                        , bendDragStartY = worldY
                        , isBending = False
                        , isPanning = False
                      }
                    , Cmd.none
                    )

                DeleteTool ->
                    ( model, Cmd.none )

        StartArrowMouseDown stateId x y ->
            case model.currentTool of
                BuildTool ->
                    let
                        worldX = (x - model.panX) / model.zoom
                        worldY = (y - model.panY) / model.zoom
                    in
                    ( { model
                        | draggingStartArrow = Just stateId
                        , bendDragStartX = worldX
                        , bendDragStartY = worldY
                        , isDraggingStartArrow = False
                        , isPanning = False
                      }
                    , Cmd.none
                    )

                DeleteTool ->
                    ( model, Cmd.none )

        ArrowRightClick from to ->
            case model.currentTool of
                DeleteTool ->
                    let
                        newAutomaton =
                            { currentAutomaton
                            | transitions = List.filter (\transition -> not (transition.from == from && transition.to == to)) currentAutomaton.transitions
                            }
                    in
                    ( { model
                        | automaton = UndoList.new newAutomaton model.automaton
                        , consoleMessages = { text = t.editorTransitionDeletedAll, msgType = Console.Info } :: model.consoleMessages
                      }
                    , Cmd.none
                    )

                BuildTool ->
                    let
                        fromState = getStateById from currentAutomaton.states
                        toState = getStateById to currentAutomaton.states
                        ( inputX, inputY ) =
                            case ( fromState, toState ) of
                                ( Just fs, Just ts ) ->
                                    if from == to then
                                        selfLoopPopupPos fs.x fs.y (getGroupBend from to currentAutomaton.transitions)
                                    else
                                        ( (fs.x + ts.x) / 2, (fs.y + ts.y) / 2 )
                                _ ->
                                    ( 400, 300 )
                        allSymbols =
                            List.filter (\tr -> tr.from == from && tr.to == to) currentAutomaton.transitions
                                |> List.map .symbol
                                |> List.sort
                                |> String.join " "
                    in
                    ( { model
                        | editingTransition = Just { from = from, to = to, x = inputX, y = inputY }
                        , editingTransitionOldSymbol = Just "__ALL__"
                        , transitionInput = allSymbols
                        , consoleMessages = { text = t.editorEditTransitionSymbol, msgType = Console.Info } :: model.consoleMessages
                      }
                    , Task.attempt (\_ -> NoOp) (Browser.Dom.focus "transition-input")
                    )

        CanvasMouseDown x y ->
            ( { model | isPanning = True, panLastX = x, panLastY = y, hasPanned = False }, Cmd.none )

        ZoomIn ->
            ( { model | zoom = min 3.0 (model.zoom * 1.2) }, Cmd.none )

        ZoomOut ->
            ( { model | zoom = max 0.2 (model.zoom / 1.2) }, Cmd.none )

        RecenterCanvas cw ch ->
            let
                targetState =
                    List.filter .isStart model.automaton.present.states
                        |> List.head
                        |> (\ms -> case ms of
                                Just s -> Just s
                                Nothing -> List.reverse model.automaton.present.states |> List.head
                           )
            in
            case targetState of
                Just s ->
                    ( { model
                        | panX = cw / 2 - s.x * model.zoom
                        , panY = ch / 2 - s.y * model.zoom
                      }
                    , Cmd.none
                    )

                Nothing ->
                    ( model, Cmd.none )

        Wheel deltaY mouseX mouseY ->
            let
                zoomFactor = if deltaY > 0 then 0.9 else 1.1
                newZoom = model.zoom * zoomFactor |> min 3.0 |> max 0.2
                scale = newZoom / model.zoom
                newPanX = mouseX - (mouseX - model.panX) * scale
                newPanY = mouseY - (mouseY - model.panY) * scale
            in
            ( { model | zoom = newZoom, panX = newPanX, panY = newPanY }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

        ShowGuide ->
            ( model, Cmd.none )

        ShowAboutGuide ->
            ( model, Cmd.none )

        ShowError text ->
            ( { model | consoleMessages = { text = text, msgType = Console.Error } :: model.consoleMessages }
            , Cmd.none
            )


handleStateClick : Int -> Model -> ( Model, Cmd Msg )
handleStateClick stateId model =
    let
        currentAutomaton = model.automaton.present

        t =
            Translations.getTranslations model.language
    in
    case model.currentTool of
        DeleteTool ->
            let
                state = getStateById stateId currentAutomaton.states
                label = Maybe.map .label state |> Maybe.withDefault ""
                message = t.editorStateDeletedPrefix ++ label
                newAutomaton =
                    { currentAutomaton
                    | states = List.filter (\s -> s.id /= stateId) currentAutomaton.states
                    , transitions = List.filter (\transition -> transition.from /= stateId && transition.to /= stateId) currentAutomaton.transitions
                    }
            in
            ( { model
                | automaton = UndoList.new newAutomaton model.automaton
                , consoleMessages = { text = message, msgType = Console.Info } :: model.consoleMessages
              }
            , Cmd.none
            )

        BuildTool ->
            if model.isDragging then
                ( { model | isDragging = False }, Cmd.none )
            else
                case model.transitionFrom of
                    Nothing ->
                        ( { model
                            | transitionFrom = Just stateId
                                                        , consoleMessages = { text = t.editorSelectTargetState, msgType = Console.Info } :: model.consoleMessages
                          }
                        , Cmd.none
                        )

                    Just fromId ->
                        let
                            fromState = getStateById fromId currentAutomaton.states
                            toState = getStateById stateId currentAutomaton.states
                            ( inputX, inputY ) =
                                case ( fromState, toState ) of
                                    ( Just fs, Just ts ) ->
                                        if fromId == stateId then
                                            selfLoopPopupPos fs.x fs.y (getGroupBend fromId stateId currentAutomaton.transitions)
                                        else
                                            ( (fs.x + ts.x) / 2, (fs.y + ts.y) / 2 )
                                    _ ->
                                        ( 400, 300 )
                        in
                        ( { model
                            | editingTransition = Just { from = fromId, to = stateId, x = inputX, y = inputY }
                            , editingTransitionOldSymbol = Nothing
                            , transitionInput = ""
                                                        , consoleMessages = { text = t.editorEnterTransitionSymbols, msgType = Console.Info } :: model.consoleMessages
                          }
                        , Task.attempt (\_ -> NoOp) (Browser.Dom.focus "transition-input")
                        )


snapToGrid : Float -> Float -> Float
snapToGrid gridSize val =
    toFloat (round (val / gridSize)) * gridSize


computeBend : Int -> Int -> Float -> Float -> List State -> Float
computeBend fromId toId mouseX mouseY states =
    let
        fromState = getStateById fromId states
        toState = getStateById toId states
    in
    case ( fromState, toState ) of
        ( Just fs, Just ts ) ->
            if fromId == toId then
                -- Self-loop: bend = angle from state center to mouse
                -- Convention: bend=0 means "up", stored as offset from -pi/2
                -- atan2 gives standard math angle, add pi/2 so 0=up
                let
                    rawAngle = atan2 (mouseY - fs.y) (mouseX - fs.x)
                in
                rawAngle + pi / 2

            else
                let
                    vx = ts.x - fs.x
                    vy = ts.y - fs.y
                    len = sqrt (vx * vx + vy * vy)
                    uxDir = if len == 0 then 1 else vx / len
                    uyDir = if len == 0 then 0 else vy / len
                    px = -uyDir
                    py = uxDir
                    midX = (fs.x + ts.x) / 2
                    midY = (fs.y + ts.y) / 2
                    dmx = mouseX - midX
                    dmy = mouseY - midY
                    bendVal = (dmx * px + dmy * py) * 2
                in
                bendVal

        _ ->
            0


selfLoopPopupPos : Float -> Float -> Float -> ( Float, Float )
selfLoopPopupPos stateX stateY bend =
    let
        midAngle = bend - pi / 2
        dist = 80
    in
    ( stateX + dist * cos midAngle
    , stateY + dist * sin midAngle
    )


getGroupBend : Int -> Int -> List Transition -> Float
getGroupBend fromId toId transitions =
    List.filter (\tr -> tr.from == fromId && tr.to == toId) transitions
        |> List.head
        |> Maybe.map .bend
        |> Maybe.withDefault 0


updateTransitionBend : Int -> Int -> Float -> List Transition -> List Transition
updateTransitionBend fromId toId newBend transitions =
    List.map
        (\tr ->
            if tr.from == fromId && tr.to == toId then
                { tr | bend = newBend }
            else
                tr
        )
        transitions


computeStartArrowAngle : Int -> Float -> Float -> List State -> Float
computeStartArrowAngle stateId mouseX mouseY states =
    case getStateById stateId states of
        Just s ->
            atan2 (mouseY - s.y) (mouseX - s.x)

        Nothing ->
            pi


updateStartAngle : Int -> Float -> List State -> List State
updateStartAngle stateId angle states =
    List.map
        (\s ->
            if s.id == stateId then
                { s | startAngle = angle }
            else
                s
        )
        states


getToolMessage : Translations.Translations -> Tool -> String
getToolMessage t tool =
    case tool of
        BuildTool ->
            t.editorToolBuildMessage

        DeleteTool ->
            t.editorToolDeleteMessage


toolToString : Tool -> String
toolToString tool =
    case tool of
        BuildTool ->
            "BuildTool"

        DeleteTool ->
            "DeleteTool"


view : Bool -> Bool -> Bool -> Language -> Int -> Int -> Maybe String -> Model -> Html Msg
view consoleOpen darkMode settingsOpen language windowWidth windowHeight tutorialHighlightGroup model =
    let
        t =
            Translations.getTranslations language

        theme = Theme.getTheme darkMode
        canvasW = toFloat windowWidth - 302
        canvasH = toFloat windowHeight - 80
        { states, transitions } = model.automaton.present
        hasStart = List.any .isStart states
        hasEnd = List.any .isEnd states
        isSimulateEnabled = not (List.isEmpty states) && hasStart && hasEnd
        autoType = classifyAutomaton states transitions
        isConvertEnabled = not (List.isEmpty states) && hasStart && hasEnd && autoType == NFA
        problematicTransitions =
            if autoType == CompleteDFA then
                []
            else
                let
                    nonDetKeys =
                        transitions
                            |> List.filter (\tr -> tr.symbol /= "\u{03B5}")
                            |> List.filter (\tr ->
                                List.length (List.filter (\t2 -> t2.from == tr.from && t2.symbol == tr.symbol) transitions) > 1
                            )
                            |> List.map (\tr -> { from = tr.from, to = tr.to })
                    epsHighlights =
                        transitions
                            |> List.filter (\tr -> tr.symbol == "\u{03B5}")
                            |> List.map (\tr -> { from = tr.from, to = tr.to })
                in
                nonDetKeys ++ epsHighlights

        problematicSymbols =
            if autoType == CompleteDFA then
                []
            else
                let
                    nonDetSymbols =
                        transitions
                            |> List.filter (\tr -> tr.symbol /= "\u{03B5}")
                            |> List.filter (\tr ->
                                List.length (List.filter (\t2 -> t2.from == tr.from && t2.symbol == tr.symbol) transitions) > 1
                            )
                            |> List.map (\tr -> { from = tr.from, to = tr.to, symbol = tr.symbol })
                    epsSymbols =
                        transitions
                            |> List.filter (\tr -> tr.symbol == "\u{03B5}")
                            |> List.map (\tr -> { from = tr.from, to = tr.to, symbol = tr.symbol })
                in
                nonDetSymbols ++ epsSymbols

        simulateDisabledReason =
            if List.isEmpty states then
                Just t.editorAddStateRequirement
            else if not hasStart then
                Just t.editorStartStateRequirement
            else if not hasEnd then
                Just t.editorEndStateRequirement
            else
                Nothing
        convertDisabledReason =
            if List.isEmpty states then
                Just t.editorAddStateRequirement
            else if not hasStart then
                Just t.editorStartStateRequirement
            else if not hasEnd then
                Just t.editorEndStateRequirement
            else if autoType == CompleteDFA then
                Just t.editorConvertRequirement
            else if autoType == IncompleteDFA then
                Just t.editorConvertRequirementIncomplete
            else
                Nothing
    in
    div
        [ style "display" "flex"
        , style "flex-direction" "column"
        , style "height" "100vh"
        , style "width" "100vw"
        , style "overflow" "hidden"
        ]
        [
          div [ style "display" "flex", style "flex-direction" "column", style "width" "100%" ]
            [ Toolbar.view
                { onResetTool = ResetAutomaton
                , onBuildTool = ChangeTool BuildTool
                , onDeleteTool = ChangeTool DeleteTool
                , onUndo = Undo
                , onRedo = Redo
                , onSwitchToSimulator = SwitchToSimulator
                , canUndo = UndoList.hasPast model.automaton
                , canRedo = UndoList.hasFuture model.automaton
                , currentTool = toolToString model.currentTool
                , isSimulateEnabled = isSimulateEnabled
                , simulateDisabledReason = simulateDisabledReason
                , onSimulateDisabledClick = ShowError (Maybe.withDefault "" simulateDisabledReason)
                , onExport = ExportJson
                , onSave = SaveRequested
                , onLoad = LoadRequested
                , onShare = ShareUrl
                , onSwitchToConversion = SwitchToConversion
                , isConvertEnabled = isConvertEnabled
                , convertDisabledReason = convertDisabledReason
                , onConvertDisabledClick = ShowError (Maybe.withDefault "" convertDisabledReason)
                , isAddDeadStateEnabled = autoType == IncompleteDFA
                , onAddDeadState = AddDeadState
                , addDeadStateInfoTooltip = t.editorAddDeadStateInfo
                , onShowGuide = ShowGuide
                , theme = theme
                , settingsOpen = settingsOpen
                , onToggleSettings = ToggleSettings
                , onToggleDarkMode = ToggleDarkMode
                , darkMode = darkMode
                , language = language
                , onToggleLanguage = ToggleLanguage
                , gridMode = model.gridMode
                , onToggleGridMode = ToggleGridMode
                , tutorialHighlightGroup = tutorialHighlightGroup
                , windowWidth = windowWidth
                }
            ]
        ,
          div
            [ style "display" "flex"
            , style "flex-direction" "row"
            , style "flex" "1"
            , style "overflow" "hidden"
            ]
            [
              let
                targetState =
                    List.filter .isStart states
                        |> List.head
                        |> (\ms -> case ms of
                                Just s -> Just s
                                Nothing -> List.reverse states |> List.head
                           )
                targetVisible =
                    case targetState of
                        Just s ->
                            let
                                sx = s.x * model.zoom + model.panX
                                sy = s.y * model.zoom + model.panY
                            in
                            sx >= -35 && sx <= canvasW + 35 && sy >= -35 && sy <= canvasH + 35
                        Nothing ->
                            True
              in
              div
                [ style "flex" "1"
                , style "overflow" "hidden"
                , style "background-color" theme.canvasBg
                , style "user-select" "none"
                , style "position" "relative"
                ]
                [ Canvas.view
                    { states = states
                    , transitions = transitions
                    , selectedState = model.selectedState
                    , transitionFrom = case model.editingTransition of
                        Just { from } -> Just from
                        Nothing -> model.transitionFrom
                    , transitionTo = Maybe.map .to model.editingTransition
                    , activeStateId = Nothing
                    , activeStateVerdict = Nothing
                    , activeTransition = Nothing
                    , onCanvasClick = CanvasClick
                    , onCanvasDoubleClick = CanvasDoubleClick
                    , onStateClick = StateClick
                    , onStateDoubleClick = StateDoubleClick
                    , onStateRightClick = StateRightClick
                    , onTransitionClick = TransitionClick
                    , onTransitionRightClick = TransitionRightClick
                    , onArrowMouseDown = ArrowMouseDown
                    , onArrowRightClick = ArrowRightClick
                    , onStartArrowMouseDown = StartArrowMouseDown
                    , onStartDrag = StartDrag
                    , onDragMove = DragMove
                    , onEndDrag = EndDrag
                    , onCanvasMouseDown = CanvasMouseDown
                    , onZoomIn = ZoomIn
                    , onZoomOut = ZoomOut
                    , onWheel = \d x y -> Wheel d x y
                    , panX = model.panX
                    , panY = model.panY
                    , zoom = model.zoom
                    , width = 800
                    , height = 600
                    , isSimulateMode = False
                    , highlightedStateIds = []
                    , highlightedTransitions = problematicTransitions
                    , highlightedSymbols = problematicSymbols
                    , editingStateId = model.editingStateId
                    , theme = theme
                    , gridMode = model.gridMode
                    }
                , button
                    ([ style "position" "absolute"
                    , style "top" "10px"
                    , style "right" "10px"
                    , style "z-index" "10"
                    , style "padding" "8px 16px"
                    , style "font-size" "14px"
                    , style "font-weight" "bold"
                    , style "border" "none"
                    , style "border-radius" "4px"
                    , style "cursor" (if targetVisible then "default" else "pointer")
                    , style "display" "flex"
                    , style "align-items" "center"
                    , style "justify-content" "center"
                    , style "opacity" (if targetVisible then "0.4" else "1")
                    , style "background-color" theme.btnSecondaryBg
                    , style "color" theme.textOnDark
                    , style "white-space" "nowrap"
                    ] ++ (if targetVisible then [ Html.Attributes.disabled True ] else [ onClick (RecenterCanvas canvasW canvasH) ]))
                    [ text t.editorRecenter ]
                ]
            , div
                [ style "width" "300px"
                , style "flex-shrink" "0"
                , style "background-color" theme.rightPanelBg
                , style "border-left" ("2px solid " ++ theme.rightPanelBorder)
                , style "display" "flex"
                , style "flex-direction" "column"
                , style "overflow" "hidden"
                ]
                [ AutomatonDisplay.view
                    { states = states
                    , transitions = transitions
                    , theme = theme
                    , language = language
                    , onCopyDefinition = CopyDefinition
                    , copySuccess = model.copyDefSuccess
                    }
                ]
            ]
        ,
          Console.view
            { messages = model.consoleMessages
            , isOpen = consoleOpen
            , onToggle = ToggleConsole
            , onLinkClick = Just ShowAboutGuide
            , theme = theme
                        , language = language
            }
        ,
                    viewInlineTransitionInput theme t canvasW model
        ,
                    viewStateModal theme t canvasW model
        ,
                    viewLoadModal theme t model
        ,
                    viewSaveModal theme t model
        ]


viewInlineTransitionInput : Theme.Theme -> Translations.Translations -> Float -> Model -> Html Msg
viewInlineTransitionInput theme t canvasW model =
    case model.editingTransition of
        Just { x, y } ->
            let
                screenX = x * model.zoom + model.panX
                screenY = y * model.zoom + model.panY
                popupW = 195
                popupH = 70
                stateR = 35 * model.zoom
                popupLeft =
                    if screenX - popupW / 2 < 0 then
                        screenX + stateR
                    else if screenX + popupW / 2 > canvasW then
                        screenX - stateR - popupW
                    else
                        screenX - popupW / 2
                popupTop =
                    if screenY - stateR - popupH < 0 then
                        screenY + stateR + 5
                    else
                        screenY - stateR - popupH - 5
            in
            div
                [ style "position" "absolute"
                , style "left" (String.fromFloat popupLeft ++ "px")
                , style "top" (String.fromFloat popupTop ++ "px")
                , style "z-index" "1000"
                , style "background-color" theme.inputBg
                , style "border" ("2px solid " ++ theme.overlayBorder)
                , style "border-radius" "4px"
                , style "padding" "8px"
                , style "box-shadow" "0 2px 8px rgba(0,0,0,0.2)"
                ]
                [ div
                    [ style "font-size" "11px"
                    , style "color" theme.overlayHint
                    , style "margin-bottom" "4px"
                    , style "white-space" "pre-line"
                    ]
                    [ text (case model.editingTransitionOldSymbol of
                        Just _ -> t.editorEditSymbolLabel
                        Nothing -> t.editorSymbolsHint)
                    ]
                , div
                    [ style "display" "flex"
                    , style "border" ("1px solid " ++ theme.inputBorder)
                    , style "border-radius" "3px"
                    , style "overflow" "hidden"
                    ]
                    [ input
                        [ type_ "text"
                        , Html.Attributes.id "transition-input"
                        , placeholder "a b \u{03B5}"
                        , value model.transitionInput
                        , onInput UpdateTransitionInput
                        , autofocus True
                        , onEnterKey ConfirmTransitionSymbol
                        , style "flex" "1"
                        , style "min-width" "0"
                        , style "padding" "5px 7px"
                        , style "border" "none"
                        , style "outline" "none"
                        , style "font-size" "13px"
                        , style "background-color" theme.inputBg
                        , style "color" theme.inputText
                        ]
                        []
                    , button
                        [ onClick ConfirmTransitionSymbol
                        , style "padding" "5px 10px"
                        , style "background-color" theme.btnPrimary
                        , style "color" theme.textOnDark
                        , style "border" "none"
                        , style "font-size" "13px"
                        , style "font-weight" "bold"
                        , style "cursor" "pointer"
                        ]
                        [ text "OK" ]
                    ]
                ]

        Nothing ->
            div [] []


viewStateModal : Theme.Theme -> Translations.Translations -> Float -> Model -> Html Msg
viewStateModal theme t canvasW model =
    case model.editingStateId of
        Just stateId ->
            let
                maybeState = List.filter (\s -> s.id == stateId) model.automaton.present.states |> List.head
            in
            case maybeState of
                Just state ->
                    let
                        screenX = state.x * model.zoom + model.panX
                        screenY = state.y * model.zoom + model.panY
                        modalW = 240
                        modalH = 200
                        stateR = 35 * model.zoom
                        modalLeft =
                            if screenX - modalW / 2 < 0 then
                                screenX + stateR
                            else if screenX + modalW / 2 > canvasW then
                                screenX - stateR - modalW
                            else
                                screenX - modalW / 2
                        modalTop =
                            if screenY - stateR - modalH < 0 then
                                screenY + stateR + 5
                            else
                                screenY - stateR - modalH - 5
                    in
                    div
                        [ style "position" "absolute"
                        , style "left" (String.fromFloat modalLeft ++ "px")
                        , style "top" (String.fromFloat modalTop ++ "px")
                        , style "z-index" "1000"
                        , style "background-color" theme.inputBg
                        , style "border" ("2px solid " ++ theme.overlayBorder)
                        , style "border-radius" "6px"
                        , style "padding" "12px"
                        , style "box-shadow" "0 4px 12px rgba(0,0,0,0.25)"
                        , style "min-width" "220px"
                        ]
                        [ div
                            [ style "font-weight" "bold"
                            , style "font-size" "13px"
                            , style "margin-bottom" "8px"
                            , style "color" theme.textPrimary
                            ]
                            [ text t.editorEditStateTitle ]
                        , input
                            [ type_ "text"
                            , Html.Attributes.id "state-modal-input"
                            , placeholder t.editorStateNamePlaceholder
                            , value model.stateLabelInput
                            , onInput UpdateStateLabelInput
                            , onEnterKey ConfirmStateModal
                            , style "width" "100%"
                            , style "padding" "4px 6px"
                            , style "border" ("1px solid " ++ theme.inputBorder)
                            , style "border-radius" "3px"
                            , style "font-size" "13px"
                            , style "margin-bottom" "8px"
                            , style "box-sizing" "border-box"
                            , style "background-color" theme.inputBg
                            , style "color" theme.inputText
                            ]
                            []
                        , div
                            [ style "display" "flex"
                            , style "align-items" "center"
                            , style "gap" "6px"
                            , style "margin-bottom" "6px"
                            ]
                            [ input
                                [ type_ "checkbox"
                                , Html.Attributes.id "modal-start-cb"
                                , checked model.stateModalIsStart
                                , onCheck SetStateModalIsStart
                                ]
                                []
                            , label [ Html.Attributes.for "modal-start-cb", style "font-size" "13px", style "cursor" "pointer", style "color" theme.textPrimary ]
                                [ text t.editorStartStateCheckbox ]
                            ]
                        , div
                            [ style "display" "flex"
                            , style "align-items" "center"
                            , style "gap" "6px"
                            , style "margin-bottom" "10px"
                            ]
                            [ input
                                [ type_ "checkbox"
                                , Html.Attributes.id "modal-end-cb"
                                , checked model.stateModalIsEnd
                                , onCheck SetStateModalIsEnd
                                ]
                                []
                            , label [ Html.Attributes.for "modal-end-cb", style "font-size" "13px", style "cursor" "pointer", style "color" theme.textPrimary ]
                                [ text t.editorEndStateCheckbox ]
                            ]
                        , if String.length model.stateLabelInput * 8 > 60 then
                            div
                                [ style "display" "flex"
                                , style "align-items" "center"
                                , style "gap" "6px"
                                , style "margin-bottom" "10px"
                                ]
                                [ input
                                    [ type_ "checkbox"
                                    , Html.Attributes.id "modal-compact-cb"
                                    , checked model.stateModalIsCompact
                                    , onCheck SetStateModalIsCompact
                                    ]
                                    []
                                , label [ Html.Attributes.for "modal-compact-cb", style "font-size" "13px", style "cursor" "pointer", style "color" theme.textPrimary ]
                                    [ text t.editorCompactStateCheckbox ]
                                ]
                          else
                            div [] []
                        , div
                            [ style "display" "flex"
                            , style "gap" "8px"
                            ]
                            [ button
                                [ onClick ConfirmStateModal
                                , style "flex" "1"
                                , style "padding" "6px"
                                , style "background-color" theme.btnAutoRunActive
                                , style "color" theme.textOnDark
                                , style "border" "none"
                                , style "border-radius" "4px"
                                , style "cursor" "pointer"
                                , style "font-size" "13px"
                                , style "font-weight" "bold"
                                ]
                                [ text t.ok ]
                            , button
                                [ onClick DismissStateModal
                                , style "flex" "1"
                                , style "padding" "6px"
                                , style "background-color" theme.btnDelete
                                , style "color" theme.textOnDark
                                , style "border" "none"
                                , style "border-radius" "4px"
                                , style "cursor" "pointer"
                                , style "font-size" "13px"
                                ]
                                [ text t.cancel ]
                            ]
                        ]
                Nothing ->
                    div [] []
        Nothing ->
            div [] []


viewLoadModal : Theme.Theme -> Translations.Translations -> Model -> Html Msg
viewLoadModal theme t model =
    if model.showLoadModal then
        div
            [ style "position" "fixed"
            , style "top" "0"
            , style "left" "0"
            , style "width" "100%"
            , style "height" "100%"
            , style "background-color" theme.overlayDark50
            , style "z-index" "2000"
            , style "display" "flex"
            , style "align-items" "center"
            , style "justify-content" "center"
            ]
            [ div
                [ style "background" theme.modalBg
                , style "padding" "24px"
                , style "border-radius" "8px"
                , style "display" "flex"
                , style "flex-direction" "column"
                , style "gap" "10px"
                , style "min-width" "280px"
                , style "max-height" "70vh"
                , style "overflow-y" "auto"
                ]
                ([ div [ style "font-weight" "bold", style "font-size" "16px", style "margin-bottom" "4px", style "color" theme.textPrimary ]
                    [ text t.editorLoadAutomatonTitle ]
                ]
                ++ List.map
                    (\entry ->
                        div
                            [ style "display" "flex"
                            , style "align-items" "center"
                            , style "justify-content" "space-between"
                            , style "gap" "8px"
                            , style "padding" "8px 0"
                            ]
                            [ div [ style "font-size" "14px", style "flex" "1", style "color" theme.textPrimary ] [ text entry.name ]
                            , button
                                [ onClick (SelectStoredAutomaton entry.name)
                                , Html.Attributes.class "elm-btn"
                                , style "padding" "6px 14px"
                                , style "background-color" theme.btnSecondaryBg
                                , style "color" theme.textOnDark
                                , style "border" "none"
                                , style "border-radius" "5px"
                                , style "cursor" "pointer"
                                , style "font-size" "13px"
                                ]
                                [ text t.load ]
                            , button
                                [ onClick (DeleteStoredAutomaton entry.name)
                                , Html.Attributes.class "elm-btn"
                                , style "padding" "6px 14px"
                                , style "background-color" theme.btnDelete
                                , style "color" theme.textOnDark
                                , style "border" "none"
                                , style "border-radius" "5px"
                                , style "cursor" "pointer"
                                , style "font-size" "13px"
                                ]
                                [ text t.deleteStored ]
                            ]
                    )
                    model.storedAutomata
                ++ [ button
                        [ onClick ImportJsonRequested
                        , Html.Attributes.class "elm-btn"
                        , style "padding" "10px"
                        , style "background-color" theme.btnSecondaryBg
                        , style "color" theme.textOnDark
                        , style "border" "none"
                        , style "border-radius" "5px"
                        , style "cursor" "pointer"
                        , style "font-size" "14px"
                        , style "margin-top" "8px"
                        ]
                            [ text t.editorLoadFromJson ]
                   , button
                        [ onClick DismissLoadModal
                        , Html.Attributes.class "elm-btn"
                        , style "padding" "8px"
                        , style "background-color" theme.btnDelete
                        , style "color" theme.textOnDark
                        , style "border" "none"
                        , style "border-radius" "5px"
                        , style "cursor" "pointer"
                        , style "font-size" "13px"
                        ]
                        [ text t.cancel ]
                   ]
                )
            ]
    else
        div [] []


viewSaveModal : Theme.Theme -> Translations.Translations -> Model -> Html Msg
viewSaveModal theme t model =
    if model.showSaveModal then
        div
            [ style "position" "fixed"
            , style "top" "0"
            , style "left" "0"
            , style "width" "100%"
            , style "height" "100%"
            , style "background-color" theme.overlayDark50
            , style "z-index" "2000"
            , style "display" "flex"
            , style "align-items" "center"
            , style "justify-content" "center"
            ]
            [ div
                [ style "background" theme.modalBg
                , style "padding" "24px"
                , style "border-radius" "8px"
                , style "display" "flex"
                , style "flex-direction" "column"
                , style "gap" "12px"
                , style "min-width" "260px"
                ]
                [ div [ style "font-weight" "bold", style "font-size" "16px", style "color" theme.textPrimary ]
                    [ text t.editorSaveAutomatonTitle ]
                , input
                    [ type_ "text"
                    , placeholder t.editorAutomatonNamePlaceholder
                    , value model.saveNameInput
                    , onInput UpdateSaveNameInput
                    , autofocus True
                    , onEnterKey ConfirmSave
                    , style "padding" "8px"
                    , style "border" ("1px solid " ++ theme.inputBorder)
                    , style "border-radius" "5px"
                    , style "font-size" "14px"
                    , style "background-color" theme.inputBg
                    , style "color" theme.inputText
                    ]
                    []
                , button
                    [ onClick ConfirmSave
                    , Html.Attributes.class "elm-btn"
                    , style "padding" "10px"
                    , style "background-color" theme.btnSecondaryBg
                    , style "color" theme.textOnDark
                    , style "border" "none"
                    , style "border-radius" "5px"
                    , style "cursor" "pointer"
                    , style "font-size" "14px"
                    ]
                    [ text t.save ]
                , button
                    [ onClick DismissSaveModal
                    , Html.Attributes.class "elm-btn"
                    , style "padding" "8px"
                    , style "background-color" theme.btnDelete
                    , style "color" theme.textOnDark
                    , style "border" "none"
                    , style "border-radius" "5px"
                    , style "cursor" "pointer"
                    , style "font-size" "13px"
                    ]
                    [ text t.cancel ]
                ]
            ]
    else
        div [] []


