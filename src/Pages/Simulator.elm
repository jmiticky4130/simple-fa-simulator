module Pages.Simulator exposing (Model, Msg(..), init, update, view, subscriptions)

import Html exposing (Html, div, text, input, span)
import Html.Attributes exposing (style, placeholder, value, disabled, type_)
import Html.Events exposing (onClick, onInput, on)
import Html.Lazy
import Json.Decode as Decode
import Browser.Events
import Time
import Shared exposing (AutomatonState, State, Transition, NfaInstance, NfaTreeNode)
import Components.Canvas as Canvas
import Components.Console as Console
import Components.SimulateToolbar as SimulateToolbar
import Components.SimulationStatus as SimulationStatus
import Components.NfaInstancePanel as NfaInstancePanel
import Components.NfaTreeView as NfaTreeView
import Set
import Utils.AutomatonHelpers exposing (getStateLabel, getStateById, isDFA, epsilonClosure)
import Json.Encode


type SimulationMode
    = DfaMode
    | NfaMode


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
    , showCanvas : Bool
    , showTree : Bool
    , mergeEnabled : Bool
    , autoRunning : Bool
    , autoSpeed : Float
    , panX : Float
    , panY : Float
    , zoom : Float
    , isPanning : Bool
    , panLastX : Float
    , panLastY : Float
    , treeZoom : Float
    , isDraggingDivider : Bool
    , splitRatio : Float
    , dividerDragStartX : Float
    , dividerDragStartRatio : Float
    , instancePanelVisible : Int
    , efficientMode : Bool
    , efficientResult : Maybe { text : String, isAccepted : Bool, reachedStates : List Int }
    }


init : AutomatonState -> Model
init automaton =
    let
        mode =
            if isDFA automaton.states automaton.transitions then
                DfaMode

            else
                NfaMode

        nfaState =
            initNfaState automaton ""

        startState =
            List.filter .isStart automaton.states |> List.head |> Maybe.map .id
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
    , nfaInstances = nfaState.instances
    , nfaHistory = []
    , nfaTree = nfaState.tree
    , nfaMergedEdges = []
    , selectedInstanceId = Nothing
    , nextInstanceId = nfaState.nextInstanceId
    , showCanvas = True
    , showTree = False
    , mergeEnabled = False
    , autoRunning = False
    , autoSpeed = 1000
    , panX = 0
    , panY = 0
    , zoom = 1.0
    , isPanning = False
    , panLastX = 0
    , panLastY = 0
    , treeZoom = 1.0
    , isDraggingDivider = False
    , splitRatio = 0.667
    , dividerDragStartX = 0
    , dividerDragStartRatio = 0.667
    , instancePanelVisible = 100
    , efficientMode = False
    , efficientResult = Nothing
    }


type Msg
    = StepForward
    | StepBackward
    | ResetSimulation
    | SwitchToEditor
    | SetInput String
    | SelectNfaInstance Int
    | ToggleCanvas
    | ToggleTree
    | ToggleMerge
    | ToggleAutoRun
    | SetAutoSpeed String
    | LoadMoreInstances
    | AutoStep Time.Posix
    | CanvasClick Float Float
    | StateClick Int
    | TransitionClick Int Int String
    | StartDrag Int Float Float
    | DragMove Float Float
    | EndDrag
    | CanvasMouseDown Float Float
    | ZoomIn
    | ZoomOut
    | Wheel Float Float Float
    | TreeZoomIn
    | TreeZoomOut
    | ShowGuide
    | StartDividerDrag Float
    | DividerDragMove Float
    | EndDividerDrag
    | ToggleConsole
    | ToggleEfficientMode
    | RunEfficient


update : Msg -> Model -> Model
update msg model =
    case msg of
        SetInput str ->
            let
                startState =
                    List.filter .isStart model.automaton.states |> List.head |> Maybe.map .id

                nfaState =
                    initNfaState model.automaton str
            in
            { model
                | inputString = str
                , remainingInput = str
                , currentStateId = startState
                , history = []
                , activeTransition = Nothing
                , verdict = Nothing
                , nfaInstances = nfaState.instances
                , nfaHistory = []
                , nfaTree = nfaState.tree
                , nfaMergedEdges = []
                , selectedInstanceId = Nothing
                , nextInstanceId = nfaState.nextInstanceId
                , consoleMessages = [ { text = "Vstup nastavený: " ++ str, msgType = Console.Info } ]
                , instancePanelVisible = 100
                , efficientResult = Nothing
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
                    update (SetInput model.inputString) (init model.automaton)
            in
            { fresh | mergeEnabled = model.mergeEnabled, showCanvas = model.showCanvas, showTree = model.showTree, autoSpeed = model.autoSpeed, panX = model.panX, panY = model.panY, zoom = model.zoom, treeZoom = model.treeZoom, splitRatio = model.splitRatio, efficientMode = model.efficientMode, efficientResult = Nothing }

        SwitchToEditor ->
            model

        SelectNfaInstance id ->
            { model | selectedInstanceId = Just id }

        ToggleCanvas ->
            { model | showCanvas = not model.showCanvas }

        ToggleTree ->
            { model | showTree = not model.showTree }

        ToggleMerge ->
            { model | mergeEnabled = not model.mergeEnabled }

        ToggleAutoRun ->
            if model.efficientMode then
                model

            else
                { model | autoRunning = not model.autoRunning }

        SetAutoSpeed str ->
            case String.toFloat str of
                Just ms ->
                    { model | autoSpeed = ms }

                Nothing ->
                    model

        LoadMoreInstances ->
            { model | instancePanelVisible = model.instancePanelVisible + 100 }

        AutoStep _ ->
            if canStepForward model then
                case model.mode of
                    DfaMode ->
                        stepForwardDfa model

                    NfaMode ->
                        stepForwardNfa model

            else
                { model | autoRunning = False }

        CanvasMouseDown x y ->
            { model | isPanning = True, panLastX = x, panLastY = y }

        DragMove x y ->
            if model.isPanning then
                { model
                    | panX = model.panX + (x - model.panLastX)
                    , panY = model.panY + (y - model.panLastY)
                    , panLastX = x
                    , panLastY = y
                }
            else
                model

        EndDrag ->
            { model | isPanning = False }

        StartDrag _ _ _ ->
            { model | isPanning = False }

        ZoomIn ->
            { model | zoom = min 3.0 (model.zoom * 1.2) }

        ZoomOut ->
            { model | zoom = max 0.2 (model.zoom / 1.2) }

        Wheel deltaY mouseX mouseY ->
            let
                zoomFactor = if deltaY > 0 then 0.9 else 1.1
                newZoom = model.zoom * zoomFactor |> min 3.0 |> max 0.2
                scale = newZoom / model.zoom
                newPanX = mouseX - (mouseX - model.panX) * scale
                newPanY = mouseY - (mouseY - model.panY) * scale
            in
            { model | zoom = newZoom, panX = newPanX, panY = newPanY }

        TreeZoomIn ->
            { model | treeZoom = min 3.0 (model.treeZoom * 1.2) }

        TreeZoomOut ->
            { model | treeZoom = max 0.2 (model.treeZoom / 1.2) }

        StartDividerDrag clientX ->
            { model | isDraggingDivider = True, dividerDragStartX = clientX, dividerDragStartRatio = model.splitRatio }

        DividerDragMove clientX ->
            if model.isDraggingDivider && model.dividerDragStartX > 0 then
                let
                    newRatio =
                        clientX * model.dividerDragStartRatio / model.dividerDragStartX
                in
                { model | splitRatio = clamp 0.1 0.9 newRatio }

            else
                model

        EndDividerDrag ->
            { model | isDraggingDivider = False }

        ToggleEfficientMode ->
            let
                newMode =
                    not model.efficientMode
            in
            if newMode then
                { model | efficientMode = True, efficientResult = Nothing, autoRunning = False }

            else
                let
                    nfaState =
                        initNfaState model.automaton model.inputString
                in
                { model
                    | efficientMode = False
                    , efficientResult = Nothing
                    , nfaInstances = nfaState.instances
                    , nfaHistory = []
                    , nfaTree = nfaState.tree
                    , nfaMergedEdges = []
                    , selectedInstanceId = Nothing
                    , nextInstanceId = nfaState.nextInstanceId
                    , instancePanelVisible = 100
                }

        RunEfficient ->
            let
                result =
                    runEfficientNfa model.automaton model.inputString
            in
            { model
                | efficientResult = Just result
                , consoleMessages = { text = "Efektívny beh: " ++ result.text, msgType = Console.Info } :: model.consoleMessages
            }

        ToggleConsole ->
            model

        _ ->
            model


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        autoSub =
            if model.autoRunning then
                Time.every model.autoSpeed AutoStep

            else
                Sub.none

        dividerMoveSub =
            if model.isDraggingDivider then
                Browser.Events.onMouseMove
                    (Decode.map DividerDragMove (Decode.field "clientX" Decode.float))

            else
                Sub.none

        dividerUpSub =
            if model.isDraggingDivider then
                Browser.Events.onMouseUp (Decode.succeed EndDividerDrag)

            else
                Sub.none
    in
    Sub.batch [ autoSub, dividerMoveSub, dividerUpSub ]


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


expandEpsChain :
    AutomatonState
    -> String
    -> List Int
    -> NfaInstance
    -> { instances : List NfaInstance, nodes : List NfaTreeNode, nextId : Int }
    -> { instances : List NfaInstance, nodes : List NfaTreeNode, nextId : Int }
expandEpsChain automaton remaining visited source acc =
    let
        sid =
            Maybe.withDefault -1 source.currentStateId

        directEps =
            List.filter
                (\t -> t.from == sid && t.symbol == "ε" && not (List.member t.to visited))
                automaton.transitions
    in
    List.foldl
        (\t innerAcc ->
            let
                childIsEnd =
                    getStateById t.to automaton.states
                        |> Maybe.map .isEnd
                        |> Maybe.withDefault False

                childVerdict =
                    if String.isEmpty remaining then
                        if childIsEnd then
                            Just { text = "Akceptované", isAccepted = True }

                        else
                            Just { text = "Zamietnuté", isAccepted = False }

                    else
                        Nothing

                childInstance =
                    { id = innerAcc.nextId
                    , currentStateId = Just t.to
                    , remainingInput = remaining
                    , verdict = childVerdict
                    , parentId = Just source.id
                    , symbolTaken = Just "ε"
                    }

                childNode =
                    { id = innerAcc.nextId
                    , stateId = Just t.to
                    , parentId = Just source.id
                    , symbol = Just "ε"
                    }

                newAcc =
                    { innerAcc
                        | instances = childInstance :: innerAcc.instances
                        , nodes = childNode :: innerAcc.nodes
                        , nextId = innerAcc.nextId + 1
                    }
            in
            expandEpsChain automaton remaining (t.to :: visited) childInstance newAcc
        )
        acc
        directEps


initNfaState :
    AutomatonState
    -> String
    -> { instances : List NfaInstance, tree : List NfaTreeNode, nextInstanceId : Int }
initNfaState automaton inputStr =
    let
        startState =
            List.filter .isStart automaton.states |> List.head |> Maybe.map .id

        rootInstance =
            { id = 0
            , currentStateId = startState
            , remainingInput = inputStr
            , verdict = Nothing
            , parentId = Nothing
            , symbolTaken = Nothing
            }

        rootNode =
            { id = 0
            , stateId = startState
            , parentId = Nothing
            , symbol = Nothing
            }

        initAcc =
            { instances = [ rootInstance ], nodes = [ rootNode ], nextId = 1 }

        expanded =
            case startState of
                Nothing ->
                    initAcc

                Just sid ->
                    expandEpsChain automaton inputStr [ sid ] rootInstance initAcc
    in
    { instances = List.reverse expanded.instances
    , tree = List.reverse expanded.nodes
    , nextInstanceId = expanded.nextId
    }


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
                        (\t outerAcc ->
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
                                    { id = outerAcc.nextId
                                    , currentStateId = Just t.to
                                    , remainingInput = rest
                                    , verdict = childVerdict
                                    , parentId = Just instance.id
                                    , symbolTaken = Just symbol
                                    }

                                childNode =
                                    { id = outerAcc.nextId
                                    , stateId = Just t.to
                                    , parentId = Just instance.id
                                    , symbol = Just symbol
                                    }

                                newAcc =
                                    { outerAcc
                                        | instances = childInstance :: outerAcc.instances
                                        , nodes = childNode :: outerAcc.nodes
                                        , nextId = outerAcc.nextId + 1
                                    }
                            in
                            expandEpsChain automaton rest [ t.to ] childInstance newAcc
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
    if model.efficientMode then
        False

    else
        case model.mode of
            DfaMode ->
                not (String.isEmpty model.remainingInput)

            NfaMode ->
                List.any (\i -> i.verdict == Nothing) model.nfaInstances


canStepBackward : Model -> Bool
canStepBackward model =
    if model.efficientMode then
        False

    else
        case model.mode of
            DfaMode ->
                not (List.isEmpty model.history)

            NfaMode ->
                not (List.isEmpty model.nfaHistory)


runEfficientNfa : AutomatonState -> String -> { text : String, isAccepted : Bool, reachedStates : List Int }
runEfficientNfa automaton inputStr =
    let
        startState =
            List.filter .isStart automaton.states |> List.head |> Maybe.map .id

        initialSet =
            case startState of
                Nothing ->
                    Set.empty

                Just sid ->
                    epsilonClosure automaton.transitions sid
                        |> Set.fromList

        step char currentSet =
            let
                symbol =
                    String.fromChar char

                targets =
                    Set.foldl
                        (\stId acc ->
                            List.foldl
                                (\t innerAcc ->
                                    if t.from == stId && t.symbol == symbol then
                                        Set.insert t.to innerAcc

                                    else
                                        innerAcc
                                )
                                acc
                                automaton.transitions
                        )
                        Set.empty
                        currentSet

                expanded =
                    Set.foldl
                        (\stId acc ->
                            List.foldl (\x s -> Set.insert x s) acc (epsilonClosure automaton.transitions stId)
                        )
                        Set.empty
                        targets
            in
            expanded

        finalSet =
            List.foldl step initialSet (String.toList inputStr)

        endStateIds =
            List.filter .isEnd automaton.states |> List.map .id |> Set.fromList

        reachedList =
            Set.toList finalSet

        accepted =
            not (Set.isEmpty (Set.intersect finalSet endStateIds))
    in
    if accepted then
        { text = "Slovo je akceptované", isAccepted = True, reachedStates = reachedList }

    else
        { text = "Slovo nie je akceptované", isAccepted = False, reachedStates = reachedList }


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


viewNfaTree : List NfaTreeNode -> List NfaInstance -> List State -> Maybe Int -> List { from : Int, to : Int } -> Float -> Html Msg
viewNfaTree treeNodes instances states selectedId mergedEdges zoom =
    NfaTreeView.view
        { treeNodes = treeNodes
        , instances = instances
        , states = states
        , selectedId = selectedId
        , onSelect = SelectNfaInstance
        , mergedEdges = mergedEdges
        , zoom = zoom
        , onZoomIn = TreeZoomIn
        , onZoomOut = TreeZoomOut
        }


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


viewDisabledToggleTab : String -> Html Msg
viewDisabledToggleTab label =
    Html.button
        [ Html.Attributes.disabled True
        , style "padding" "7px 18px"
        , style "background-color" "transparent"
        , style "color" "#78909c"
        , style "border" "none"
        , style "border-bottom" "2px solid transparent"
        , style "cursor" "not-allowed"
        , style "font-size" "13px"
        , style "opacity" "0.5"
        ]
        [ Html.text label ]


viewToggleTab : String -> Bool -> Msg -> Html Msg
viewToggleTab label isActive msg =
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


view : Bool -> Model -> Html Msg
view consoleOpen model =
    let
        hasEpsilon =
            List.any (\t -> t.symbol == "ε") model.automaton.transitions

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

        efficientHighlights =
            case model.efficientResult of
                Just result ->
                    result.reachedStates
                        |> List.map
                            (\stId ->
                                let
                                    isEnd =
                                        getStateById stId model.automaton.states
                                            |> Maybe.map .isEnd
                                            |> Maybe.withDefault False
                                in
                                { stateId = stId, isAccepted = isEnd }
                            )

                Nothing ->
                    []
    in
    div
        [ style "display" "flex"
        , style "flex-direction" "column"
        , style "height" "100vh"
        , style "width" "100vw"
        , style "overflow" "hidden"
        , style "user-select" (if model.isDraggingDivider then "none" else "auto")
        , style "cursor" (if model.isDraggingDivider then "col-resize" else "auto")
        ]
        [ SimulateToolbar.view
            { onStepBackward = StepBackward
            , onStepForward = StepForward
            , onReset = ResetSimulation
            , onSwitchToEditor = SwitchToEditor
            , canStepBackward = canStepBackward model
            , canStepForward = canStepForward model
            , nextSymbol = nextSymbol
            , onToggleAutoRun = ToggleAutoRun
            , autoRunning = model.autoRunning
            , autoSpeed = model.autoSpeed
            , onSetAutoSpeed = SetAutoSpeed
            , onShowGuide = ShowGuide
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
                        , style "background-color" "#1a2f4a"
                        , style "flex-shrink" "0"
                        ]
                        (if model.efficientMode then
                            [ viewDisabledToggleTab "Automat"
                            , viewDisabledToggleTab "Strom"
                            ]

                         else
                            [ viewToggleTab "Automat" model.showCanvas ToggleCanvas
                            , viewToggleTab "Strom" model.showTree ToggleTree
                            ]
                        )

                  else
                    div [] []
                , -- Canvas and/or tree (side by side)
                  div
                    [ style "flex" "1"
                    , style "display" "flex"
                    , style "flex-direction" "row"
                    , style "overflow" "hidden"
                    ]
                    [ if model.mode == DfaMode || model.showCanvas || model.efficientMode then
                        div
                            [ if model.mode == NfaMode && model.showCanvas && model.showTree && not model.efficientMode then
                                style "flex-basis" (String.fromFloat (model.splitRatio * 100) ++ "%")

                              else
                                style "flex" "1"
                            , style "flex-shrink" (if model.mode == NfaMode && model.showCanvas && model.showTree && not model.efficientMode then "0" else "1")
                            , style "flex-grow" (if model.mode == NfaMode && model.showCanvas && model.showTree && not model.efficientMode then "0" else "1")
                            , style "min-width" "150px"
                            , style "overflow" "auto"
                            , style "background-color" "#ecf0f1"
                            ]
                            [ Canvas.view
                                { states = model.automaton.states
                                , transitions = model.automaton.transitions
                                , selectedState = Nothing
                                , transitionFrom = Nothing
                                , transitionTo = Nothing
                                , activeStateId = activeStateId
                                , activeStateVerdict =
                                    case model.mode of
                                        DfaMode ->
                                            model.verdict |> Maybe.map .isAccepted
                                        NfaMode ->
                                            selectedInstanceVerdict |> Maybe.map .isAccepted
                                , activeTransition = model.activeTransition
                                , onCanvasClick = CanvasClick
                                , onCanvasDoubleClick = \_ _ -> CanvasClick 0 0
                                , onStateClick = StateClick
                                , onStateDoubleClick = \_ -> CanvasClick 0 0
                                , onTransitionClick = TransitionClick
                                , onTransitionDoubleClick = \_ _ _ -> CanvasClick 0 0
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
                                , isSimulateMode = True
                                , highlightedStateIds = efficientHighlights
                                }
                            ]

                      else
                        div [] []
                    , if model.mode == NfaMode && model.showCanvas && model.showTree && not model.efficientMode then
                        div
                            [ style "width" "6px"
                            , style "background-color" "#b0bec5"
                            , style "cursor" "col-resize"
                            , style "flex-shrink" "0"
                            , style "transition" "background-color 0.15s"
                            , on "mousedown" (Decode.map StartDividerDrag (Decode.field "clientX" Decode.float))
                            ]
                            []

                      else if model.mode == NfaMode && model.showTree && not model.efficientMode then
                        div
                            [ style "width" "1px"
                            , style "background-color" "#ccc"
                            ]
                            []

                      else
                        div [] []
                    , if model.mode == NfaMode && model.showTree && not model.efficientMode then
                        Html.Lazy.lazy6 viewNfaTree
                            model.nfaTree
                            model.nfaInstances
                            model.automaton.states
                            model.selectedInstanceId
                            model.nfaMergedEdges
                            model.treeZoom

                      else
                        div [] []
                    ]
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
                            [ if not model.efficientMode then
                                SimulationStatus.view
                                    { inputString = model.inputString
                                    , remainingInput = selectedInstanceRemaining
                                    , currentState = selectedInstanceState
                                    , verdict = selectedInstanceVerdict
                                    }

                              else
                                div [] []
                            , div
                                [ style "padding" "6px 15px"
                                , style "border-top" "1px solid #ccc"
                                , style "display" "flex"
                                , style "align-items" "center"
                                , style "justify-content" "space-between"
                                ]
                                [ div
                                    [ style "display" "flex"
                                    , style "align-items" "center"
                                    , style "gap" "4px"
                                    ]
                                    [ Html.label
                                        ([ style "display" "flex"
                                         , style "align-items" "center"
                                         , style "gap" "6px"
                                         , style "font-size" "12px"
                                         , style "user-select" "none"
                                         , style "cursor" (if hasEpsilon then "not-allowed" else "pointer")
                                         , style "color" (if hasEpsilon then "#b0bec5" else "#546e7a")
                                         ]
                                            ++ (if hasEpsilon then
                                                    [ Html.Attributes.title "Zlúčenie stavov nie je dostupné pre automaty s ε-prechodmi" ]

                                                else
                                                    []
                                               )
                                        )
                                        [ Html.input
                                            ([ type_ "checkbox"
                                             , Html.Attributes.checked model.mergeEnabled
                                             , style "cursor" (if hasEpsilon then "not-allowed" else "pointer")
                                             ]
                                                ++ (if hasEpsilon then
                                                        [ Html.Attributes.disabled True ]

                                                    else
                                                        [ onClick ToggleMerge ]
                                                   )
                                            )
                                            []
                                        , text "Zlúčiť stavy"
                                        ]
                                    , span
                                        [ style "display" "inline-flex"
                                        , style "align-items" "center"
                                        , style "justify-content" "center"
                                        , style "width" "14px"
                                        , style "height" "14px"
                                        , style "border-radius" "50%"
                                        , style "background" "#90a4ae"
                                        , style "color" "white"
                                        , style "font-size" "9px"
                                        , style "font-weight" "bold"
                                        , style "cursor" "help"
                                        , style "flex-shrink" "0"
                                        , Html.Attributes.title "Bez zlucenia moze pocet instancii rst exponencialne s dlzkou vstupu (az k^n, kde k je priemer vetveni a n dlzka vstupu). Zlucenie redukuje pocet aktivnych instancii na najviac |Q| v kazdom kroku - rovnaky princip ako algoritmus podmnozin. Odporucane pre komplexne NFA."
                                        ]
                                        [ text "?" ]
                                    ]
                                , div
                                    [ style "font-weight" "bold"
                                    , style "font-size" "13px"
                                    ]
                                    [ text "Inštancie NFA:" ]
                                ]
                            , div
                                [ style "padding" "6px 15px"
                                , style "border-top" "1px solid #e0e0e0"
                                , style "display" "flex"
                                , style "align-items" "center"
                                , style "gap" "6px"
                                ]
                                [ Html.label
                                    [ style "display" "flex"
                                    , style "align-items" "center"
                                    , style "gap" "6px"
                                    , style "font-size" "12px"
                                    , style "user-select" "none"
                                    , style "cursor" "pointer"
                                    , style "color" "#546e7a"
                                    ]
                                    [ Html.input
                                        [ type_ "checkbox"
                                        , Html.Attributes.checked model.efficientMode
                                        , onClick ToggleEfficientMode
                                        , style "cursor" "pointer"
                                        ]
                                        []
                                    , text "Efektívny režim"
                                    ]
                                , span
                                    [ style "display" "inline-flex"
                                    , style "align-items" "center"
                                    , style "justify-content" "center"
                                    , style "width" "14px"
                                    , style "height" "14px"
                                    , style "border-radius" "50%"
                                    , style "background" "#90a4ae"
                                    , style "color" "white"
                                    , style "font-size" "9px"
                                    , style "font-weight" "bold"
                                    , style "cursor" "help"
                                    , style "flex-shrink" "0"
                                    , Html.Attributes.title "Efektívny režim spustí simuláciu naraz bez budovania stromu inštancií. Vhodné pre komplexné NFA s dlhým vstupom, kde by klasická simulácia bola príliš pomalá."
                                    ]
                                    [ text "?" ]
                                ]
                            , if model.efficientMode then
                                div []
                                    [ Html.button
                                        [ onClick RunEfficient
                                        , style "width" "100%"
                                        , style "padding" "12px 16px"
                                        , style "background-color" "#0277bd"
                                        , style "color" "white"
                                        , style "border" "none"
                                        , style "border-radius" "6px"
                                        , style "cursor" "pointer"
                                        , style "font-size" "15px"
                                        , style "font-weight" "bold"
                                        , style "margin" "8px 15px"
                                        , style "box-sizing" "border-box"
                                        ]
                                        [ text "Okamžitý beh" ]
                                    , case model.efficientResult of
                                        Just result ->
                                            div
                                                [ style "padding" "10px 15px"
                                                , style "margin" "4px 15px"
                                                , style "border-radius" "6px"
                                                , style "background-color"
                                                    (if result.isAccepted then "#e8f5e9" else "#ffebee")
                                                , style "border-left"
                                                    (if result.isAccepted then "4px solid #43a047" else "4px solid #e53935")
                                                ]
                                                [ div
                                                    [ style "font-weight" "bold"
                                                    , style "font-size" "14px"
                                                    , style "color"
                                                        (if result.isAccepted then "#2e7d32" else "#c62828")
                                                    ]
                                                    [ text result.text ]
                                                , div
                                                    [ style "font-size" "12px"
                                                    , style "color" "#546e7a"
                                                    , style "margin-top" "4px"
                                                    ]
                                                    [ text ("Dosiahnuté stavy: " ++ String.join ", " (List.map (\sid -> getStateLabel sid model.automaton.states) result.reachedStates)) ]
                                                ]

                                        Nothing ->
                                            div [] []
                                    , div
                                        [ style "flex" "1"
                                        , style "display" "flex"
                                        , style "align-items" "center"
                                        , style "justify-content" "center"
                                        , style "padding" "15px"
                                        , style "color" "#90a4ae"
                                        , style "font-size" "13px"
                                        , style "text-align" "center"
                                        ]
                                        [ text "Panel inštancií je deaktivovaný v efektívnom režime." ]
                                    ]

                              else
                                div
                                    [ style "flex" "1"
                                    , style "overflow-y" "auto"
                                    , style "padding" "4px 15px"
                                    ]
                                    [ NfaInstancePanel.view
                                        { instances = model.nfaInstances
                                        , selectedId = model.selectedInstanceId
                                        , onSelect = SelectNfaInstance
                                        , states = model.automaton.states
                                        , visibleCount = model.instancePanelVisible
                                        , onLoadMore = LoadMoreInstances
                                        }
                                    ]
                            ]
                ]
            ]
        , Console.view
            { messages = model.consoleMessages
            , isOpen = consoleOpen
            , onToggle = ToggleConsole
            }
        ]
