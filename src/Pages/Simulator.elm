module Pages.Simulator exposing (Model, Msg(..), init, update, view)

import Html exposing (Html, div, text, input, span)
import Html.Attributes exposing (style, placeholder, value, disabled, type_)
import Html.Events exposing (onClick, onInput)
import Shared exposing (AutomatonState, State, Transition, NfaInstance, NfaTreeNode)
import Components.Canvas as Canvas
import Components.Console as Console
import Components.SimulateToolbar as SimulateToolbar
import Components.SimulationStatus as SimulationStatus
import Components.NfaInstancePanel as NfaInstancePanel
import Components.NfaTreeView as NfaTreeView
import Utils.AutomatonHelpers exposing (getStateLabel, getStateById, isDFA)
import Json.Encode


type SimulationMode
    = DfaMode
    | NfaMode


type ViewMode
    = CanvasView
    | TreeView


type alias Model =
    { automaton : AutomatonState
    , mode : SimulationMode
    -- DFA
    , currentStateId : Maybe Int
    , remainingInput : String
    , history : List ( Maybe Int, String )
    , activeTransition : Maybe { from : Int, to : Int, symbol : String }
    , verdict : Maybe { text : String, isAccepted : Bool }
    -- NFA
    , nfaInstances : List NfaInstance
    , nfaHistory : List { instances : List NfaInstance, tree : List NfaTreeNode, nextId : Int, mergedEdges : List { from : Int, to : Int } }
    , nfaTree : List NfaTreeNode
    , nfaMergedEdges : List { from : Int, to : Int }
    , selectedInstanceId : Maybe Int
    , nextInstanceId : Int
    -- shared
    , inputString : String
    , consoleMessages : List Console.Message
    , viewMode : ViewMode
    , mergeEnabled : Bool
    }


init : AutomatonState -> Model
init automaton =
    let
        mode =
            if isDFA automaton.states automaton.transitions then
                DfaMode

            else
                NfaMode

        startState =
            List.filter .isStart automaton.states |> List.head |> Maybe.map .id

        initInstance =
            { id = 0
            , currentStateId = startState
            , remainingInput = ""
            , verdict = Nothing
            , parentId = Nothing
            , symbolTaken = Nothing
            }

        initNode =
            { id = 0
            , stateId = startState
            , parentId = Nothing
            , symbol = Nothing
            }
    in
    { automaton = automaton
    , mode = mode
    , currentStateId = startState
    , inputString = ""
    , remainingInput = ""
    , history = []
    , consoleMessages = [ { text = "Simulátor pripravený. Zadajte vstupné slovo.", msgType = Console.Info } ]
    , activeTransition = Nothing
    , verdict = Nothing
    , nfaInstances = [ initInstance ]
    , nfaHistory = []
    , nfaTree = [ initNode ]
    , nfaMergedEdges = []
    , selectedInstanceId = Nothing
    , nextInstanceId = 1
    , viewMode = CanvasView
    , mergeEnabled = False
    }


type Msg
    = StepForward
    | StepBackward
    | ResetSimulation
    | SwitchToEditor
    | SetInput String
    | SelectNfaInstance Int
    | SetViewMode ViewMode
    | ToggleMerge
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

                initInstance =
                    { id = 0
                    , currentStateId = startState
                    , remainingInput = str
                    , verdict = Nothing
                    , parentId = Nothing
                    , symbolTaken = Nothing
                    }

                initNode =
                    { id = 0
                    , stateId = startState
                    , parentId = Nothing
                    , symbol = Nothing
                    }
            in
            { model
                | inputString = str
                , remainingInput = str
                , currentStateId = startState
                , history = []
                , activeTransition = Nothing
                , verdict = Nothing
                , nfaInstances = [ initInstance ]
                , nfaHistory = []
                , nfaTree = [ initNode ]
                , nfaMergedEdges = []
                , selectedInstanceId = Nothing
                , nextInstanceId = 1
                , consoleMessages = [ { text = "Vstup nastavený: " ++ str, msgType = Console.Info } ]
            }

        StepForward ->
            case model.mode of
                DfaMode ->
                    stepForwardDfa model

                NfaMode ->
                    stepForwardNfa model

        StepBackward ->
            case model.mode of
                DfaMode ->
                    stepBackwardDfa model

                NfaMode ->
                    stepBackwardNfa model

        ResetSimulation ->
            let
                fresh =
                    init model.automaton
            in
            { fresh | mergeEnabled = model.mergeEnabled, viewMode = model.viewMode }

        SwitchToEditor ->
            model

        SelectNfaInstance id ->
            { model | selectedInstanceId = Just id }

        SetViewMode mode ->
            { model | viewMode = mode }

        ToggleMerge ->
            { model | mergeEnabled = not model.mergeEnabled }

        _ ->
            model


stepForwardDfa : Model -> Model
stepForwardDfa model =
    case ( model.currentStateId, String.uncons model.remainingInput ) of
        ( Just currentId, Just ( char, rest ) ) ->
            let
                symbol =
                    String.fromChar char

                maybeTransition =
                    model.automaton.transitions
                        |> List.filter (\t -> t.from == currentId && t.symbol == symbol)
                        |> List.head
            in
            case maybeTransition of
                Just t ->
                    let
                        nextStateId =
                            t.to

                        nextRemaining =
                            rest

                        isEnd =
                            getStateById nextStateId model.automaton.states
                                |> Maybe.map .isEnd
                                |> Maybe.withDefault False

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
                        , history = ( model.currentStateId, model.remainingInput ) :: model.history
                        , consoleMessages = { text = "Prechod cez '" ++ symbol ++ "' do stavu " ++ getStateLabel nextStateId model.automaton.states, msgType = Console.Info } :: model.consoleMessages
                        , activeTransition = Just { from = t.from, to = t.to, symbol = t.symbol }
                        , verdict = nextVerdict
                    }

                Nothing ->
                    { model
                        | consoleMessages = { text = "Chyba: Neexistuje prechod pre symbol '" ++ String.fromChar char ++ "'", msgType = Console.Error } :: model.consoleMessages
                        , verdict = Just { text = "Slovo nie je akceptované", isAccepted = False }
                        , activeTransition = Nothing
                    }

        ( Just currentId, Nothing ) ->
            let
                isEnd =
                    getStateById currentId model.automaton.states
                        |> Maybe.map .isEnd
                        |> Maybe.withDefault False

                v =
                    if isEnd then
                        Just { text = "Slovo je akceptované", isAccepted = True }

                    else
                        Just { text = "Slovo nie je akceptované", isAccepted = False }
            in
            { model
                | consoleMessages = { text = "Koniec vstupu.", msgType = Console.Info } :: model.consoleMessages
                , verdict = v
            }

        ( Nothing, _ ) ->
            { model
                | consoleMessages = { text = "Chyba: Nie je nastavený aktuálny stav.", msgType = Console.Error } :: model.consoleMessages
            }


stepBackwardDfa : Model -> Model
stepBackwardDfa model =
    case model.history of
        ( prevState, prevInput ) :: restHistory ->
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


processInstance :
    AutomatonState
    -> NfaInstance
    -> { instances : List NfaInstance, nodes : List NfaTreeNode, nextId : Int }
    -> { instances : List NfaInstance, nodes : List NfaTreeNode, nextId : Int }
processInstance automaton instance acc =
    case String.uncons instance.remainingInput of
        Nothing ->
            let
                isEnd =
                    case instance.currentStateId of
                        Just sid ->
                            getStateById sid automaton.states
                                |> Maybe.map .isEnd
                                |> Maybe.withDefault False

                        Nothing ->
                            False

                newVerdict =
                    if isEnd then
                        Just { text = "Akceptované", isAccepted = True }

                    else
                        Just { text = "Zamietnuté", isAccepted = False }
            in
            { acc | instances = { instance | verdict = newVerdict } :: acc.instances }

        Just ( char, rest ) ->
            let
                symbol =
                    String.fromChar char

                matchingTransitions =
                    case instance.currentStateId of
                        Just sid ->
                            List.filter (\t -> t.from == sid && t.symbol == symbol) automaton.transitions

                        Nothing ->
                            []
            in
            case matchingTransitions of
                [] ->
                    { acc
                        | instances =
                            { instance | verdict = Just { text = "Zamietnuté", isAccepted = False } }
                                :: acc.instances
                    }

                _ ->
                    List.foldl
                        (\t innerAcc ->
                            let
                                childIsEnd =
                                    getStateById t.to automaton.states
                                        |> Maybe.map .isEnd
                                        |> Maybe.withDefault False

                                childVerdict =
                                    if String.isEmpty rest then
                                        if childIsEnd then
                                            Just { text = "Akceptované", isAccepted = True }

                                        else
                                            Just { text = "Zamietnuté", isAccepted = False }

                                    else
                                        Nothing

                                childInstance =
                                    { id = innerAcc.nextId
                                    , currentStateId = Just t.to
                                    , remainingInput = rest
                                    , verdict = childVerdict
                                    , parentId = Just instance.id
                                    , symbolTaken = Just symbol
                                    }

                                childNode =
                                    { id = innerAcc.nextId
                                    , stateId = Just t.to
                                    , parentId = Just instance.id
                                    , symbol = Just symbol
                                    }
                            in
                            { innerAcc
                                | instances = childInstance :: innerAcc.instances
                                , nodes = childNode :: innerAcc.nodes
                                , nextId = innerAcc.nextId + 1
                            }
                        )
                        acc
                        matchingTransitions


mergeIfEnabled :
    Bool
    -> List NfaInstance
    -> List NfaInstance
    -> List NfaTreeNode
    -> ( List NfaInstance, List NfaTreeNode, List { from : Int, to : Int } )
mergeIfEnabled enabled done newInsts newNodes =
    if not enabled then
        ( done ++ newInsts, newNodes, [] )

    else
        let
            foldResult =
                List.foldl
                    (\inst acc ->
                        let
                            key =
                                ( inst.currentStateId, inst.remainingInput )

                            doneMatch =
                                List.filter (\i -> ( i.currentStateId, i.remainingInput ) == key) done
                                    |> List.head

                            accMatch =
                                List.filter (\i -> ( i.currentStateId, i.remainingInput ) == key) acc.kept
                                    |> List.head

                            keptMatch =
                                case doneMatch of
                                    Just k ->
                                        Just k

                                    Nothing ->
                                        accMatch
                        in
                        case keptMatch of
                            Just kept ->
                                let
                                    droppedParentId =
                                        newNodes
                                            |> List.filter (\n -> n.id == inst.id)
                                            |> List.head
                                            |> Maybe.andThen .parentId
                                in
                                case droppedParentId of
                                    Just pid ->
                                        { acc | mergeEdges = acc.mergeEdges ++ [ { from = pid, to = kept.id } ] }

                                    Nothing ->
                                        acc

                            Nothing ->
                                { acc | kept = acc.kept ++ [ inst ] }
                    )
                    { kept = [], mergeEdges = [] }
                    newInsts

            keptIds =
                List.map .id foldResult.kept

            filteredNodes =
                List.filter (\n -> List.member n.id keptIds) newNodes
        in
        ( done ++ foldResult.kept, filteredNodes, foldResult.mergeEdges )


stepForwardNfa : Model -> Model
stepForwardNfa model =
    let
        snapshot =
            { instances = model.nfaInstances
            , tree = model.nfaTree
            , nextId = model.nextInstanceId
            , mergedEdges = model.nfaMergedEdges
            }

        newHistory =
            snapshot :: model.nfaHistory

        ( done, alive ) =
            List.partition (\i -> i.verdict /= Nothing) model.nfaInstances

        initAcc =
            { instances = [], nodes = [], nextId = model.nextInstanceId }

        finalAcc =
            List.foldl (processInstance model.automaton) initAcc alive

        processedInstances =
            List.reverse finalAcc.instances

        newNodes =
            List.reverse finalAcc.nodes

        ( finalInstances, filteredNodes, newMergedEdges ) =
            mergeIfEnabled model.mergeEnabled done processedInstances newNodes

        finalTree =
            model.nfaTree ++ filteredNodes

        newSelectedId =
            case model.selectedInstanceId of
                Nothing ->
                    Nothing

                Just sid ->
                    if List.any (\i -> i.id == sid) finalInstances then
                        Just sid

                    else
                        finalInstances
                            |> List.filter (\i -> i.parentId == Just sid)
                            |> List.head
                            |> Maybe.map .id
    in
    { model
        | nfaInstances = finalInstances
        , nfaTree = finalTree
        , nfaHistory = newHistory
        , nfaMergedEdges = model.nfaMergedEdges ++ newMergedEdges
        , nextInstanceId = finalAcc.nextId
        , selectedInstanceId = newSelectedId
        , consoleMessages = { text = "Krok vpred (NFA).", msgType = Console.Info } :: model.consoleMessages
    }


stepBackwardNfa : Model -> Model
stepBackwardNfa model =
    case model.nfaHistory of
        snapshot :: restHistory ->
            { model
                | nfaInstances = snapshot.instances
                , nfaTree = snapshot.tree
                , nextInstanceId = snapshot.nextId
                , nfaMergedEdges = snapshot.mergedEdges
                , nfaHistory = restHistory
                , selectedInstanceId = Nothing
                , consoleMessages = { text = "Krok späť.", msgType = Console.Info } :: model.consoleMessages
            }

        [] ->
            model


canStepForward : Model -> Bool
canStepForward model =
    case model.mode of
        DfaMode ->
            not (String.isEmpty model.remainingInput)

        NfaMode ->
            List.any (\i -> i.verdict == Nothing) model.nfaInstances


canStepBackward : Model -> Bool
canStepBackward model =
    case model.mode of
        DfaMode ->
            not (List.isEmpty model.history)

        NfaMode ->
            not (List.isEmpty model.nfaHistory)


nfaActiveStateId : Model -> Maybe Int
nfaActiveStateId model =
    model.selectedInstanceId
        |> Maybe.andThen
            (\sid ->
                model.nfaInstances
                    |> List.filter (\i -> i.id == sid)
                    |> List.head
            )
        |> Maybe.andThen .currentStateId


nfaTreeToJson : List NfaTreeNode -> Json.Encode.Value
nfaTreeToJson nodes =
    Json.Encode.object
        [ ( "nodes", Json.Encode.list encodeNode nodes ) ]


encodeNode : NfaTreeNode -> Json.Encode.Value
encodeNode node =
    Json.Encode.object
        [ ( "id", Json.Encode.int node.id )
        , ( "stateId", Maybe.map Json.Encode.int node.stateId |> Maybe.withDefault Json.Encode.null )
        , ( "parentId", Maybe.map Json.Encode.int node.parentId |> Maybe.withDefault Json.Encode.null )
        , ( "symbol", Maybe.map Json.Encode.string node.symbol |> Maybe.withDefault Json.Encode.null )
        ]


viewReadingHead : String -> String -> Html Msg
viewReadingHead fullInput remaining =
    let
        consumedCount =
            String.length fullInput - String.length remaining

        chars =
            String.toList fullInput

        renderChar idx c =
            let
                isConsumed =
                    idx < consumedCount

                isCurrent =
                    idx == consumedCount
            in
            div
                [ style "min-width" "26px"
                , style "height" "30px"
                , style "display" "flex"
                , style "align-items" "center"
                , style "justify-content" "center"
                , style "font-size" "15px"
                , style "font-weight" "bold"
                , style "border-radius" "4px"
                , style "background-color"
                    (if isCurrent then
                        "#1e88e5"

                     else if isConsumed then
                        "#eceff1"

                     else
                        "white"
                    )
                , style "color"
                    (if isCurrent then
                        "white"

                     else if isConsumed then
                        "#b0bec5"

                     else
                        "#263238"
                    )
                , style "border"
                    (if isCurrent then
                        "2px solid #1565c0"

                     else
                        "1px solid #cfd8dc"
                    )
                , style "padding" "0 4px"
                ]
                [ text (String.fromChar c) ]
    in
    if String.isEmpty fullInput then
        div [] []

    else
        div
            [ style "padding" "6px 15px 8px 15px"
            , style "border-bottom" "1px solid #e0e0e0"
            ]
            [ div
                [ style "display" "flex"
                , style "flex-wrap" "wrap"
                , style "gap" "3px"
                , style "align-items" "center"
                ]
                (List.indexedMap renderChar chars)
            ]


viewTab : String -> Bool -> Msg -> Html Msg
viewTab label isActive msg =
    Html.button
        [ onClick msg
        , style "padding" "7px 18px"
        , style "background-color" (if isActive then "#546e7a" else "transparent")
        , style "color" "white"
        , style "border" "none"
        , style "border-bottom" (if isActive then "2px solid #00bcd4" else "2px solid transparent")
        , style "cursor" "pointer"
        , style "font-size" "13px"
        , style "font-weight" (if isActive then "bold" else "normal")
        ]
        [ Html.text label ]


view : Model -> Html Msg
view model =
    let
        activeStateId =
            case model.mode of
                DfaMode ->
                    model.currentStateId

                NfaMode ->
                    nfaActiveStateId model

        selectedInstance =
            model.selectedInstanceId
                |> Maybe.andThen
                    (\sid ->
                        model.nfaInstances
                            |> List.filter (\i -> i.id == sid)
                            |> List.head
                    )

        selectedInstanceState =
            selectedInstance
                |> Maybe.andThen
                    (\inst ->
                        inst.currentStateId
                            |> Maybe.andThen (\stId -> getStateById stId model.automaton.states)
                    )

        selectedInstanceRemaining =
            selectedInstance
                |> Maybe.map .remainingInput
                |> Maybe.withDefault model.inputString

        selectedInstanceVerdict =
            selectedInstance
                |> Maybe.andThen .verdict

        nextSymbol =
            case model.mode of
                DfaMode ->
                    String.uncons model.remainingInput
                        |> Maybe.map (Tuple.first >> String.fromChar)

                NfaMode ->
                    model.nfaInstances
                        |> List.filter (\i -> i.verdict == Nothing)
                        |> List.head
                        |> Maybe.andThen (\i -> String.uncons i.remainingInput)
                        |> Maybe.map (Tuple.first >> String.fromChar)

        readingHeadRemaining =
            case model.mode of
                DfaMode ->
                    model.remainingInput

                NfaMode ->
                    selectedInstanceRemaining
    in
    div
        [ style "display" "flex"
        , style "flex-direction" "column"
        , style "height" "100vh"
        , style "width" "100vw"
        , style "overflow" "hidden"
        ]
        [ SimulateToolbar.view
            { onStepBackward = StepBackward
            , onStepForward = StepForward
            , onReset = ResetSimulation
            , onSwitchToEditor = SwitchToEditor
            , canStepBackward = canStepBackward model
            , canStepForward = canStepForward model
            , nextSymbol = nextSymbol
            }
        , div
            [ style "display" "flex"
            , style "flex-direction" "row"
            , style "flex" "1"
            , style "overflow" "hidden"
            ]
            [ div
                [ style "flex" "1"
                , style "display" "flex"
                , style "flex-direction" "column"
                , style "overflow" "hidden"
                ]
                [ -- Toggle tabs (NFA mode only)
                  if model.mode == NfaMode then
                    div
                        [ style "display" "flex"
                        , style "background-color" "#455a64"
                        , style "flex-shrink" "0"
                        ]
                        [ viewTab "Automat" (model.viewMode == CanvasView) (SetViewMode CanvasView)
                        , viewTab "Strom" (model.viewMode == TreeView) (SetViewMode TreeView)
                        ]

                  else
                    div [] []
                , -- Canvas or tree
                  if model.mode == NfaMode && model.viewMode == TreeView then
                    NfaTreeView.view
                        { treeNodes = model.nfaTree
                        , instances = model.nfaInstances
                        , states = model.automaton.states
                        , selectedId = model.selectedInstanceId
                        , onSelect = SelectNfaInstance
                        , mergedEdges = model.nfaMergedEdges
                        }

                  else
                    Canvas.view
                        { states = model.automaton.states
                        , transitions = model.automaton.transitions
                        , selectedState = Nothing
                        , transitionFrom = Nothing
                        , activeStateId = activeStateId
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
            , div
                [ style "width" "300px"
                , style "border-left" "2px solid #34495e"
                , style "display" "flex"
                , style "flex-direction" "column"
                , style "background-color" "#f8f9fa"
                , style "overflow" "hidden"
                ]
                [ div [ style "padding" "10px 15px 6px 15px" ]
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
                        , style "box-sizing" "border-box"
                        ]
                        []
                    ]
                , viewReadingHead model.inputString readingHeadRemaining
                , case model.mode of
                    DfaMode ->
                        SimulationStatus.view
                            { inputString = model.inputString
                            , remainingInput = model.remainingInput
                            , currentState = getStateById (Maybe.withDefault -1 model.currentStateId) model.automaton.states
                            , verdict = model.verdict
                            }

                    NfaMode ->
                        div
                            [ style "display" "flex"
                            , style "flex-direction" "column"
                            , style "flex" "1"
                            , style "overflow" "hidden"
                            ]
                            [ SimulationStatus.view
                                { inputString = model.inputString
                                , remainingInput = selectedInstanceRemaining
                                , currentState = selectedInstanceState
                                , verdict = selectedInstanceVerdict
                                }
                            , div
                                [ style "padding" "6px 15px"
                                , style "border-top" "1px solid #ccc"
                                , style "display" "flex"
                                , style "align-items" "center"
                                , style "justify-content" "space-between"
                                ]
                                [ Html.label
                                    [ style "display" "flex"
                                    , style "align-items" "center"
                                    , style "gap" "6px"
                                    , style "cursor" "pointer"
                                    , style "font-size" "12px"
                                    , style "color" "#546e7a"
                                    , style "user-select" "none"
                                    ]
                                    [ Html.input
                                        [ type_ "checkbox"
                                        , Html.Attributes.checked model.mergeEnabled
                                        , onClick ToggleMerge
                                        ]
                                        []
                                    , text "Zlúčiť stavy"
                                    ]
                                , div
                                    [ style "font-weight" "bold"
                                    , style "font-size" "13px"
                                    ]
                                    [ text "Inštancie NFA:" ]
                                ]
                            , div
                                [ style "flex" "1"
                                , style "overflow-y" "auto"
                                , style "padding" "4px 15px"
                                ]
                                [ NfaInstancePanel.view
                                    { instances = model.nfaInstances
                                    , selectedId = model.selectedInstanceId
                                    , onSelect = SelectNfaInstance
                                    , states = model.automaton.states
                                    }
                                ]
                            ]
                ]
            ]
        , Console.view { messages = model.consoleMessages }
        ]
