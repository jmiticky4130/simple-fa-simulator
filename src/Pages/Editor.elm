module Pages.Editor exposing (Model, Msg(..), Tool(..), init, initWith, update, view)

import Html exposing (Html, div, input, button, text, label, span)
import Html.Attributes exposing (style, placeholder, value, autofocus, type_, checked)
import Html.Events exposing (onInput, on, onClick, onCheck)
import Json.Decode as Decode
import Components.Toolbar as Toolbar
import Components.Canvas as Canvas
import Components.Console as Console
import Components.AutomatonDisplay as AutomatonDisplay
import UndoList exposing (UndoList)
import Shared exposing (State, Transition, AutomatonState)
import Utils.AutomatonHelpers exposing
    ( getStateById
    , transitionExists
    , updateStatePosition
    , updateStateLabel
    , setStartState
    , toggleEndState
    , updateTransitionSymbol
    , isDFA
    )
import Browser.Dom
import Task
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
    }


type Msg
    = ChangeTool Tool
    | CanvasClick Float Float
    | CanvasDoubleClick Float Float
    | StateClick Int
    | StateDoubleClick Int
    | TransitionClick Int Int String
    | TransitionDoubleClick Int Int String
    | StartDrag Int Float Float
    | DragMove Float Float
    | EndDrag
    | DeleteState Int
    | DeleteTransition Int Int String
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
    | ResetAutomaton
    | Undo
    | Redo
    | CancelAction
    | NoOp
    | SwitchToSimulator
    | CanvasMouseDown Float Float
    | ZoomIn
    | ZoomOut
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
    | ShowGuide
    | ShowError String
    | ToggleConsole


init : Model
init =
    { automaton = UndoList.fresh { states = [], transitions = [], nextStateId = 0 }
    , currentTool = BuildTool
    , selectedState = Nothing
    , transitionFrom = Nothing
    , consoleMessages = [ { text = "Vitajte v simulátore DFA/NFA. Dvojklikom na plátno pridajte stav.", msgType = Console.Info } ]
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
    }


initWith : Maybe AutomatonState -> Model
initWith maybeAutomaton =
    case maybeAutomaton of
        Nothing ->
            init

        Just automaton ->
            { init
                | automaton = UndoList.fresh automaton
                , consoleMessages = [ { text = "Automat načítaný z URL.", msgType = Console.Info } ]
            }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        currentAutomaton = model.automaton.present
    in
    case msg of
        SwitchToSimulator ->
            ( model, Cmd.none )

        SwitchToConversion ->
            ( model, Cmd.none )

        ToggleConsole ->
            ( model, Cmd.none )

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
                        , consoleMessages = { text = "Automat importovaný zo súboru.", msgType = Console.Info } :: model.consoleMessages
                      }
                    , Cmd.none
                    )

                Err err ->
                    ( { model
                        | consoleMessages = { text = "Chyba importu: " ++ Decode.errorToString err, msgType = Console.Error } :: model.consoleMessages
                      }
                    , Cmd.none
                    )

        ShareUrl ->
            ( { model | consoleMessages = { text = "URL skopírovaná do schránky.", msgType = Console.Info } :: model.consoleMessages }
            , Cmd.none
            )

        SaveRequested ->
            ( { model | showSaveModal = True, saveNameInput = "" }, Cmd.none )

        UpdateSaveNameInput s ->
            ( { model | saveNameInput = s }, Cmd.none )

        ConfirmSave ->
            if String.isEmpty (String.trim model.saveNameInput) then
                ( { model | consoleMessages = { text = "Zadajte názov automatu.", msgType = Console.Error } :: model.consoleMessages }
                , Cmd.none
                )
            else
                ( { model
                    | showSaveModal = False
                    , saveNameInput = ""
                    , consoleMessages = { text = "Automat uložený: " ++ model.saveNameInput, msgType = Console.Info } :: model.consoleMessages
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
                                , consoleMessages = { text = "Automat načítaný: " ++ name, msgType = Console.Info } :: model.consoleMessages
                              }
                            , Cmd.none
                            )

                        Err err ->
                            ( { model
                                | showLoadModal = False
                                , consoleMessages = { text = "Chyba: " ++ Decode.errorToString err, msgType = Console.Error } :: model.consoleMessages
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
                , consoleMessages = { text = "Akcia zrušená.", msgType = Console.Info } :: model.consoleMessages
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
                , consoleMessages = { text = getToolMessage newTool, msgType = Console.Info } :: model.consoleMessages
              }
            , Cmd.none
            )

        CanvasDoubleClick x y ->
            case model.currentTool of
                BuildTool ->
                    let
                        worldX = (x - model.panX) / model.zoom
                        worldY = (y - model.panY) / model.zoom
                        newState =
                            { id = currentAutomaton.nextStateId
                            , x = worldX
                            , y = worldY
                            , label = "q" ++ String.fromInt currentAutomaton.nextStateId
                            , isStart = False
                            , isEnd = False
                            }
                        message = "Pridaný stav: " ++ newState.label
                        newAutomaton =
                            { currentAutomaton
                            | states = currentAutomaton.states ++ [ newState ]
                            , nextStateId = currentAutomaton.nextStateId + 1
                            }
                    in
                    ( { model
                        | automaton = UndoList.new newAutomaton model.automaton
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
                                , isDragging = False
                              }
                            , Task.attempt (\_ -> NoOp) (Browser.Dom.focus "state-modal-input")
                            )
                        Nothing ->
                            ( model, Cmd.none )

                DeleteTool ->
                    ( model, Cmd.none )

        TransitionDoubleClick from to symbol ->
            case model.currentTool of
                BuildTool ->
                    let
                        fromState = getStateById from currentAutomaton.states
                        toState = getStateById to currentAutomaton.states
                        ( inputX, inputY ) =
                            case ( fromState, toState ) of
                                ( Just fs, Just ts ) ->
                                    if from == to then
                                        ( fs.x, fs.y - 80 )
                                    else
                                        ( (fs.x + ts.x) / 2, (fs.y + ts.y) / 2 )
                                _ ->
                                    ( 400, 300 )
                    in
                    ( { model
                        | editingTransition = Just { from = from, to = to, x = inputX, y = inputY }
                        , editingTransitionOldSymbol = Just symbol
                        , transitionInput = symbol
                        , consoleMessages = { text = "Upravte symbol prechodu.", msgType = Console.Info } :: model.consoleMessages
                      }
                    , Task.attempt (\_ -> NoOp) (Browser.Dom.focus "transition-input")
                    )

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
                case model.draggedState of
                    Just stateId ->
                        let
                            worldX = (x - model.panX) / model.zoom
                            worldY = (y - model.panY) / model.zoom
                            dx = worldX - model.dragStartX
                            dy = worldY - model.dragStartY
                            dist = sqrt (dx * dx + dy * dy)
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
            ( { model | draggedState = Nothing, isPanning = False }, Cmd.none )

        DeleteState stateId ->
            let
                state = getStateById stateId currentAutomaton.states
                label = Maybe.map .label state |> Maybe.withDefault ""
                message = "Odstránený stav: " ++ label
                newAutomaton =
                    { currentAutomaton
                    | states = List.filter (\s -> s.id /= stateId) currentAutomaton.states
                    , transitions = List.filter (\t -> t.from /= stateId && t.to /= stateId) currentAutomaton.transitions
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
                message = "Odstránený prechod: " ++ symbol
                newAutomaton =
                    { currentAutomaton
                    | transitions = List.filter (\t -> not (t.from == from && t.to == to && t.symbol == symbol)) currentAutomaton.transitions
                    }
            in
            ( { model
                | automaton = UndoList.new newAutomaton model.automaton
                , consoleMessages = { text = message, msgType = Console.Info } :: model.consoleMessages
              }
            , Cmd.none
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
                            , consoleMessages = { text = "Prázdny názov nie je povolený.", msgType = Console.Error } :: model.consoleMessages
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
                                | consoleMessages = { text = "Stav s názvom '" ++ newLabel ++ "' už existuje.", msgType = Console.Error } :: model.consoleMessages
                              }
                            , Cmd.none
                            )
                        else
                            let
                                message = "Stav premenovaný na: " ++ newLabel
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
                        ( { model | consoleMessages = { text = "Prázdny názov nie je povolený.", msgType = Console.Error } :: model.consoleMessages }
                        , Cmd.none
                        )
                    else
                        let
                            newLabel = String.trim model.stateLabelInput
                            isDuplicate = List.any (\s -> s.label == newLabel && s.id /= stateId) currentAutomaton.states
                        in
                        if isDuplicate then
                            ( { model | consoleMessages = { text = "Stav s názvom '" ++ newLabel ++ "' už existuje.", msgType = Console.Error } :: model.consoleMessages }
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
                                newAutomaton = { currentAutomaton | states = statesWithEnd }
                                message = "Stav upravený: " ++ newLabel
                            in
                            ( { model
                                | automaton = UndoList.new newAutomaton model.automaton
                                , editingStateId = Nothing
                                , stateLabelInput = ""
                                , stateModalIsStart = False
                                , stateModalIsEnd = False
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
              }
            , Cmd.none
            )

        SetStateModalIsStart val ->
            ( { model | stateModalIsStart = val }, Cmd.none )

        SetStateModalIsEnd val ->
            ( { model | stateModalIsEnd = val }, Cmd.none )

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
                , consoleMessages = { text = "Automat bol resetovaný.", msgType = Console.Info } :: model.consoleMessages
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
            ( { model | transitionInput = inputVal }, Cmd.none )

        ConfirmTransitionSymbol ->
            case model.editingTransition of
                Just { from, to } ->
                    case model.editingTransitionOldSymbol of
                        Just oldSymbol ->
                            -- Edit mode: replace old transition(s) with new
                            let
                                newInput = String.trim model.transitionInput
                                newSymbol = if String.isEmpty newInput then "ε" else newInput
                                -- Remove old transition
                                filteredTransitions =
                                    List.filter (\t -> not (t.from == from && t.to == to && t.symbol == oldSymbol)) currentAutomaton.transitions
                                -- Check duplicate
                                isDuplicate = List.any (\t -> t.from == from && t.to == to && t.symbol == newSymbol) filteredTransitions
                            in
                            if from == to && newSymbol == "ε" then
                                ( { model | consoleMessages = { text = "Slučka nemôže byť ε-prechodom.", msgType = Console.Error } :: model.consoleMessages }
                                , Cmd.none
                                )
                            else if symbolHasSpaces newSymbol && newSymbol /= "ε" then
                                ( { model | consoleMessages = { text = "Symbol nemôže obsahovať medzery.", msgType = Console.Error } :: model.consoleMessages }
                                , Cmd.none
                                )
                            else if isDuplicate then
                                ( { model | consoleMessages = { text = "Prechod '" ++ newSymbol ++ "' už existuje.", msgType = Console.Error } :: model.consoleMessages }
                                , Cmd.none
                                )
                            else
                                let
                                    newTransitions = filteredTransitions ++ [ { from = from, to = to, symbol = newSymbol } ]
                                    newAutomaton = { currentAutomaton | transitions = newTransitions }
                                    message = "Prechod zmenený na: " ++ newSymbol
                                in
                                ( { model
                                    | automaton = UndoList.new newAutomaton model.automaton
                                    , editingTransition = Nothing
                                    , editingTransitionOldSymbol = Nothing
                                    , transitionInput = ""
                                    , transitionFrom = Nothing
                                    , consoleMessages = { text = message, msgType = Console.Info } :: model.consoleMessages
                                  }
                                , Cmd.none
                                )

                        Nothing ->
                            -- Create mode: existing behavior
                            if String.isEmpty (String.trim model.transitionInput) then
                                if from == to then
                                    ( { model | consoleMessages = { text = "Slučka nemôže byť ε-prechodom.", msgType = Console.Error } :: model.consoleMessages }
                                    , Cmd.none
                                    )
                                else if transitionExists from to "ε" currentAutomaton.transitions then
                                    ( { model
                                        | consoleMessages = { text = "ε-prechod už existuje.", msgType = Console.Error } :: model.consoleMessages
                                      }
                                    , Cmd.none
                                    )

                                else
                                    let
                                        newAutomaton =
                                            { currentAutomaton | transitions = currentAutomaton.transitions ++ [ { from = from, to = to, symbol = "ε" } ] }
                                    in
                                    ( { model
                                        | automaton = UndoList.new newAutomaton model.automaton
                                        , editingTransition = Nothing
                                        , transitionInput = ""
                                        , transitionFrom = Nothing
                                        , consoleMessages = { text = "Pridaný ε-prechod.", msgType = Console.Info } :: model.consoleMessages
                                      }
                                    , Cmd.none
                                    )

                            else
                                let
                                    rawSymbols =
                                        String.split "," model.transitionInput
                                            |> List.map String.trim
                                            |> List.filter (not << String.isEmpty)

                                    symbolsWithSpaces =
                                        List.filter symbolHasSpaces rawSymbols

                                    symbols =
                                        Set.fromList rawSymbols
                                            |> Set.toList
                                            |> List.sort

                                    duplicates =
                                        List.filter (\sym -> transitionExists from to sym currentAutomaton.transitions) symbols

                                    uniqueSymbols =
                                        List.filter (\sym -> not (transitionExists from to sym currentAutomaton.transitions)) symbols
                                in
                                if not (List.isEmpty symbolsWithSpaces) then
                                    ( { model | consoleMessages = { text = "Symbol nemôže obsahovať medzery: " ++ String.join ", " symbolsWithSpaces, msgType = Console.Error } :: model.consoleMessages }
                                    , Cmd.none
                                    )
                                else if from == to && List.member "ε" symbols then
                                    ( { model | consoleMessages = { text = "Slučka nemôže byť ε-prechodom.", msgType = Console.Error } :: model.consoleMessages }
                                    , Cmd.none
                                    )
                                else if not (List.isEmpty duplicates) then
                                    let
                                        errorMsg = "Prechod(y) už existujú: " ++ String.join ", " duplicates
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
                                                    acc ++ [ { from = from, to = to, symbol = symbol } ]
                                                )
                                                currentAutomaton.transitions
                                                uniqueSymbols

                                        addedCount =
                                            List.length newTransitions - List.length currentAutomaton.transitions

                                        message =
                                            if addedCount == 0 then
                                                "Všetky prechody už existujú."
                                            else if addedCount == 1 then
                                                "Pridaný prechod: " ++ String.join ", " uniqueSymbols
                                            else
                                                "Pridaných " ++ String.fromInt addedCount ++ " prechodov."

                                        newAutomaton = { currentAutomaton | transitions = newTransitions }
                                    in
                                    ( { model
                                        | automaton = UndoList.new newAutomaton model.automaton
                                        , editingTransition = Nothing
                                        , transitionInput = ""
                                        , transitionFrom = Nothing
                                        , consoleMessages = { text = message, msgType = Console.Info } :: model.consoleMessages
                                      }
                                    , Cmd.none
                                    )

                Nothing ->
                    ( model, Cmd.none )

        TransitionClick from to symbol ->
            if model.currentTool == DeleteTool then
                let
                    message = "Odstránený prechod: " ++ symbol
                    newAutomaton =
                        { currentAutomaton
                        | transitions = List.filter (\t -> not (t.from == from && t.to == to && t.symbol == symbol)) currentAutomaton.transitions
                        }
                in
                ( { model
                    | automaton = UndoList.new newAutomaton model.automaton
                    , consoleMessages = { text = message, msgType = Console.Info } :: model.consoleMessages
                  }
                , Cmd.none
                )
            else
                ( model, Cmd.none )

        CanvasMouseDown x y ->
            ( { model | isPanning = True, panLastX = x, panLastY = y, hasPanned = False }, Cmd.none )

        ZoomIn ->
            ( { model | zoom = min 3.0 (model.zoom * 1.2) }, Cmd.none )

        ZoomOut ->
            ( { model | zoom = max 0.2 (model.zoom / 1.2) }, Cmd.none )

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

        ShowError text ->
            ( { model | consoleMessages = { text = text, msgType = Console.Error } :: model.consoleMessages }
            , Cmd.none
            )


symbolHasSpaces : String -> Bool
symbolHasSpaces symbol =
    String.contains " " symbol


handleStateClick : Int -> Model -> ( Model, Cmd Msg )
handleStateClick stateId model =
    let
        currentAutomaton = model.automaton.present
    in
    case model.currentTool of
        DeleteTool ->
            let
                state = getStateById stateId currentAutomaton.states
                label = Maybe.map .label state |> Maybe.withDefault ""
                message = "Odstránený stav: " ++ label
                newAutomaton =
                    { currentAutomaton
                    | states = List.filter (\s -> s.id /= stateId) currentAutomaton.states
                    , transitions = List.filter (\t -> t.from /= stateId && t.to /= stateId) currentAutomaton.transitions
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
                            , consoleMessages = { text = "Vyberte cieľový stav pre prechod.", msgType = Console.Info } :: model.consoleMessages
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
                                            ( fs.x, fs.y - 80 )
                                        else
                                            ( (fs.x + ts.x) / 2, (fs.y + ts.y) / 2 )
                                    _ ->
                                        ( 400, 300 )
                        in
                        ( { model
                            | editingTransition = Just { from = fromId, to = stateId, x = inputX, y = inputY }
                            , editingTransitionOldSymbol = Nothing
                            , transitionInput = ""
                            , consoleMessages = { text = "Zadajte symbol(y) pre prechod (oddeľte čiarkou).", msgType = Console.Info } :: model.consoleMessages
                          }
                        , Task.attempt (\_ -> NoOp) (Browser.Dom.focus "transition-input")
                        )


getToolMessage : Tool -> String
getToolMessage tool =
    case tool of
        BuildTool ->
            "Nástroj: Stavať - dvojklik=nový stav, klik na stav=prechod, dvojklik na stav=upraviť"

        DeleteTool ->
            "Nástroj: Odstrániť - kliknite na stav alebo prechod"


toolToString : Tool -> String
toolToString tool =
    case tool of
        BuildTool ->
            "BuildTool"

        DeleteTool ->
            "DeleteTool"


view : Bool -> Model -> Html Msg
view consoleOpen model =
    let
        { states, transitions } = model.automaton.present
        hasStart = List.any .isStart states
        hasEnd = List.any .isEnd states
        isSimulateEnabled = not (List.isEmpty states) && hasStart && hasEnd
        isConvertEnabled = not (List.isEmpty states) && hasStart && hasEnd && not (isDFA states transitions)
        simulateDisabledReason =
            if List.isEmpty states then
                Just "Pridajte aspoň jeden stav."
            else if not hasStart then
                Just "Nastavte počiatočný stav."
            else if not hasEnd then
                Just "Nastavte aspoň jeden koncový stav."
            else
                Nothing
        convertDisabledReason =
            if List.isEmpty states then
                Just "Pridajte aspoň jeden stav."
            else if not hasStart then
                Just "Nastavte počiatočný stav."
            else if not hasEnd then
                Just "Nastavte aspoň jeden koncový stav."
            else if isDFA states transitions then
                Just "Preveďte NFA (musí obsahovať ε-prechody alebo viacero prechodov na rovnakej abecede)."
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
                , onShowGuide = ShowGuide
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
              div
                [ style "flex" "1"
                , style "overflow" "hidden"
                , style "background-color" "#ecf0f1"
                , style "user-select" "none"
                ]
                [ Canvas.view
                    { states = states
                    , transitions = transitions
                    , selectedState = model.selectedState
                    , transitionFrom = model.transitionFrom
                    , transitionTo = Maybe.map .to model.editingTransition
                    , activeStateId = Nothing
                    , activeStateVerdict = Nothing
                    , activeTransition = Nothing
                    , onCanvasClick = CanvasClick
                    , onCanvasDoubleClick = CanvasDoubleClick
                    , onStateClick = StateClick
                    , onStateDoubleClick = StateDoubleClick
                    , onTransitionClick = TransitionClick
                    , onTransitionDoubleClick = TransitionDoubleClick
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
                    }
                ]
            , div
                [ style "width" "300px"
                , style "flex-shrink" "0"
                , style "background-color" "#f8f9fa"
                , style "border-left" "2px solid #34495e"
                , style "display" "flex"
                , style "flex-direction" "column"
                , style "overflow" "hidden"
                ]
                [ AutomatonDisplay.view
                    { states = states
                    , transitions = transitions
                    }
                ]
            ]
        ,
          Console.view
            { messages = model.consoleMessages
            , isOpen = consoleOpen
            , onToggle = ToggleConsole
            }
        ,
          viewInlineTransitionInput model
        ,
          viewStateModal model
        ,
          viewLoadModal model
        ,
          viewSaveModal model
        ]


viewInlineTransitionInput : Model -> Html Msg
viewInlineTransitionInput model =
    case model.editingTransition of
        Just { x, y } ->
            let
                screenX = x * model.zoom + model.panX
                screenY = y * model.zoom + model.panY
            in
            div
                [ style "position" "absolute"
                , style "left" (String.fromFloat (screenX - 75) ++ "px")
                , style "top" (String.fromFloat (screenY - 60) ++ "px")
                , style "z-index" "1000"
                , style "background-color" "white"
                , style "border" "2px solid #3498db"
                , style "border-radius" "4px"
                , style "padding" "8px"
                , style "box-shadow" "0 2px 8px rgba(0,0,0,0.2)"
                ]
                [ div
                    [ style "font-size" "11px"
                    , style "color" "#666"
                    , style "margin-bottom" "4px"
                    , style "white-space" "nowrap"
                    ]
                    [ text (case model.editingTransitionOldSymbol of
                        Just _ -> "Upraviť symbol:"
                        Nothing -> "Symbol(y): a,b,ε (prázdny=ε)")
                    ]
                , input
                    [ type_ "text"
                    , Html.Attributes.id "transition-input"
                    , placeholder "a,b,ε"
                    , value model.transitionInput
                    , onInput UpdateTransitionInput
                    , autofocus True
                    , onEnterKey ConfirmTransitionSymbol
                    , style "width" "130px"
                    , style "padding" "4px 6px"
                    , style "border" "1px solid #ccc"
                    , style "border-radius" "3px"
                    , style "font-size" "13px"
                    ]
                    []
                ]

        Nothing ->
            div [] []


viewStateModal : Model -> Html Msg
viewStateModal model =
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
                    in
                    div
                        [ style "position" "absolute"
                        , style "left" (String.fromFloat (screenX - 110) ++ "px")
                        , style "top" (String.fromFloat (screenY - 160) ++ "px")
                        , style "z-index" "1000"
                        , style "background-color" "white"
                        , style "border" "2px solid #3498db"
                        , style "border-radius" "6px"
                        , style "padding" "12px"
                        , style "box-shadow" "0 4px 12px rgba(0,0,0,0.25)"
                        , style "min-width" "220px"
                        ]
                        [ div
                            [ style "font-weight" "bold"
                            , style "font-size" "13px"
                            , style "margin-bottom" "8px"
                            , style "color" "#333"
                            ]
                            [ text "Upraviť stav" ]
                        , input
                            [ type_ "text"
                            , Html.Attributes.id "state-modal-input"
                            , placeholder "Názov stavu"
                            , value model.stateLabelInput
                            , onInput UpdateStateLabelInput
                            , onEnterKey ConfirmStateModal
                            , style "width" "100%"
                            , style "padding" "4px 6px"
                            , style "border" "1px solid #ccc"
                            , style "border-radius" "3px"
                            , style "font-size" "13px"
                            , style "margin-bottom" "8px"
                            , style "box-sizing" "border-box"
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
                            , label [ Html.Attributes.for "modal-start-cb", style "font-size" "13px", style "cursor" "pointer" ]
                                [ text "Počiatočný stav" ]
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
                            , label [ Html.Attributes.for "modal-end-cb", style "font-size" "13px", style "cursor" "pointer" ]
                                [ text "Koncový stav" ]
                            ]
                        , div
                            [ style "display" "flex"
                            , style "gap" "8px"
                            ]
                            [ button
                                [ onClick ConfirmStateModal
                                , style "flex" "1"
                                , style "padding" "6px"
                                , style "background-color" "#00897b"
                                , style "color" "white"
                                , style "border" "none"
                                , style "border-radius" "4px"
                                , style "cursor" "pointer"
                                , style "font-size" "13px"
                                , style "font-weight" "bold"
                                ]
                                [ text "OK" ]
                            , button
                                [ onClick DismissStateModal
                                , style "flex" "1"
                                , style "padding" "6px"
                                , style "background-color" "#c62828"
                                , style "color" "white"
                                , style "border" "none"
                                , style "border-radius" "4px"
                                , style "cursor" "pointer"
                                , style "font-size" "13px"
                                ]
                                [ text "Zrušiť" ]
                            ]
                        ]
                Nothing ->
                    div [] []
        Nothing ->
            div [] []


viewLoadModal : Model -> Html Msg
viewLoadModal model =
    if model.showLoadModal then
        div
            [ style "position" "fixed"
            , style "top" "0"
            , style "left" "0"
            , style "width" "100%"
            , style "height" "100%"
            , style "background-color" "rgba(0,0,0,0.5)"
            , style "z-index" "2000"
            , style "display" "flex"
            , style "align-items" "center"
            , style "justify-content" "center"
            ]
            [ div
                [ style "background" "white"
                , style "padding" "24px"
                , style "border-radius" "8px"
                , style "display" "flex"
                , style "flex-direction" "column"
                , style "gap" "10px"
                , style "min-width" "280px"
                , style "max-height" "70vh"
                , style "overflow-y" "auto"
                ]
                ([ div [ style "font-weight" "bold", style "font-size" "16px", style "margin-bottom" "4px" ]
                    [ text "Načítať automat" ]
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
                            [ div [ style "font-size" "14px", style "flex" "1" ] [ text entry.name ]
                            , button
                                [ onClick (SelectStoredAutomaton entry.name)
                                , Html.Attributes.class "elm-btn"
                                , style "padding" "6px 14px"
                                , style "background-color" "#546e7a"
                                , style "color" "white"
                                , style "border" "none"
                                , style "border-radius" "5px"
                                , style "cursor" "pointer"
                                , style "font-size" "13px"
                                ]
                                [ text "Načítať" ]
                            , button
                                [ onClick (DeleteStoredAutomaton entry.name)
                                , Html.Attributes.class "elm-btn"
                                , style "padding" "6px 14px"
                                , style "background-color" "#c62828"
                                , style "color" "white"
                                , style "border" "none"
                                , style "border-radius" "5px"
                                , style "cursor" "pointer"
                                , style "font-size" "13px"
                                ]
                                [ text "Vymazať" ]
                            ]
                    )
                    model.storedAutomata
                ++ [ button
                        [ onClick ImportJsonRequested
                        , Html.Attributes.class "elm-btn"
                        , style "padding" "10px"
                        , style "background-color" "#546e7a"
                        , style "color" "white"
                        , style "border" "none"
                        , style "border-radius" "5px"
                        , style "cursor" "pointer"
                        , style "font-size" "14px"
                        , style "margin-top" "8px"
                        ]
                        [ text "Načítať zo súboru .json" ]
                   , button
                        [ onClick DismissLoadModal
                        , Html.Attributes.class "elm-btn"
                        , style "padding" "8px"
                        , style "background-color" "#c62828"
                        , style "color" "white"
                        , style "border" "none"
                        , style "border-radius" "5px"
                        , style "cursor" "pointer"
                        , style "font-size" "13px"
                        ]
                        [ text "Zrušiť" ]
                   ]
                )
            ]
    else
        div [] []


viewSaveModal : Model -> Html Msg
viewSaveModal model =
    if model.showSaveModal then
        div
            [ style "position" "fixed"
            , style "top" "0"
            , style "left" "0"
            , style "width" "100%"
            , style "height" "100%"
            , style "background-color" "rgba(0,0,0,0.5)"
            , style "z-index" "2000"
            , style "display" "flex"
            , style "align-items" "center"
            , style "justify-content" "center"
            ]
            [ div
                [ style "background" "white"
                , style "padding" "24px"
                , style "border-radius" "8px"
                , style "display" "flex"
                , style "flex-direction" "column"
                , style "gap" "12px"
                , style "min-width" "260px"
                ]
                [ div [ style "font-weight" "bold", style "font-size" "16px" ]
                    [ text "Uložiť automat" ]
                , input
                    [ type_ "text"
                    , placeholder "Názov automatu"
                    , value model.saveNameInput
                    , onInput UpdateSaveNameInput
                    , autofocus True
                    , onEnterKey ConfirmSave
                    , style "padding" "8px"
                    , style "border" "1px solid #ccc"
                    , style "border-radius" "5px"
                    , style "font-size" "14px"
                    ]
                    []
                , button
                    [ onClick ConfirmSave
                    , Html.Attributes.class "elm-btn"
                    , style "padding" "10px"
                    , style "background-color" "#546e7a"
                    , style "color" "white"
                    , style "border" "none"
                    , style "border-radius" "5px"
                    , style "cursor" "pointer"
                    , style "font-size" "14px"
                    ]
                    [ text "Uložiť" ]
                , button
                    [ onClick DismissSaveModal
                    , Html.Attributes.class "elm-btn"
                    , style "padding" "8px"
                    , style "background-color" "#c62828"
                    , style "color" "white"
                    , style "border" "none"
                    , style "border-radius" "5px"
                    , style "cursor" "pointer"
                    , style "font-size" "13px"
                    ]
                    [ text "Zrušiť" ]
                ]
            ]
    else
        div [] []


