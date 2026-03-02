module Pages.Conversion exposing (Model, Msg(..), init, update, view, conversionResultToAutomaton)

import Dict exposing (Dict)
import Html exposing (Html, div, button, text, input, table, tr, td, th, thead, tbody, img)
import Html.Attributes exposing (style, type_, value, placeholder, autofocus, disabled, src)
import Html.Events exposing (onClick, onInput)
import Shared exposing (State, AutomatonState)
import Components.ConversionCanvas as ConversionCanvas
import Components.Console as Console
import Utils.ConversionHelpers exposing
    ( DfaSubsetState
    , DfaSubsetTransition
    , ConversionStep(..)
    , StepSnapshot
    , buildSteps
    , lastSnapshotToAutomaton
    , stepExplanation
    , nfaAlphabet
    , getDfaLabel
    )


-- MODEL


type alias Model =
    { nfa : AutomatonState
    , snapshots : List StepSnapshot
    , currentStep : Int
    , highlightDfaStateId : Maybe Int
    , highlightTransition : Maybe { fromId : Int, toId : Int, symbol : String }
    , panX : Float
    , panY : Float
    , zoom : Float
    , isPanning : Bool
    , panLastX : Float
    , panLastY : Float
    , showSaveModal : Bool
    , saveNameInput : String
    , statePositions : Dict Int { x : Float, y : Float }
    , draggingStateId : Maybe Int
    , dragOffsetX : Float
    , dragOffsetY : Float
    , consoleMessages : List Console.Message
    }


-- MSG


type Msg
    = StepForward
    | StepBackward
    | JumpToEnd
    | JumpToStart
    | SwitchToEditor
    | ReplaceAutomaton
    | ShowSaveModal
    | UpdateSaveNameInput String
    | ConfirmSaveToStorage
    | DismissSaveModal
    | CanvasMouseDown Float Float
    | DragMove Float Float
    | EndDrag
    | ZoomIn
    | ZoomOut
    | Wheel Float Float Float
    | StateMouseDown Int Float Float
    | NoOp
    | ShowGuide
    | ToggleConsole


-- INIT


init : AutomatonState -> Model
init nfa =
    updateHighlight
        { nfa = nfa
        , snapshots = buildSteps nfa
        , currentStep = 0
        , highlightDfaStateId = Nothing
        , highlightTransition = Nothing
        , panX = 0
        , panY = 0
        , zoom = 1.0
        , isPanning = False
        , panLastX = 0
        , panLastY = 0
        , showSaveModal = False
        , saveNameInput = ""
        , statePositions = Dict.empty
        , draggingStateId = Nothing
        , dragOffsetX = 0
        , dragOffsetY = 0
        , consoleMessages = [ { text = "Konverzia NFA -> DFA spustena.", msgType = Console.Info } ]
        }


-- UPDATE


update : Msg -> Model -> Model
update msg model =
    let
        total =
            List.length model.snapshots
    in
    case msg of
        StepForward ->
            let
                newStep = min (total - 1) (model.currentStep + 1)
                isNowDone = newStep >= total - 1 && model.currentStep < total - 1
                msgs =
                    if isNowDone then
                        { text = "Konverzia dokoncena.", msgType = Console.Info } :: model.consoleMessages
                    else
                        model.consoleMessages
            in
            updateHighlight { model | currentStep = newStep, consoleMessages = msgs }

        StepBackward ->
            updateHighlight { model | currentStep = max 0 (model.currentStep - 1) }

        JumpToEnd ->
            let
                isNowDone = model.currentStep < total - 1
                msgs =
                    if isNowDone then
                        { text = "Konverzia dokoncena.", msgType = Console.Info } :: model.consoleMessages
                    else
                        model.consoleMessages
            in
            updateHighlight { model | currentStep = total - 1, consoleMessages = msgs }

        JumpToStart ->
            updateHighlight { model | currentStep = 0 }

        SwitchToEditor ->
            model

        ReplaceAutomaton ->
            { model | consoleMessages = { text = "Automat nahradeny konvertovanym DFA.", msgType = Console.Info } :: model.consoleMessages }

        ShowSaveModal ->
            { model | showSaveModal = True, saveNameInput = "" }

        UpdateSaveNameInput s ->
            { model | saveNameInput = s }

        ConfirmSaveToStorage ->
            { model | consoleMessages = { text = "DFA ulozeny: " ++ model.saveNameInput, msgType = Console.Info } :: model.consoleMessages }

        DismissSaveModal ->
            { model | showSaveModal = False, saveNameInput = "" }

        CanvasMouseDown x y ->
            { model | isPanning = True, panLastX = x, panLastY = y }

        StateMouseDown stateId mouseX mouseY ->
            let
                statePos =
                    getStatePos model stateId

                worldMouseX =
                    (mouseX - model.panX) / model.zoom

                worldMouseY =
                    (mouseY - model.panY) / model.zoom
            in
            { model
                | draggingStateId = Just stateId
                , dragOffsetX = statePos.x - worldMouseX
                , dragOffsetY = statePos.y - worldMouseY
                , isPanning = False
            }

        DragMove x y ->
            case model.draggingStateId of
                Just stateId ->
                    let
                        worldX =
                            (x - model.panX) / model.zoom

                        worldY =
                            (y - model.panY) / model.zoom

                        newPos =
                            { x = worldX + model.dragOffsetX, y = worldY + model.dragOffsetY }
                    in
                    { model | statePositions = Dict.insert stateId newPos model.statePositions }

                Nothing ->
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
            { model | isPanning = False, draggingStateId = Nothing }

        ZoomIn ->
            { model | zoom = min 3.0 (model.zoom * 1.2) }

        ZoomOut ->
            { model | zoom = max 0.2 (model.zoom / 1.2) }

        Wheel deltaY mouseX mouseY ->
            let
                newZoom =
                    (model.zoom * (if deltaY > 0 then 0.9 else 1.1)) |> min 3.0 |> max 0.2

                scale =
                    newZoom / model.zoom
            in
            { model
                | zoom = newZoom
                , panX = mouseX - (mouseX - model.panX) * scale
                , panY = mouseY - (mouseY - model.panY) * scale
            }

        NoOp ->
            model

        ShowGuide ->
            model

        ToggleConsole ->
            model


updateHighlight : Model -> Model
updateHighlight model =
    case List.drop model.currentStep model.snapshots |> List.head of
        Nothing ->
            { model | highlightDfaStateId = Nothing, highlightTransition = Nothing }

        Just snap ->
            case snap.step of
                StepInit _ ->
                    { model | highlightDfaStateId = Just 0, highlightTransition = Nothing }

                StepProcessSymbol info ->
                    { model
                        | highlightDfaStateId = Just info.dfaStateId
                        , highlightTransition =
                            if info.resultDfaId >= 0 then
                                Just { fromId = info.dfaStateId, toId = info.resultDfaId, symbol = info.symbol }
                            else
                                Nothing
                    }

                StepMarkProcessed info ->
                    { model | highlightDfaStateId = Just info.dfaStateId, highlightTransition = Nothing }

                StepDone ->
                    { model | highlightDfaStateId = Nothing, highlightTransition = Nothing }


-- HELPERS


getStatePos : Model -> Int -> { x : Float, y : Float }
getStatePos model stateId =
    case Dict.get stateId model.statePositions of
        Just pos ->
            pos

        Nothing ->
            List.drop model.currentStep model.snapshots
                |> List.head
                |> Maybe.andThen (\snap -> List.filter (\s -> s.id == stateId) snap.states |> List.head)
                |> Maybe.map (\s -> { x = s.x, y = s.y })
                |> Maybe.withDefault { x = 0, y = 0 }


resolvePositions : Dict Int { x : Float, y : Float } -> List DfaSubsetState -> List DfaSubsetState
resolvePositions positions states =
    List.map
        (\s ->
            case Dict.get s.id positions of
                Just pos -> { s | x = pos.x, y = pos.y }
                Nothing -> s
        )
        states


-- EXPORT


conversionResultToAutomaton : Model -> AutomatonState
conversionResultToAutomaton model =
    lastSnapshotToAutomaton model.snapshots


-- VIEW


view : Bool -> Model -> Html Msg
view consoleOpen model =
    let
        total =
            List.length model.snapshots

        currentSnap =
            List.drop model.currentStep model.snapshots |> List.head

        isAtEnd =
            model.currentStep >= total - 1

        isAtStart =
            model.currentStep <= 0
    in
    div
        [ style "display" "flex"
        , style "flex-direction" "column"
        , style "height" "100vh"
        , style "overflow" "hidden"
        , style "font-family" "sans-serif"
        ]
        [ viewTopBar (model.currentStep + 1) total isAtStart isAtEnd
        , div
            [ style "display" "flex"
            , style "flex" "1"
            , style "overflow" "hidden"
            ]
            [ viewCanvas model currentSnap
            , viewRightPanel model currentSnap
            ]
        , Console.view
            { messages = model.consoleMessages
            , isOpen = consoleOpen
            , onToggle = ToggleConsole
            , onLinkClick = Nothing
            }
        , viewSaveModal model
        ]


-- TOP BAR


viewTopBar : Int -> Int -> Bool -> Bool -> Html Msg
viewTopBar stepNum total isAtStart isAtEnd =
    div
        [ style "display" "flex"
        , style "flex-direction" "row"
        , style "padding" "14px 12px"
        , style "background-color" "#1a2f4a"
        , style "gap" "8px"
        , style "align-items" "center"
        , style "border-bottom" "2px solid #263238"
        , style "flex-shrink" "0"
        ]
        [ navBtn "⏮" JumpToStart isAtStart
        , navBtn "◀" StepBackward isAtStart
        , navBtn "▶" StepForward isAtEnd
        , navBtn "⏭" JumpToEnd isAtEnd
        , div [ style "color" "white", style "font-size" "14px", style "padding" "0 8px" ]
            [ text ("Krok " ++ String.fromInt stepNum ++ " / " ++ String.fromInt total) ]
        , div
            [ style "width" "1px"
            , style "height" "28px"
            , style "background-color" "rgba(255,255,255,0.2)"
            , style "margin" "0 4px"
            ]
            []
        , actionBtn "Nahradiť automat" ReplaceAutomaton isAtEnd
        , actionBtn "Uložiť DFA" ShowSaveModal isAtEnd
        , div [ style "flex" "1" ] []
        , div
            [ style "width" "300px"
            , style "display" "flex"
            , style "justify-content" "flex-end"
            , style "gap" "8px"
            ]
            [ guideColorBtn ShowGuide
            , colorBtn "← Editor" "#0277bd" SwitchToEditor True
            ]
        ]


navBtn : String -> Msg -> Bool -> Html Msg
navBtn label msg isDisabled =
    button
        [ onClick msg
        , style "padding" "11px 16px"
        , style "background-color" (if isDisabled then "#b0bec5" else "#546e7a")
        , style "color" "white"
        , style "border" "none"
        , style "border-radius" "5px"
        , style "cursor" (if isDisabled then "not-allowed" else "pointer")
        , style "font-size" "14px"
        , disabled isDisabled
        ]
        [ text label ]


actionBtn : String -> Msg -> Bool -> Html Msg
actionBtn label msg isEnabled =
    button
        [ onClick msg
        , style "padding" "11px 18px"
        , style "background-color" (if isEnabled then "#0277bd" else "#b0bec5")
        , style "color" "white"
        , style "border" "none"
        , style "border-radius" "5px"
        , style "cursor" (if isEnabled then "pointer" else "not-allowed")
        , style "font-size" "14px"
        , style "font-weight" "bold"
        , disabled (not isEnabled)
        ]
        [ text label ]


colorBtn : String -> String -> Msg -> Bool -> Html Msg
colorBtn label color msg isEnabled =
    button
        [ onClick msg
        , style "padding" "11px 18px"
        , style "background-color" (if isEnabled then color else "#b0bec5")
        , style "color" "white"
        , style "border" "none"
        , style "border-radius" "5px"
        , style "cursor" (if isEnabled then "pointer" else "not-allowed")
        , style "font-size" "14px"
        , style "font-weight" "bold"
        , disabled (not isEnabled)
        ]
        [ text label ]


guideColorBtn : Msg -> Html Msg
guideColorBtn msg =
    button
        [ onClick msg
        , style "padding" "11px 18px"
        , style "background-color" "#00796b"
        , style "color" "white"
        , style "border" "none"
        , style "border-radius" "5px"
        , style "cursor" "pointer"
        , style "font-size" "14px"
        , style "font-weight" "bold"
        , style "display" "flex"
        , style "align-items" "center"
        , style "gap" "6px"
        ]
        [ img
            [ src "guide_icon.png"
            , style "width" "20px"
            , style "height" "20px"
            , style "filter" "brightness(0) invert(1)"
            ]
            []
        , text "Sprievodca"
        ]


-- CANVAS


viewCanvas : Model -> Maybe StepSnapshot -> Html Msg
viewCanvas model maybeSnap =
    let
        snap =
            Maybe.withDefault { states = [], transitions = [], step = StepDone, processedIds = [], worklist = [] } maybeSnap

        newlyCreatedId =
            case snap.step of
                StepProcessSymbol info ->
                    if info.isNewState then Just info.resultDfaId else Nothing

                _ ->
                    Nothing
    in
    ConversionCanvas.view
        { dfaStates = resolvePositions model.statePositions snap.states
        , dfaTransitions = snap.transitions
        , processedIds = snap.processedIds
        , newlyCreatedId = newlyCreatedId
        , highlightDfaStateId = model.highlightDfaStateId
        , highlightTransition = model.highlightTransition
        , panX = model.panX
        , panY = model.panY
        , zoom = model.zoom
        , onMouseDown = CanvasMouseDown
        , onDragMove = DragMove
        , onEndDrag = EndDrag
        , onZoomIn = ZoomIn
        , onZoomOut = ZoomOut
        , onWheel = Wheel
        , onStateMouseDown = StateMouseDown
        }


-- RIGHT PANEL


viewRightPanel : Model -> Maybe StepSnapshot -> Html Msg
viewRightPanel model maybeSnap =
    let
        snap =
            Maybe.withDefault { states = [], transitions = [], step = StepDone, processedIds = [], worklist = [] } maybeSnap

        alph =
            nfaAlphabet model.nfa.transitions

        currentSymbol =
            case snap.step of
                StepProcessSymbol info -> Just info.symbol
                _ -> Nothing
    in
    div
        [ style "width" "300px"
        , style "flex-shrink" "0"
        , style "background-color" "#f8f9fa"
        , style "border-left" "2px solid #34495e"
        , style "display" "flex"
        , style "flex-direction" "column"
        , style "overflow" "hidden"
        ]
        [ panelHeader "#e8eaf6" "Popis kroku"
        , div
            [ style "padding" "10px 12px"
            , style "font-size" "12px"
            , style "line-height" "1.5"
            , style "background-color" "#fffde7"
            , style "border-bottom" "1px solid #ccc"
            , style "min-height" "54px"
            ]
            [ text (stepExplanation model.nfa.states snap.states snap.step) ]
        , panelHeader "#e8f5e9" "Pôvodné NFA stavy"
        , div [ style "max-height" "120px", style "overflow-y" "auto", style "border-bottom" "1px solid #ccc" ]
            [ viewNfaTable model.nfa.states ]
        , panelHeader "#e3f2fd" "Tabuľka podmnožín"
        , div [ style "flex" "1", style "overflow-y" "auto", style "overflow-x" "auto" ]
            [ viewWorktable snap alph model.highlightDfaStateId currentSymbol ]
        ]


panelHeader : String -> String -> Html Msg
panelHeader bgColor title =
    div
        [ style "padding" "8px 12px"
        , style "font-weight" "bold"
        , style "font-size" "12px"
        , style "background-color" bgColor
        , style "border-bottom" "1px solid #ccc"
        ]
        [ text title ]


-- NFA TABLE


viewNfaTable : List State -> Html Msg
viewNfaTable states =
    table [ style "border-collapse" "collapse", style "font-size" "12px", style "width" "100%" ]
        [ thead []
            [ tr []
                [ tableHeader "left" "Stav"
                , tableHeader "center" "Poč."
                , tableHeader "center" "Konc."
                ]
            ]
        , tbody [] (List.map viewNfaRow states)
        ]


viewNfaRow : State -> Html Msg
viewNfaRow state =
    tr []
        [ td [ style "padding" "2px 8px", style "border-top" "1px solid #ddd", style "font-size" "11px" ] [ text state.label ]
        , td [ style "padding" "2px 8px", style "text-align" "center", style "border-top" "1px solid #ddd", style "font-size" "11px" ] [ text (if state.isStart then "✓" else "") ]
        , td [ style "padding" "2px 8px", style "text-align" "center", style "border-top" "1px solid #ddd", style "font-size" "11px" ] [ text (if state.isEnd then "✓" else "") ]
        ]


tableHeader : String -> String -> Html Msg
tableHeader align label =
    th
        [ style "padding" "4px 8px"
        , style "text-align" align
        , style "background" "#ccc"
        , style "font-size" "11px"
        ]
        [ text label ]


-- WORKTABLE


viewWorktable : StepSnapshot -> List String -> Maybe Int -> Maybe String -> Html Msg
viewWorktable snap alph highlightStateId highlightSymbol =
    table [ style "border-collapse" "collapse", style "font-size" "11px", style "width" "100%" ]
        [ thead []
            [ tr []
                ([ th
                    [ style "padding" "4px 8px"
                    , style "text-align" "left"
                    , style "background" "#bbb"
                    , style "white-space" "nowrap"
                    , style "position" "sticky"
                    , style "top" "0"
                    ]
                    [ text "Stav DFA" ]
                 ]
                    ++ List.map (worktableColHeader highlightSymbol) alph
                )
            ]
        , tbody []
            (List.map (viewWorktableRow snap alph highlightStateId highlightSymbol) snap.states)
        ]


worktableColHeader : Maybe String -> String -> Html Msg
worktableColHeader highlightSymbol sym =
    th
        [ style "padding" "4px 8px"
        , style "text-align" "center"
        , style "background" (if highlightSymbol == Just sym then "#90caf9" else "#ccc")
        , style "white-space" "nowrap"
        , style "position" "sticky"
        , style "top" "0"
        ]
        [ text sym ]


viewWorktableRow : StepSnapshot -> List String -> Maybe Int -> Maybe String -> DfaSubsetState -> Html Msg
viewWorktableRow snap alph highlightStateId highlightSymbol state =
    let
        isRowHighlighted =
            highlightStateId == Just state.id

        rowBg =
            if isRowHighlighted then "#fff9c4" else "transparent"

        isProcessed =
            List.member state.id snap.processedIds
    in
    tr []
        ([ td
            [ style "padding" "3px 8px"
            , style "border-top" "1px solid #ddd"
            , style "background-color" rowBg
            , style "white-space" "nowrap"
            , style "font-weight" "bold"
            ]
            [ text state.label ]
         ]
            ++ List.map (worktableCell snap isRowHighlighted isProcessed rowBg highlightSymbol state.id) alph
        )


worktableCell : StepSnapshot -> Bool -> Bool -> String -> Maybe String -> Int -> String -> Html Msg
worktableCell snap isRowHighlighted isProcessed rowBg highlightSymbol stateId sym =
    let
        cellBg =
            if isRowHighlighted && highlightSymbol == Just sym then
                "#fff176"
            else if isRowHighlighted then
                rowBg
            else if highlightSymbol == Just sym then
                "#e3f2fd"
            else
                "transparent"

        target =
            List.filter (\t -> t.from == stateId && t.symbol == sym) snap.transitions
                |> List.head
                |> Maybe.andThen (\t -> List.filter (\s -> s.id == t.to) snap.states |> List.head)
                |> Maybe.map .label

        cellText =
            if isProcessed then
                Maybe.withDefault "—" target
            else
                Maybe.withDefault "" target
    in
    td
        [ style "padding" "3px 8px"
        , style "text-align" "center"
        , style "border-top" "1px solid #ddd"
        , style "background-color" cellBg
        ]
        [ text cellText ]


-- SAVE MODAL


viewSaveModal : Model -> Html Msg
viewSaveModal model =
    if not model.showSaveModal then
        div [] []

    else
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
                [ div [ style "font-weight" "bold", style "font-size" "16px" ] [ text "Uložiť DFA" ]
                , input
                    [ type_ "text"
                    , placeholder "Názov automatu"
                    , value model.saveNameInput
                    , onInput UpdateSaveNameInput
                    , autofocus True
                    , style "padding" "8px"
                    , style "border" "1px solid #ccc"
                    , style "border-radius" "5px"
                    , style "font-size" "14px"
                    ]
                    []
                , button
                    [ onClick ConfirmSaveToStorage
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
