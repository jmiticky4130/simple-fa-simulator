module Pages.Simulator exposing (Model, Msg(..), init, update, view)

import Html exposing (Html, div, button, text, input, span)
import Html.Attributes exposing (style, placeholder, value, disabled)
import Html.Events exposing (onClick, onInput)
import Shared exposing (AutomatonState, State, Transition)
import Components.Canvas as Canvas
import Components.Console as Console
import Components.SimulateToolbar as SimulateToolbar
import Components.SimulationStatus as SimulationStatus
import Utils.AutomatonHelpers exposing (getStateLabel, getStateById)

type alias Model =
    { automaton : AutomatonState
    , currentStateId : Maybe Int
    , inputString : String
    , remainingInput : String
    , history : List (Maybe Int, String)
    , consoleMessages : List Console.Message
    , activeTransition : Maybe { from : Int, to : Int, symbol : String }
    , verdict : Maybe { text : String, isAccepted : Bool }
    }


init : AutomatonState -> Model
init automaton =
    let
        startState =
            List.filter .isStart automaton.states |> List.head |> Maybe.map .id
    in
    { automaton = automaton
    , currentStateId = startState
    , inputString = ""
    , remainingInput = ""
    , history = []
    , consoleMessages = [ { text = "Simulátor pripravený. Zadajte vstupné slovo.", msgType = Console.Info } ]
    , activeTransition = Nothing
    , verdict = Nothing
    }

type Msg
    = StepForward
    | StepBackward
    | ResetSimulation
    | SwitchToEditor
    | SetInput String
    | CanvasClick Float Float
    | StateClick Int
    | TransitionClick Int Int String
    | StartDrag Int Float Float
    | DragMove Float Float
    | EndDrag


update : Msg -> Model -> Model
update msg model =
    case msg of
        SetInput str ->
            let
                startState =
                    List.filter .isStart model.automaton.states |> List.head |> Maybe.map .id
            in
            { model
                | inputString = str
                , remainingInput = str
                , currentStateId = startState
                , history = []
                , consoleMessages = [ { text = "Vstup nastavený: " ++ str, msgType = Console.Info } ]
                , activeTransition = Nothing
                , verdict = Nothing
            }

        StepForward ->
            case (model.currentStateId, String.uncons model.remainingInput) of
                (Just currentId, Just (char, rest)) ->
                    let
                        symbol = String.fromChar char
                        maybeTransition =
                            model.automaton.transitions
                                |> List.filter (\t -> t.from == currentId && t.symbol == symbol)
                                |> List.head
                    in
                    case maybeTransition of
                        Just t ->
                            let
                                nextStateId = t.to
                                nextRemaining = rest
                                isEnd = getStateById nextStateId model.automaton.states |> Maybe.map .isEnd |> Maybe.withDefault False
                                nextVerdict =
                                    if String.isEmpty nextRemaining then
                                        if isEnd then
                                            Just { text = "Slovo je akceptované", isAccepted = True }
                                        else
                                            Just { text = "Slovo nie je akceptované", isAccepted = False }
                                    else
                                        Nothing
                            in
                            { model
                                | currentStateId = Just nextStateId
                                , remainingInput = nextRemaining
                                , history = (model.currentStateId, model.remainingInput) :: model.history
                                , consoleMessages = { text = "Prechod cez '" ++ symbol ++ "' do stavu " ++ (getStateLabel nextStateId model.automaton.states), msgType = Console.Info } :: model.consoleMessages
                                , activeTransition = Just { from = t.from, to = t.to, symbol = t.symbol }
                                , verdict = nextVerdict
                            }

                        Nothing ->
                            { model
                                | consoleMessages = { text = "Chyba: Neexistuje prechod pre symbol '" ++ symbol ++ "'", msgType = Console.Error } :: model.consoleMessages
                                , verdict = Just { text = "Slovo nie je akceptované", isAccepted = False }
                                , activeTransition = Nothing
                            }

                (Just currentId, Nothing) ->
                    let
                        isEnd = getStateById currentId model.automaton.states |> Maybe.map .isEnd |> Maybe.withDefault False
                        v = if isEnd then Just { text = "Slovo je akceptované", isAccepted = True } else Just { text = "Slovo nie je akceptované", isAccepted = False }
                    in
                    { model
                        | consoleMessages = { text = "Koniec vstupu.", msgType = Console.Info } :: model.consoleMessages
                        , verdict = v
                    }

                (Nothing, _) ->
                    { model
                        | consoleMessages = { text = "Chyba: Nie je nastavený aktuálny stav.", msgType = Console.Error } :: model.consoleMessages
                    }

        StepBackward ->
            case model.history of
                (prevState, prevInput) :: restHistory ->
                    { model
                        | currentStateId = prevState
                        , remainingInput = prevInput
                        , history = restHistory
                        , consoleMessages = { text = "Krok späť.", msgType = Console.Info } :: model.consoleMessages
                        , activeTransition = Nothing
                        , verdict = Nothing
                    }

                [] ->
                    model

        ResetSimulation ->
            init model.automaton

        SwitchToEditor ->
            model

        _ ->
            model


view : Model -> Html Msg
view model =
    div
        [ style "display" "flex"
        , style "flex-direction" "column"
        , style "height" "100vh"
        , style "width" "100vw"
        , style "overflow" "hidden"
        ]
        [
          SimulateToolbar.view
            { onStepBackward = StepBackward
            , onStepForward = StepForward
            , onReset = ResetSimulation
            , onSwitchToEditor = SwitchToEditor
            , canStepBackward = not (List.isEmpty model.history)
            , canStepForward = not (String.isEmpty model.remainingInput)
            }
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
                , style "background-color" "#ecf0f1"
                ]
                [ Canvas.view
                    { states = model.automaton.states
                    , transitions = model.automaton.transitions
                    , selectedState = Nothing
                    , transitionFrom = Nothing
                    , activeStateId = model.currentStateId
                    , activeTransition = model.activeTransition
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
              div
                [ style "width" "300px"
                , style "background-color" "white"
                , style "border-left" "2px solid #34495e"
                , style "padding" "15px"
                , style "display" "flex"
                , style "flex-direction" "column"
                , style "background-color" "#f8f9fa"
                ]
                [ div [ style "padding" "20px" ]
                    [ text "Vstupné slovo:"
                    , input
                        [ type_ "text"
                        , value model.inputString
                        , onInput SetInput
                        , style "width" "100%"
                        , style "padding" "8px"
                        , style "margin-top" "5px"
                        , style "border" "1px solid #bdc3c7"
                        , style "border-radius" "4px"
                        ]
                        []
                    ]
                , SimulationStatus.view
                    { inputString = model.inputString
                    , remainingInput = model.remainingInput
                    , currentState = getStateById (Maybe.withDefault -1 model.currentStateId) model.automaton.states
                    , verdict = model.verdict
                    }
                ]
            ]
        ,
          Console.view { messages = model.consoleMessages }
        ]

type_ : String -> Html.Attribute msg
type_ = Html.Attributes.type_
