module Pages.Simulator exposing (Model, Msg(..), SimulationMode(..), init, update, view, subscriptions)

import Html exposing (Html, div, text, input, span, button)
import Html.Attributes exposing (style, placeholder, value, disabled, type_)
import Html.Events exposing (onClick, onInput, on)
import Html.Lazy
import Json.Decode as Decode
import Browser.Events
import Time
import Shared exposing (AutomatonState, State, Transition, NfaInstance, NfaTreeNode, AutomatonType(..))
import Components.Canvas as Canvas
import Components.Console as Console
import Components.SimulateToolbar as SimulateToolbar
import Components.SimulationStatus as SimulationStatus
import Components.NfaInstancePanel as NfaInstancePanel
import Components.NfaTreeView as NfaTreeView
import Set
import Utils.AutomatonHelpers exposing (getStateLabel, getStateById, isDFA, classifyAutomaton, epsilonClosure)
import Json.Encode
import Utils.Theme as Theme
import Utils.Translations as Translations exposing (Language)


type SimulationMode
    = DfaMode
    | NfaMode


type alias Model =
    { automaton : AutomatonState
    , language : Language
    , mode : SimulationMode
    , automatonType : AutomatonType
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


init : Language -> AutomatonState -> Model
init language automaton =
    let
        autoType =
            classifyAutomaton automaton.states automaton.transitions

        mode =
            case autoType of
                NFA ->
                    NfaMode

                _ ->
                    DfaMode

        nfaState =
            initNfaState automaton language ""

        startState =
            List.filter .isStart automaton.states |> List.head |> Maybe.map .id
    in
    { automaton = automaton
    , language = language
    , mode = mode
    , automatonType = autoType
    , currentStateId = startState
    , inputString = ""
    , remainingInput = ""
    , history = []
    , consoleMessages =
        let
            t =
                Translations.getTranslations language
        in
        [ { text = t.simReady, msgType = Console.Info } ]
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
    | ToggleSettings
    | ToggleDarkMode
    | ToggleLanguage
    | RecenterCanvas Float Float


update : Msg -> Model -> Model
update msg model =
    let
        t =
            Translations.getTranslations model.language
    in
    case msg of
        SetInput str ->
            let
                startState =
                    List.filter .isStart model.automaton.states |> List.head |> Maybe.map .id

                nfaState =
                    initNfaState model.automaton model.language str
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
                , consoleMessages = [ { text = t.simInputSetPrefix ++ str, msgType = Console.Info } ]
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
                    update (SetInput model.inputString) (init model.language model.automaton)
            in
            { fresh | language = model.language, mergeEnabled = model.mergeEnabled, showCanvas = model.showCanvas, showTree = model.showTree, autoSpeed = model.autoSpeed, panX = model.panX, panY = model.panY, zoom = model.zoom, treeZoom = model.treeZoom, splitRatio = model.splitRatio, efficientMode = model.efficientMode, efficientResult = Nothing }

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

        RecenterCanvas cw ch ->
            let
                targetState =
                    List.filter .isStart model.automaton.states
                        |> List.head
                        |> (\ms -> case ms of
                                Just s -> Just s
                                Nothing -> List.reverse model.automaton.states |> List.head
                           )
            in
            case targetState of
                Just s ->
                    { model
                        | panX = cw / 2 - s.x * model.zoom
                        , panY = ch / 2 - s.y * model.zoom
                    }

                Nothing ->
                    model

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
                        initNfaState model.automaton model.language model.inputString
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
                    runEfficientNfa model.language model.automaton model.inputString
            in
            { model
                | efficientResult = Just result
                , consoleMessages = { text = t.simEfficientRunPrefix ++ result.text, msgType = Console.Info } :: model.consoleMessages
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
    let
        t =
            Translations.getTranslations model.language
    in
    case ( model.currentStateId, String.uncons model.remainingInput ) of
        ( Just currentId, Just ( char, rest ) ) ->
            let
                symbol =
                    String.fromChar char

                maybeTransition =
                    model.automaton.transitions
                        |> List.filter (\transition -> transition.from == currentId && transition.symbol == symbol)
                        |> List.head
            in
            case maybeTransition of
                Just transition ->
                    let
                        nextStateId =
                            transition.to

                        nextRemaining =
                            rest

                        isEnd =
                            getStateById nextStateId model.automaton.states
                                |> Maybe.map .isEnd
                                |> Maybe.withDefault False

                        nextVerdict =
                            if String.isEmpty nextRemaining then
                                if isEnd then
                                    Just { text = t.simWordAccepted, isAccepted = True }

                                else
                                    Just { text = t.simWordRejected, isAccepted = False }

                            else
                                Nothing
                    in
                    { model
                        | currentStateId = Just nextStateId
                        , remainingInput = nextRemaining
                        , history = ( model.currentStateId, model.remainingInput ) :: model.history
                        , consoleMessages = { text = t.simTransitionThroughPrefix ++ symbol ++ t.simTransitionToStatePrefix ++ getStateLabel nextStateId model.automaton.states, msgType = Console.Info } :: model.consoleMessages
                        , activeTransition = Just { from = transition.from, to = transition.to, symbol = transition.symbol }
                        , verdict = nextVerdict
                    }

                Nothing ->
                    { model
                        | consoleMessages = { text = t.simMissingTransitionPrefix ++ String.fromChar char ++ "'", msgType = Console.Error } :: model.consoleMessages
                        , verdict = Just { text = t.simWordRejected, isAccepted = False }
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
                        Just { text = t.simWordAccepted, isAccepted = True }

                    else
                        Just { text = t.simWordRejected, isAccepted = False }
            in
            { model
                | consoleMessages = { text = t.simEndOfInput, msgType = Console.Info } :: model.consoleMessages
                , verdict = v
            }

        ( Nothing, _ ) ->
            { model
                | consoleMessages = { text = t.simNoCurrentState, msgType = Console.Error } :: model.consoleMessages
            }


stepBackwardDfa : Model -> Model
stepBackwardDfa model =
    let
        t =
            Translations.getTranslations model.language
    in
    case model.history of
        ( prevState, prevInput ) :: restHistory ->
            { model
                | currentStateId = prevState
                , remainingInput = prevInput
                , history = restHistory
                , consoleMessages = { text = t.simStepBack, msgType = Console.Info } :: model.consoleMessages
                , activeTransition = Nothing
                , verdict = Nothing
            }

        [] ->
            model


expandEpsChain :
    AutomatonState
    -> Language
    -> String
    -> List Int
    -> NfaInstance
    -> { instances : List NfaInstance, nodes : List NfaTreeNode, nextId : Int }
    -> { instances : List NfaInstance, nodes : List NfaTreeNode, nextId : Int }
expandEpsChain automaton language remaining visited source acc =
    let
        translations =
            Translations.getTranslations language

        sid =
            Maybe.withDefault -1 source.currentStateId

        directEps =
            List.filter
                (\transition -> transition.from == sid && transition.symbol == "ε" && not (List.member transition.to visited))
                automaton.transitions
    in
    List.foldl
        (\transition innerAcc ->
            let
                childIsEnd =
                    getStateById transition.to automaton.states
                        |> Maybe.map .isEnd
                        |> Maybe.withDefault False

                childVerdict =
                    if String.isEmpty remaining then
                        if childIsEnd then
                            Just { text = translations.accepted, isAccepted = True }

                        else
                            Just { text = translations.rejected, isAccepted = False }

                    else
                        Nothing

                childInstance =
                    { id = innerAcc.nextId
                    , currentStateId = Just transition.to
                    , remainingInput = remaining
                    , verdict = childVerdict
                    , parentId = Just source.id
                    , symbolTaken = Just "ε"
                    }

                childNode =
                    { id = innerAcc.nextId
                    , stateId = Just transition.to
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
            expandEpsChain automaton language remaining (transition.to :: visited) childInstance newAcc
        )
        acc
        directEps


initNfaState :
    AutomatonState
    -> Language
    -> String
    -> { instances : List NfaInstance, tree : List NfaTreeNode, nextInstanceId : Int }
initNfaState automaton language inputStr =
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
                    expandEpsChain automaton language inputStr [ sid ] rootInstance initAcc
    in
    { instances = List.reverse expanded.instances
    , tree = List.reverse expanded.nodes
    , nextInstanceId = expanded.nextId
    }


processInstance :
    AutomatonState
    -> Language
    -> NfaInstance
    -> { instances : List NfaInstance, nodes : List NfaTreeNode, nextId : Int }
    -> { instances : List NfaInstance, nodes : List NfaTreeNode, nextId : Int }
processInstance automaton language instance acc =
    let
        translations =
            Translations.getTranslations language
    in
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
                        Just { text = translations.accepted, isAccepted = True }

                    else
                        Just { text = translations.rejected, isAccepted = False }
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
                            { instance | verdict = Just { text = translations.rejected, isAccepted = False } }
                                :: acc.instances
                    }

                _ ->
                    List.foldl
                        (\transition outerAcc ->
                            let
                                childIsEnd =
                                    getStateById transition.to automaton.states
                                        |> Maybe.map .isEnd
                                        |> Maybe.withDefault False

                                childVerdict =
                                    if String.isEmpty rest then
                                        if childIsEnd then
                                            Just { text = translations.accepted, isAccepted = True }

                                        else
                                            Just { text = translations.rejected, isAccepted = False }

                                    else
                                        Nothing

                                childInstance =
                                    { id = outerAcc.nextId
                                    , currentStateId = Just transition.to
                                    , remainingInput = rest
                                    , verdict = childVerdict
                                    , parentId = Just instance.id
                                    , symbolTaken = Just symbol
                                    }

                                childNode =
                                    { id = outerAcc.nextId
                                    , stateId = Just transition.to
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
                            expandEpsChain automaton language rest [ transition.to ] childInstance newAcc
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
            List.foldl (processInstance model.automaton model.language) initAcc alive

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
        , consoleMessages = { text = (Translations.getTranslations model.language).simStepForwardNfa, msgType = Console.Info } :: model.consoleMessages
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
                , consoleMessages = { text = (Translations.getTranslations model.language).simStepBack, msgType = Console.Info } :: model.consoleMessages
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
                not (String.isEmpty model.remainingInput) && model.verdict == Nothing

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


runEfficientNfa : Language -> AutomatonState -> String -> { text : String, isAccepted : Bool, reachedStates : List Int }
runEfficientNfa language automaton inputStr =
    let
        t =
            Translations.getTranslations language

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
                                (\transition innerAcc ->
                                    if transition.from == stId && transition.symbol == symbol then
                                        Set.insert transition.to innerAcc

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
        { text = t.simWordAccepted, isAccepted = True, reachedStates = reachedList }

    else
        { text = t.simWordRejected, isAccepted = False, reachedStates = reachedList }


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


viewNfaTree : Theme.Theme -> List NfaTreeNode -> List NfaInstance -> List State -> Maybe Int -> List { from : Int, to : Int } -> Float -> Html Msg
viewNfaTree theme treeNodes instances states selectedId mergedEdges zoom =
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
        , theme = theme
        }


viewReadingHead : Theme.Theme -> List String -> String -> String -> Html Msg
viewReadingHead theme alphabet fullInput remaining =
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

                isUnknown =
                    not (List.member (String.fromChar c) alphabet)
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
                    (if isCurrent && isUnknown then
                        "#f9a825"

                     else if isCurrent then
                        "#1e88e5"

                     else if isConsumed then
                        theme.readingHeadConsumedBg

                     else if isUnknown then
                        "#f9a825"

                     else
                        theme.inputBg
                    )
                , style "color"
                    (if isCurrent && isUnknown then
                        "#000"

                     else if isCurrent then
                        "white"

                     else if isConsumed then
                        theme.readingHeadConsumedText

                     else if isUnknown then
                        "#000"

                     else
                        theme.inputText
                    )
                , style "border"
                    (if isCurrent then
                        "2px solid #1565c0"

                     else if isUnknown then
                        "1px solid #f57f17"

                     else
                        "1px solid " ++ theme.inputBorder
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
            , style "border-bottom" ("1px solid " ++ theme.separatorColor)
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


viewToggleTab : Theme.Theme -> String -> Bool -> Msg -> Html Msg
viewToggleTab theme label isActive msg =
    Html.button
        [ onClick msg
        , style "padding" "7px 18px"
        , style "background-color" (if isActive then theme.tabActiveBg else "transparent")
        , style "color" theme.tabText
        , style "border" "none"
        , style "border-bottom" (if isActive then "2px solid #00bcd4" else "2px solid transparent")
        , style "cursor" "pointer"
        , style "font-size" "13px"
        , style "font-weight" (if isActive then "bold" else "normal")
        ]
        [ Html.text label ]


viewWhyNfaBlock : Theme.Theme -> Translations.Translations -> AutomatonType -> Bool -> Bool -> Html Msg
viewWhyNfaBlock theme t autoType hasEpsilon hasNonDeterminism =
    let
        reasons =
            (if hasEpsilon then [ t.simWhyNfaEpsilon ] else [])
                ++ (if hasNonDeterminism then [ t.simWhyNfaNondet ] else [])
                ++ (if autoType == IncompleteDFA then [ t.simWhyNfaIncomplete ] else [])
    in
    div
        [ style "padding" "10px 15px"
        , style "border-top" ("1px solid " ++ theme.separatorColor)
        ]
        [ div
            [ style "font-weight" "bold"
            , style "font-size" "14px"
            , style "color" theme.textPrimary
            , style "margin-bottom" "6px"
            ]
            [ text t.simWhyNfaTitle ]
        , div []
            (List.map
                (\reason ->
                    div
                        [ style "font-size" "13px"
                        , style "color" theme.textMuted
                        , style "padding-left" "10px"
                        , style "margin-bottom" "3px"
                        , style "line-height" "1.4"
                        ]
                        [ text ("\u{2022} " ++ reason) ]
                )
                reasons
            )
        ]


view : Bool -> Bool -> Bool -> Language -> Bool -> Bool -> Int -> Int -> Model -> Html Msg
view consoleOpen darkMode settingsOpen language tutorialInputHighlight tutorialButtonsHighlight windowWidth windowHeight model =
    let
        t =
            Translations.getTranslations language

        theme = Theme.getTheme darkMode
        canvasW = toFloat windowWidth - 302
        canvasH = toFloat windowHeight - 80
        hasEpsilon =
            List.any (\transition -> transition.symbol == "\u{03B5}") model.automaton.transitions

        hasNonDeterminism =
            let
                key tr = String.fromInt tr.from ++ "|" ++ tr.symbol
                checkDups tl seen =
                    case tl of
                        [] -> False
                        tr :: rest ->
                            let k = key tr
                            in
                            if List.member k seen then True
                            else checkDups rest (k :: seen)
            in
            checkDups (List.filter (\tr -> tr.symbol /= "\u{03B5}") model.automaton.transitions) []

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
            , theme = theme
            , settingsOpen = settingsOpen
            , onToggleSettings = ToggleSettings
            , onToggleDarkMode = ToggleDarkMode
            , darkMode = darkMode
            , language = language
            , onToggleLanguage = ToggleLanguage
            , tutorialHighlightButtons = tutorialButtonsHighlight
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
                        , style "background-color" theme.toolbarBg
                        , style "flex-shrink" "0"
                        ]
                        (if model.efficientMode then
                            [ viewDisabledToggleTab t.simAutomatonTab
                            , viewDisabledToggleTab t.simTreeTab
                            ]

                         else
                            [ viewToggleTab theme t.simAutomatonTab model.showCanvas ToggleCanvas
                            , viewToggleTab theme t.simTreeTab model.showTree ToggleTree
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
                        let
                            targetState =
                                List.filter .isStart model.automaton.states
                                    |> List.head
                                    |> (\ms -> case ms of
                                            Just s -> Just s
                                            Nothing -> List.reverse model.automaton.states |> List.head
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
                            [ if model.mode == NfaMode && model.showCanvas && model.showTree && not model.efficientMode then
                                style "flex-basis" (String.fromFloat (model.splitRatio * 100) ++ "%")

                              else
                                style "flex" "1"
                            , style "flex-shrink" (if model.mode == NfaMode && model.showCanvas && model.showTree && not model.efficientMode then "0" else "1")
                            , style "flex-grow" (if model.mode == NfaMode && model.showCanvas && model.showTree && not model.efficientMode then "0" else "1")
                            , style "min-width" "150px"
                            , style "overflow" "auto"
                            , style "background-color" theme.canvasBg
                            , style "position" "relative"
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
                                , onStateRightClick = \_ -> CanvasClick 0 0
                                , onTransitionClick = TransitionClick
                                , onTransitionDoubleClick = \_ _ _ -> CanvasClick 0 0
                                , onArrowClick = \_ _ -> CanvasClick 0 0
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
                                , highlightedTransitions = []
                                , editingStateId = Nothing
                                , theme = theme
                                , gridMode = False
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
                                , style "color" "white"
                                , style "white-space" "nowrap"
                                ] ++ (if targetVisible then [ disabled True ] else [ onClick (RecenterCanvas canvasW canvasH) ]))
                                [ text t.editorRecenter ]
                            ]

                      else
                        div [] []
                    , if model.mode == NfaMode && model.showCanvas && model.showTree && not model.efficientMode  then
                        div
                            [ style "width" "6px"
                            , style "background-color" theme.dividerColor
                            , style "cursor" "col-resize"
                            , style "flex-shrink" "0"
                            , style "transition" "background-color 0.15s"
                            , on "mousedown" (Decode.map StartDividerDrag (Decode.field "clientX" Decode.float))
                            ]
                            []

                      else if model.mode == NfaMode && model.showTree && not model.efficientMode  then
                        div
                            [ style "width" "1px"
                            , style "background-color" theme.separatorColor
                            ]
                            []

                      else
                        div [] []
                    , if model.mode == NfaMode && model.showTree && not model.efficientMode  then
                        viewNfaTree theme
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
                , style "border-left" ("2px solid " ++ theme.rightPanelBorder)
                , style "display" "flex"
                , style "flex-direction" "column"
                , style "background-color" theme.rightPanelBg
                , style "overflow" "hidden"
                ]
                [ div
                    ([ style "padding" "10px 15px 6px 15px", style "color" theme.textPrimary ]
                    ++ (if tutorialInputHighlight then
                            [ style "position" "relative"
                            , style "z-index" "501"
                            , style "box-shadow" "0 0 0 3px #ffeb3b, 0 0 16px rgba(255,235,59,0.7)"
                            ]
                        else
                            []
                       )
                    )
                    [ text (t.simInputWordLabel ++ ":")
                    , input
                        [ type_ "text"
                        , value model.inputString
                        , onInput SetInput
                        , style "width" "100%"
                        , style "padding" "8px"
                        , style "margin-top" "5px"
                        , style "border" (if String.isEmpty model.inputString then "2px solid #e53935" else "1px solid " ++ theme.inputBorder)
                        , style "border-radius" "4px"
                        , style "box-sizing" "border-box"
                        , style "background-color" theme.inputBg
                        , style "color" theme.inputText
                        , style "outline" (if String.isEmpty model.inputString then "none" else "")
                        ]
                        []
                    , if String.isEmpty model.inputString then
                        div
                            [ style "color" "#e53935"
                            , style "font-size" "12px"
                            , style "margin-top" "4px"
                            ]
                            [ text t.simInputEmptyError ]
                      else
                        let
                            alphabet =
                                model.automaton.transitions
                                    |> List.map .symbol
                                    |> List.filter (\s -> s /= "ε")
                            hasUnknownSymbol =
                                model.inputString
                                    |> String.toList
                                    |> List.any (\c -> not (List.member (String.fromChar c) alphabet))
                        in
                        if hasUnknownSymbol then
                            div
                                [ style "color" "#f9a825"
                                , style "font-size" "12px"
                                , style "margin-top" "4px"
                                ]
                                [ text t.simInputUnknownSymbols ]
                        else
                            text ""
                    ]
                , viewReadingHead theme
                    (model.automaton.transitions |> List.map .symbol |> List.filter (\s -> s /= "ε"))
                    model.inputString
                    readingHeadRemaining
                , case model.mode of
                    DfaMode ->
                        div []
                            [ SimulationStatus.view
                                { inputString = model.inputString
                                , remainingInput = model.remainingInput
                                , currentState = getStateById (Maybe.withDefault -1 model.currentStateId) model.automaton.states
                                , verdict = model.verdict
                                , theme = theme
                                , language = language
                                }
                            , if model.automatonType == IncompleteDFA then
                                viewWhyNfaBlock theme t model.automatonType hasEpsilon hasNonDeterminism
                              else
                                text ""
                            ]

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
                                    , theme = theme
                                    , language = language
                                    }

                              else
                                div [] []
                            , viewWhyNfaBlock theme t model.automatonType hasEpsilon hasNonDeterminism
                            , div
                                    [ style "padding" "6px 15px"
                                    , style "border-top" ("1px solid " ++ theme.separatorColor)
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
                                             , style "color" (if hasEpsilon then theme.textMuted else theme.textMuted)
                                             ]
                                                ++ (if hasEpsilon then
                                                        [ Html.Attributes.title t.simMergeUnavailable ]

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
                                            , text t.simMergeLabel
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
                                            , Html.Attributes.title t.simMergeTooltip
                                            ]
                                            [ text "?" ]
                                        ]
                                    , div
                                        [ style "font-weight" "bold"
                                        , style "font-size" "13px"
                                        ]
                                        []
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
                                        , text t.simEfficientModeLabel
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
                                        , Html.Attributes.title t.simEfficientModeTooltip
                                        ]
                                        [ text "?" ]
                                    ]
                            , if model.efficientMode then
                                div []
                                    [ Html.button
                                        [ onClick RunEfficient
                                        , style "width" "100%"
                                        , style "padding" "12px 16px"
                                        , style "background-color" theme.btnPrimary
                                        , style "color" "white"
                                        , style "border" "none"
                                        , style "border-radius" "6px"
                                        , style "cursor" "pointer"
                                        , style "font-size" "15px"
                                        , style "font-weight" "bold"
                                        , style "margin" "8px 15px"
                                        , style "box-sizing" "border-box"
                                        ]
                                        [ text t.simInstantRun ]
                                    , case model.efficientResult of
                                        Just result ->
                                            div
                                                [ style "padding" "10px 15px"
                                                , style "margin" "4px 15px"
                                                , style "border-radius" "6px"
                                                , style "background-color"
                                                    (if result.isAccepted then theme.resultAcceptBg else theme.resultRejectBg)
                                                , style "border-left"
                                                    (if result.isAccepted then "4px solid #43a047" else "4px solid #e53935")
                                                ]
                                                [ div
                                                    [ style "font-weight" "bold"
                                                    , style "font-size" "14px"
                                                    , style "color"
                                                        (if result.isAccepted then theme.resultAcceptText else theme.resultRejectText)
                                                    ]
                                                    [ text result.text ]
                                                , div
                                                    [ style "font-size" "12px"
                                                    , style "color" theme.textMuted
                                                    , style "margin-top" "4px"
                                                    ]
                                                    [ text (t.simReachedStatesPrefix ++ String.join ", " (List.map (\sid -> getStateLabel sid model.automaton.states) result.reachedStates)) ]
                                                ]

                                        Nothing ->
                                            div [] []
                                    , div
                                        [ style "flex" "1"
                                        , style "display" "flex"
                                        , style "align-items" "center"
                                        , style "justify-content" "center"
                                        , style "padding" "15px"
                                        , style "color" theme.textMuted
                                        , style "font-size" "13px"
                                        , style "text-align" "center"
                                        ]
                                        [ text t.simInstancePanelDisabled ]
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
                                        , theme = theme
                                        , language = language
                                        }
                                    ]
                            ]
                ]
            ]
        , Console.view
            { messages = model.consoleMessages
            , isOpen = consoleOpen
            , onToggle = ToggleConsole
            , onLinkClick = Nothing
            , theme = theme
            , language = language
            }
        ]
