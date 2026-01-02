module Pages.Editor exposing (Model, Msg(..), Tool(..), init, update, view)

import Html exposing (Html, div, input, button, text)
import Html.Attributes exposing (style, placeholder, value, autofocus, type_)
import Html.Events exposing (onInput, on, onClick)
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
    = ResetTool
    | AddStateTool
    | AddTransitionTool
    | DeleteTool
    | MoveTool
    | RenameTool
    | SetStartStateTool
    | SetEndStateTool


type alias Model =
    { automaton : UndoList AutomatonState
    , currentTool : Tool
    , selectedState : Maybe Int
    , transitionFrom : Maybe Int
    , consoleMessages : List Console.Message
    , isDragging : Bool
    , draggedState : Maybe Int
    , editingTransition : Maybe { from : Int, to : Int, x : Float, y : Float }
    , transitionInput : String
    , editingStateId : Maybe Int
    , stateLabelInput : String
    , transitionDisplayMode : AutomatonDisplay.TransitionDisplayMode
    }


type Msg
    = ChangeTool Tool
    | CanvasClick Float Float
    | StateClick Int
    | StartDrag Int Float Float
    | DragMove Float Float
    | EndDrag
    | DeleteState Int
    | DeleteTransition Int Int String
    | SetStateLabel Int String
    | SetTransitionSymbol Int Int String String
    | TransitionClick Int Int String
    | UpdateTransitionInput String
    | ConfirmTransitionSymbol
    | UpdateStateLabelInput String
    | ConfirmStateLabel
    | SetTransitionDisplayMode AutomatonDisplay.TransitionDisplayMode
    | ResetAutomaton
    | Undo
    | Redo
    | CancelAction
    | NoOp
    | SwitchToSimulator


init : Model
init =
    { automaton = UndoList.fresh { states = [], transitions = [], nextStateId = 0 }
    , currentTool = ResetTool
    , selectedState = Nothing
    , transitionFrom = Nothing
    , consoleMessages = [ { text = "Vítajte v simulátore DFA/NFA. Začnite pridaním stavov.", msgType = Console.Info } ]
    , isDragging = False
    , draggedState = Nothing
    , editingTransition = Nothing
    , transitionInput = ""
    , editingStateId = Nothing
    , stateLabelInput = ""
    , transitionDisplayMode = AutomatonDisplay.Table
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        currentAutomaton = model.automaton.present
    in
    case msg of
        SwitchToSimulator ->
            if isDFA currentAutomaton.states currentAutomaton.transitions then
                ( model, Cmd.none )
            else
                ( { model | consoleMessages = { text = "Automat nie je DFA (obsahuje nedeterministické prechody).", msgType = Console.Error } :: model.consoleMessages }
                , Cmd.none
                )

        Undo ->
            ( { model | automaton = UndoList.undo model.automaton }, Cmd.none )
        Redo ->
            ( { model | automaton = UndoList.redo model.automaton }, Cmd.none )

        CancelAction ->
            ( { model
                | editingTransition = Nothing
                , transitionInput = ""
                , transitionFrom = Nothing
                , editingStateId = Nothing
                , stateLabelInput = ""
                , consoleMessages = { text = "Akcia zrušená.", msgType = Console.Info } :: model.consoleMessages
              }
            , Cmd.none
            )

        ChangeTool tool ->
            let
                newTool =
                    if model.currentTool == tool then
                        ResetTool
                    else
                        tool
            in
            ( { model 
                | currentTool = newTool
                , transitionFrom = Nothing
                , consoleMessages = { text = getToolMessage newTool, msgType = Console.Info } :: model.consoleMessages
                , editingStateId = Nothing
                , stateLabelInput = ""
              }
            , Cmd.none
            )

        CanvasClick x y ->
            case model.currentTool of
                AddStateTool ->
                    let
                        newState =
                            { id = currentAutomaton.nextStateId
                            , x = x
                            , y = y
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

                _ ->
                    ( { model 
                        | selectedState = Nothing 
                        , editingStateId = Nothing
                        , stateLabelInput = ""
                        , editingTransition = Nothing
                        , transitionInput = ""
                      }
                    , Cmd.none
                    )

        StateClick stateId ->
            handleStateClick stateId model

        StartDrag stateId _ _ ->
            if model.currentTool == MoveTool then
                ( { model
                    | automaton = UndoList.new currentAutomaton model.automaton
                    , isDragging = True
                    , draggedState = Just stateId
                  }
                , Cmd.none
                )
            else
                ( model, Cmd.none )

        DragMove x y ->
            case model.draggedState of
                Just stateId ->
                    let
                        newStates = updateStatePosition stateId x y currentAutomaton.states
                        newAutomaton = { currentAutomaton | states = newStates }
                        undoList = model.automaton
                    in
                    ( { model
                        | automaton = { undoList | present = newAutomaton }
                      }
                    , Cmd.none
                    )

                Nothing ->
                    ( model, Cmd.none )

        EndDrag ->
            ( { model
                | isDragging = False
                , draggedState = Nothing
              }
            , Cmd.none
            )

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

        UpdateStateLabelInput input ->
            ( { model | stateLabelInput = input }, Cmd.none )

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

        SetTransitionDisplayMode mode ->
            ( { model | transitionDisplayMode = mode }, Cmd.none )

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
                , currentTool = ResetTool
                , selectedState = Nothing
                , transitionFrom = Nothing
                , consoleMessages = { text = "Automat bol resetovaný.", msgType = Console.Info } :: model.consoleMessages
                , isDragging = False
                , draggedState = Nothing
                , editingTransition = Nothing
                , transitionInput = ""
                , editingStateId = Nothing
                , stateLabelInput = ""
                , transitionDisplayMode = AutomatonDisplay.Table
              }
            , Cmd.none
            )

        UpdateTransitionInput input ->
            ( { model | transitionInput = input }, Cmd.none )

        ConfirmTransitionSymbol ->
            case model.editingTransition of
                Just { from, to } ->
                    if String.isEmpty (String.trim model.transitionInput) then
                        ( { model
                            | editingTransition = Nothing
                            , transitionInput = ""
                            , consoleMessages = { text = "Prázdny symbol nie je povolený.", msgType = Console.Error } :: model.consoleMessages
                          }
                        , Cmd.none
                        )
                    else
                        let
                            rawSymbols =
                                String.split "," model.transitionInput
                                    |> List.map String.trim
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
                        if not (List.isEmpty duplicates) then
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

        NoOp ->
            ( model, Cmd.none )


handleStateClick : Int -> Model -> ( Model, Cmd Msg )
handleStateClick stateId model =
    let
        currentAutomaton = model.automaton.present
    in
    case model.currentTool of
        ResetTool ->
            ( { model | selectedState = Just stateId }
            , Cmd.none
            )

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

        AddTransitionTool ->
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
                        (inputX, inputY) =
                            case (fromState, toState) of
                                (Just from, Just to) ->
                                    if fromId == stateId then
                                        (from.x, from.y - 80)
                                    else
                                        ((from.x + to.x) / 2, (from.y + to.y) / 2)
                                _ ->
                                    (400, 300)
                    in
                    ( { model
                        | editingTransition = Just { from = fromId, to = stateId, x = inputX, y = inputY }
                        , transitionInput = ""
                        , consoleMessages = { text = "Zadajte symbol(y) pre prechod (oddeľte čiarkou).", msgType = Console.Info } :: model.consoleMessages
                      }
                    , Task.attempt (\_ -> NoOp) (Browser.Dom.focus "transition-input")
                    )

        RenameTool ->
            let
                state = getStateById stateId currentAutomaton.states
                label = Maybe.map .label state |> Maybe.withDefault ""
            in
            ( { model
                | editingStateId = Just stateId
                , stateLabelInput = label
                , consoleMessages = { text = "Upravte názov stavu.", msgType = Console.Info } :: model.consoleMessages
              }
            , Task.attempt (\_ -> NoOp) (Browser.Dom.focus "state-input")
            )

        MoveTool ->
            ( model, Cmd.none )

        SetStartStateTool ->
            let
                message = "Nastavený počiatočný stav"
                newAutomaton = { currentAutomaton | states = setStartState stateId currentAutomaton.states }
            in
            ( { model
                | automaton = UndoList.new newAutomaton model.automaton
                , consoleMessages = { text = message, msgType = Console.Info } :: model.consoleMessages
              }
            , Cmd.none
            )

        SetEndStateTool ->
            let
                state = getStateById stateId currentAutomaton.states
                isCurrentlyEnd = Maybe.map .isEnd state |> Maybe.withDefault False
                message = if isCurrentlyEnd then "Odstránený koncový stav" else "Nastavený koncový stav"
                newAutomaton = { currentAutomaton | states = toggleEndState stateId currentAutomaton.states }
            in
            ( { model
                | automaton = UndoList.new newAutomaton model.automaton
                , consoleMessages = { text = message, msgType = Console.Info } :: model.consoleMessages
              }
            , Cmd.none
            )

        _ ->
            ( model, Cmd.none )


getToolMessage : Tool -> String
getToolMessage tool =
    case tool of
        ResetTool ->
            "Nástroj: Reset"

        AddStateTool ->
            "Nástroj: Pridať stav - kliknite na plátno"

        AddTransitionTool ->
            "Nástroj: Pridať prechod - kliknite na dva stavy"

        DeleteTool ->
            "Nástroj: Odstrániť - kliknite na stav alebo prechod"

        MoveTool ->
            "Nástroj: Posunúť - ťahajte stavy myšou"

        RenameTool ->
            "Nástroj: Premenovať - kliknite na stav"

        SetStartStateTool ->
            "Nástroj: Nastaviť počiatočný stav"

        SetEndStateTool ->
            "Nástroj: Nastaviť koncový stav"


toolToString : Tool -> String
toolToString tool =
    case tool of
        ResetTool ->
            "ResetTool"

        AddStateTool ->
            "AddStateTool"

        AddTransitionTool ->
            "AddTransitionTool"

        DeleteTool ->
            "DeleteTool"

        MoveTool ->
            "MoveTool"

        RenameTool ->
            "RenameTool"

        SetStartStateTool ->
            "SetStartStateTool"

        SetEndStateTool ->
            "SetEndStateTool"


view : Model -> Html Msg
view model =
    let
        { states, transitions } = model.automaton.present
        isSimulateEnabled = isDFA states transitions
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
                , onAddStateTool = ChangeTool AddStateTool
                , onAddTransitionTool = ChangeTool AddTransitionTool
                , onDeleteTool = ChangeTool DeleteTool
                , onMoveTool = ChangeTool MoveTool
                , onRenameTool = ChangeTool RenameTool
                , onSetStartStateTool = ChangeTool SetStartStateTool
                , onSetEndStateTool = ChangeTool SetEndStateTool
                , onUndo = Undo
                , onRedo = Redo
                , onSwitchToSimulator = SwitchToSimulator
                , canUndo = UndoList.hasPast model.automaton
                , canRedo = UndoList.hasFuture model.automaton
                , currentTool = toolToString model.currentTool
                , isSimulateEnabled = isSimulateEnabled
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
                ]
                [ Canvas.view
                    { states = states
                    , transitions = transitions
                    , selectedState = model.selectedState
                    , transitionFrom = model.transitionFrom
                    , activeStateId = Nothing
                    , activeTransition = Nothing
                    , onCanvasClick = CanvasClick
                    , onStateClick = StateClick
                    , onTransitionClick = TransitionClick
                    , onStartDrag = StartDrag
                    , onDragMove = DragMove
                    , onEndDrag = EndDrag
                    , width = 800
                    , height = 600
                    }
                ]
            ,
              AutomatonDisplay.view
                { states = states
                , transitions = transitions
                , displayMode = model.transitionDisplayMode
                , onModeChange = SetTransitionDisplayMode
                }
            ]
        ,
          Console.view
            { messages = model.consoleMessages
            }
        ,
          viewInlineTransitionInput model
        ,
          viewInlineStateInput model
        ]


viewInlineTransitionInput : Model -> Html Msg
viewInlineTransitionInput model =
    case model.editingTransition of
        Just { x, y } ->
            div
                [ style "position" "absolute"
                , style "left" (String.fromFloat (x - 75) ++ "px")
                , style "top" (String.fromFloat (y - 60) ++ "px")
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
                    [ text "Symbol(y): a,b,c" ]
                , input
                    [ type_ "text"
                    , Html.Attributes.id "transition-input"
                    , placeholder "a,b,c"
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


viewInlineStateInput : Model -> Html Msg
viewInlineStateInput model =
    case model.editingStateId of
        Just id ->
            let
                maybeState = List.filter (\s -> s.id == id) model.automaton.present.states |> List.head
            in
            case maybeState of
                Just state ->
                    div
                        [ style "position" "absolute"
                        , style "left" (String.fromFloat (state.x - 75) ++ "px")
                        , style "top" (String.fromFloat (state.y - 60) ++ "px")
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
                            [ text "Názov stavu:" ]
                        , input
                            [ type_ "text"
                            , Html.Attributes.id "state-input"
                            , placeholder "Názov"
                            , value model.stateLabelInput
                            , onInput UpdateStateLabelInput
                            , autofocus True
                            , onEnterKey ConfirmStateLabel
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
        Nothing ->
            div [] []
