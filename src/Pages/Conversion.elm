module Pages.Conversion exposing (Model, Msg(..), init, update, view, conversionResultToAutomaton)

import Dict exposing (Dict)
import Html exposing (Html, div, button, text, input, table, tr, td, th, thead, tbody, img)
import Html.Attributes exposing (style, type_, value, placeholder, autofocus, disabled, src)
import Html.Events exposing (onClick, onInput)
import Svg
import Svg.Attributes as SA
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
import Utils.Theme as Theme
import Utils.Translations as Translations exposing (Language)


-- MODEL


type alias Model =
    { nfa : AutomatonState
    , language : Language
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
    | ToggleSettings
    | ToggleDarkMode
    | ToggleLanguage


-- INIT


init : Language -> AutomatonState -> Model
init language nfa =
    updateHighlight
        { nfa = nfa
        , language = language
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
        , consoleMessages =
            let
                t =
                    Translations.getTranslations language
            in
            [ { text = t.convStarted, msgType = Console.Info } ]
        }


-- UPDATE


update : Msg -> Model -> Model
update msg model =
    let
        t =
            Translations.getTranslations model.language

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
                        { text = t.convFinished, msgType = Console.Info } :: model.consoleMessages
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
                        { text = t.convFinished, msgType = Console.Info } :: model.consoleMessages
                    else
                        model.consoleMessages
            in
            updateHighlight { model | currentStep = total - 1, consoleMessages = msgs }

        JumpToStart ->
            updateHighlight { model | currentStep = 0 }

        SwitchToEditor ->
            model

        ReplaceAutomaton ->
            { model | consoleMessages = { text = t.convAutomatonReplaced, msgType = Console.Info } :: model.consoleMessages }

        ShowSaveModal ->
            { model | showSaveModal = True, saveNameInput = "" }

        UpdateSaveNameInput s ->
            { model | saveNameInput = s }

        ConfirmSaveToStorage ->
            { model | consoleMessages = { text = t.convDfaSavedPrefix ++ model.saveNameInput, msgType = Console.Info } :: model.consoleMessages }

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

        ToggleSettings ->
            model

        ToggleDarkMode ->
            model

        ToggleLanguage ->
            { model | language = if model.language == Translations.Slovak then Translations.English else Translations.Slovak }


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


view : Bool -> Bool -> Bool -> Language -> Model -> Html Msg
view consoleOpen darkMode settingsOpen language model =
    let
        t =
            Translations.getTranslations language

        theme = Theme.getTheme darkMode

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
        [ viewTopBar theme settingsOpen darkMode language (model.currentStep + 1) total isAtStart isAtEnd
        , div
            [ style "display" "flex"
            , style "flex" "1"
            , style "overflow" "hidden"
            ]
            [ viewCanvas theme model currentSnap
            , viewRightPanel theme model currentSnap
            ]
        , Console.view
            { messages = model.consoleMessages
            , isOpen = consoleOpen
            , onToggle = ToggleConsole
            , onLinkClick = Nothing
            , theme = theme
            , language = language
            }
        , viewSaveModal theme t model
        ]


-- TOP BAR


viewTopBar : Theme.Theme -> Bool -> Bool -> Language -> Int -> Int -> Bool -> Bool -> Html Msg
viewTopBar theme settingsOpen darkMode language stepNum total isAtStart isAtEnd =
    let
        t =
            Translations.getTranslations language
    in
    div
        [ style "display" "flex"
        , style "flex-direction" "row"
        , style "padding" "14px 12px"
        , style "background-color" theme.toolbarBg
        , style "gap" "8px"
        , style "align-items" "center"
        , style "border-bottom" ("2px solid " ++ theme.toolbarBorderColor)
        , style "flex-shrink" "0"
        ]
        [ navBtn theme "<<" JumpToStart isAtStart
        , navBtn theme "<" StepBackward isAtStart
        , navBtn theme ">" StepForward isAtEnd
        , navBtn theme ">>" JumpToEnd isAtEnd
        , div [ style "color" "white", style "font-size" "14px", style "padding" "0 8px" ]
            [ text (t.stepLabel ++ " " ++ String.fromInt stepNum ++ " / " ++ String.fromInt total) ]
        , div
            [ style "width" "1px"
            , style "height" "28px"
            , style "background-color" "rgba(255,255,255,0.2)"
            , style "margin" "0 4px"
            ]
            []
        , iconActionBtn theme replaceIcon t.replaceAutomaton ReplaceAutomaton isAtEnd
        , iconActionBtn theme saveIcon t.saveDfa ShowSaveModal isAtEnd
        , div [ style "flex" "1" ] []
        , div
            [ style "width" "300px"
            , style "display" "flex"
            , style "justify-content" "flex-end"
            , style "gap" "8px"
            ]
            [ guideColorBtn theme t.guide ShowGuide
            , colorBtn theme t.backToEditor theme.btnPrimary SwitchToEditor True
            , settingsGearBtn theme settingsOpen darkMode language
            ]
        ]


settingsGearBtn : Theme.Theme -> Bool -> Bool -> Language -> Html Msg
settingsGearBtn theme settingsOpen darkMode language =
    let
        t = Translations.getTranslations language
    in
    div
        [ style "position" "relative"
        , style "display" "flex"
        ]
        [ button
            [ onClick ToggleSettings
            , style "padding" "11px 16px"
            , style "background-color" theme.btnSecondaryBg
            , style "color" "white"
            , style "border" "none"
            , style "border-radius" "5px"
            , style "cursor" "pointer"
            , style "font-size" "14px"
            , style "font-weight" "bold"
            ]
            [ text "⚙" ]
        , if settingsOpen then
            div
                [ style "position" "absolute"
                , style "top" "calc(100% + 6px)"
                , style "right" "0"
                , style "background-color" theme.settingsBg
                , style "border" ("1px solid " ++ theme.settingsBorder)
                , style "border-radius" "6px"
                , style "padding" "12px 16px"
                , style "min-width" "180px"
                , style "z-index" "2000"
                , style "display" "flex"
                , style "flex-direction" "column"
                , style "gap" "10px"
                ]
                [ div
                    [ style "color" "white"
                    , style "font-size" "13px"
                    , style "display" "flex"
                    , style "align-items" "center"
                    , style "justify-content" "space-between"
                    , style "gap" "10px"
                    ]
                    [ text t.darkMode
                    , pillToggle ToggleDarkMode darkMode
                    ]
                , div
                    [ style "color" "white"
                    , style "font-size" "13px"
                    , style "display" "flex"
                    , style "align-items" "center"
                    , style "justify-content" "space-between"
                    , style "gap" "10px"
                    ]
                    [ text t.language
                    , languageToggleBtn t ToggleLanguage
                    ]
                ]
          else
            div [] []
        ]


pillToggle : msg -> Bool -> Html msg
pillToggle toggleMsg isOn =
    div
        [ onClick toggleMsg
        , style "width" "40px"
        , style "height" "20px"
        , style "border-radius" "10px"
        , style "background-color" (if isOn then "#0288d1" else "#607d8b")
        , style "position" "relative"
        , style "cursor" "pointer"
        , style "flex-shrink" "0"
        , style "transition" "background-color 0.2s"
        ]
        [ div
            [ style "width" "16px"
            , style "height" "16px"
            , style "border-radius" "50%"
            , style "background-color" "white"
            , style "position" "absolute"
            , style "top" "2px"
            , style "left" (if isOn then "22px" else "2px")
            , style "transition" "left 0.2s"
            ]
            []
        ]


languageToggleBtn : Translations.Translations -> msg -> Html msg
languageToggleBtn t onToggle =
    button
        [ onClick onToggle
        , style "background" "#37474f"
        , style "color" "white"
        , style "border" "none"
        , style "border-radius" "4px"
        , style "padding" "2px 8px"
        , style "font-size" "12px"
        , style "cursor" "pointer"
        ]
        [ text t.languageName ]


replaceIcon : Html msg
replaceIcon =
    Svg.svg
        [ SA.width "16", SA.height "16", SA.viewBox "0 0 52 52", SA.fill "currentColor" ]
        [ Svg.path [ SA.d "M20,37.5c0-0.8-0.7-1.5-1.5-1.5h-15C2.7,36,2,36.7,2,37.5v11C2,49.3,2.7,50,3.5,50h15c0.8,0,1.5-0.7,1.5-1.5V37.5z" ] []
        , Svg.path [ SA.d "M8.1,22H3.2c-1,0-1.5,0.9-0.9,1.4l8,8.3c0.4,0.3,1,0.3,1.4,0l8-8.3c0.6-0.6,0.1-1.4-0.9-1.4h-4.7c0-5,4.9-10,9.9-10V6C15,6,8.1,13,8.1,22z" ] []
        , Svg.path [ SA.d "M41.8,20.3c-0.4-0.3-1-0.3-1.4,0l-8,8.3c-0.6,0.6-0.1,1.4,0.9,1.4h4.8c0,6-4.1,10-10.1,10v6c9,0,16.1-7,16.1-16H49c1,0,1.5-0.9,0.9-1.4L41.8,20.3z" ] []
        , Svg.path [ SA.d "M50,3.5C50,2.7,49.3,2,48.5,2h-15C32.7,2,32,2.7,32,3.5v11c0,0.8,0.7,1.5,1.5,1.5h15c0.8,0,1.5-0.7,1.5-1.5V3.5z" ] []
        ]


saveIcon : Html msg
saveIcon =
    Svg.svg
        [ SA.width "16", SA.height "16", SA.viewBox "0 0 24 24", SA.fill "currentColor" ]
        [ Svg.path [ SA.fillRule "evenodd", SA.clipRule "evenodd", SA.d "M18.1716 1C18.702 1 19.2107 1.21071 19.5858 1.58579L22.4142 4.41421C22.7893 4.78929 23 5.29799 23 5.82843V20C23 21.6569 21.6569 23 20 23H4C2.34315 23 1 21.6569 1 20V4C1 2.34315 2.34315 1 4 1H18.1716ZM4 3C3.44772 3 3 3.44772 3 4V20C3 20.5523 3.44772 21 4 21L5 21L5 15C5 13.3431 6.34315 12 8 12L16 12C17.6569 12 19 13.3431 19 15V21H20C20.5523 21 21 20.5523 21 20V6.82843C21 6.29799 20.7893 5.78929 20.4142 5.41421L18.5858 3.58579C18.2107 3.21071 17.702 3 17.1716 3H17V5C17 6.65685 15.6569 8 14 8H10C8.34315 8 7 6.65685 7 5V3H4ZM17 21V15C17 14.4477 16.5523 14 16 14L8 14C7.44772 14 7 14.4477 7 15L7 21L17 21ZM9 3H15V5C15 5.55228 14.5523 6 14 6H10C9.44772 6 9 5.55228 9 5V3Z" ] []
        ]


iconActionBtn : Theme.Theme -> Html Msg -> String -> Msg -> Bool -> Html Msg
iconActionBtn theme icon label msg isEnabled =
    button
        [ onClick msg
        , style "padding" "11px 18px"
        , style "background-color" (if isEnabled then theme.btnPrimary else theme.btnDisabledBg)
        , style "color" (if isEnabled then "white" else theme.btnDisabledText)
        , style "border" "none"
        , style "border-radius" "5px"
        , style "cursor" (if isEnabled then "pointer" else "not-allowed")
        , style "font-size" "14px"
        , style "font-weight" "bold"
        , style "display" "flex"
        , style "align-items" "center"
        , style "gap" "6px"
        , disabled (not isEnabled)
        ]
        [ icon, text label ]


navBtn : Theme.Theme -> String -> Msg -> Bool -> Html Msg
navBtn theme label msg isDisabled =
    button
        [ onClick msg
        , style "padding" "11px 16px"
        , style "background-color" (if isDisabled then theme.btnDisabledBg else theme.btnSecondaryBg)
        , style "color" (if isDisabled then theme.btnDisabledText else "white")
        , style "border" "none"
        , style "border-radius" "5px"
        , style "cursor" (if isDisabled then "not-allowed" else "pointer")
        , style "font-size" "14px"
        , disabled isDisabled
        ]
        [ text label ]


actionBtn : Theme.Theme -> String -> Msg -> Bool -> Html Msg
actionBtn theme label msg isEnabled =
    button
        [ onClick msg
        , style "padding" "11px 18px"
        , style "background-color" (if isEnabled then theme.btnPrimary else theme.btnDisabledBg)
        , style "color" (if isEnabled then "white" else theme.btnDisabledText)
        , style "border" "none"
        , style "border-radius" "5px"
        , style "cursor" (if isEnabled then "pointer" else "not-allowed")
        , style "font-size" "14px"
        , style "font-weight" "bold"
        , disabled (not isEnabled)
        ]
        [ text label ]


colorBtn : Theme.Theme -> String -> String -> Msg -> Bool -> Html Msg
colorBtn theme label color msg isEnabled =
    button
        [ onClick msg
        , style "padding" "11px 18px"
        , style "background-color" (if isEnabled then color else theme.btnDisabledBg)
        , style "color" (if isEnabled then "white" else theme.btnDisabledText)
        , style "border" "none"
        , style "border-radius" "5px"
        , style "cursor" (if isEnabled then "pointer" else "not-allowed")
        , style "font-size" "14px"
        , style "font-weight" "bold"
        , disabled (not isEnabled)
        ]
        [ text label ]


guideColorBtn : Theme.Theme -> String -> Msg -> Html Msg
guideColorBtn theme label msg =
    button
        [ onClick msg
        , style "padding" "11px 18px"
        , style "background-color" theme.btnGuide
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
            [ src "icons/guide_icon.png"
            , style "width" "20px"
            , style "height" "20px"
            , style "filter" "brightness(0) invert(1)"
            ]
            []
        , text label
        ]


-- CANVAS


viewCanvas : Theme.Theme -> Model -> Maybe StepSnapshot -> Html Msg
viewCanvas theme model maybeSnap =
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
        , theme = theme
        }


-- RIGHT PANEL


viewRightPanel : Theme.Theme -> Model -> Maybe StepSnapshot -> Html Msg
viewRightPanel theme model maybeSnap =
    let
        t =
            Translations.getTranslations model.language

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
        , style "background-color" theme.rightPanelBg
        , style "border-left" ("2px solid " ++ theme.rightPanelBorder)
        , style "display" "flex"
        , style "flex-direction" "column"
        , style "overflow" "hidden"
        ]
        [ panelHeader theme theme.convSectionHeaderBg t.convStepDescription
        , div
            [ style "padding" "10px 12px"
            , style "font-size" "12px"
            , style "line-height" "1.5"
            , style "background-color" theme.convStepDescBg
            , style "border-bottom" ("1px solid " ++ theme.separatorColor)
            , style "min-height" "54px"
            , style "color" theme.textPrimary
            ]
            [ text (stepExplanation t model.nfa.states snap.states snap.step) ]
        , panelHeader theme theme.convSectionHeaderBg t.convOriginalNfaStates
        , div [ style "max-height" "120px", style "overflow-y" "auto", style "border-bottom" ("1px solid " ++ theme.separatorColor) ]
            [ viewNfaTable theme t model.nfa.states ]
        , panelHeader theme theme.convSectionHeaderBg t.convSubsetTable
        , div [ style "flex" "1", style "overflow-y" "auto", style "overflow-x" "auto" ]
            [ viewWorktable theme t snap alph model.highlightDfaStateId currentSymbol ]
        ]


panelHeader : Theme.Theme -> String -> String -> Html Msg
panelHeader theme bgColor title =
    div
        [ style "padding" "8px 12px"
        , style "font-weight" "bold"
        , style "font-size" "12px"
        , style "background-color" bgColor
        , style "border-bottom" ("1px solid " ++ theme.separatorColor)
        , style "color" theme.textPrimary
        ]
        [ text title ]


-- NFA TABLE


viewNfaTable : Theme.Theme -> Translations.Translations -> List State -> Html Msg
viewNfaTable theme t states =
    table [ style "border-collapse" "collapse", style "font-size" "12px", style "width" "100%" ]
        [ thead []
            [ tr []
                [ tableHeader theme "left" t.convStateColumn
                , tableHeader theme "center" t.convStartColumn
                , tableHeader theme "center" t.convEndColumn
                ]
            ]
        , tbody [] (List.map (viewNfaRow theme) states)
        ]


viewNfaRow : Theme.Theme -> State -> Html Msg
viewNfaRow theme state =
    tr []
        [ td [ style "padding" "2px 8px", style "border-top" ("1px solid " ++ theme.separatorColor), style "font-size" "11px", style "color" theme.textPrimary ] [ text state.label ]
        , td [ style "padding" "2px 8px", style "text-align" "center", style "border-top" ("1px solid " ++ theme.separatorColor), style "font-size" "11px", style "color" theme.textPrimary ] [ text (if state.isStart then "✓" else "") ]
        , td [ style "padding" "2px 8px", style "text-align" "center", style "border-top" ("1px solid " ++ theme.separatorColor), style "font-size" "11px", style "color" theme.textPrimary ] [ text (if state.isEnd then "✓" else "") ]
        ]


tableHeader : Theme.Theme -> String -> String -> Html Msg
tableHeader theme align label =
    th
        [ style "padding" "4px 8px"
        , style "text-align" align
        , style "background" theme.convTableHeaderBg
        , style "font-size" "11px"
        , style "color" theme.textPrimary
        ]
        [ text label ]


-- WORKTABLE


viewWorktable : Theme.Theme -> Translations.Translations -> StepSnapshot -> List String -> Maybe Int -> Maybe String -> Html Msg
viewWorktable theme t snap alph highlightStateId highlightSymbol =
    table [ style "border-collapse" "collapse", style "font-size" "11px", style "width" "100%" ]
        [ thead []
            [ tr []
                ([ th
                    [ style "padding" "4px 8px"
                    , style "text-align" "left"
                    , style "background" theme.convTableHeaderBg
                    , style "white-space" "nowrap"
                    , style "position" "sticky"
                    , style "top" "0"
                    , style "color" theme.textPrimary
                    ]
                          [ text t.convDfaStateColumn ]
                 ]
                    ++ List.map (worktableColHeader theme highlightSymbol) alph
                )
            ]
        , tbody []
            (List.map (viewWorktableRow theme snap alph highlightStateId highlightSymbol) snap.states)
        ]


worktableColHeader : Theme.Theme -> Maybe String -> String -> Html Msg
worktableColHeader theme highlightSymbol sym =
    th
        [ style "padding" "4px 8px"
        , style "text-align" "center"
        , style "background" (if highlightSymbol == Just sym then theme.convTableColHeaderHighlight else theme.convTableHeaderBg)
        , style "white-space" "nowrap"
        , style "position" "sticky"
        , style "top" "0"
        , style "color" theme.textPrimary
        ]
        [ text sym ]


viewWorktableRow : Theme.Theme -> StepSnapshot -> List String -> Maybe Int -> Maybe String -> DfaSubsetState -> Html Msg
viewWorktableRow theme snap alph highlightStateId highlightSymbol state =
    let
        isRowHighlighted =
            highlightStateId == Just state.id

        rowBg =
            if isRowHighlighted then theme.convTableRowHighlight else "transparent"

        isProcessed =
            List.member state.id snap.processedIds
    in
    tr []
        ([ td
            [ style "padding" "3px 8px"
            , style "border-top" ("1px solid " ++ theme.separatorColor)
            , style "background-color" rowBg
            , style "white-space" "nowrap"
            , style "font-weight" "bold"
            , style "color" theme.textPrimary
            ]
            [ text state.label ]
         ]
            ++ List.map (worktableCell theme snap isRowHighlighted isProcessed rowBg highlightSymbol state.id) alph
        )


worktableCell : Theme.Theme -> StepSnapshot -> Bool -> Bool -> String -> Maybe String -> Int -> String -> Html Msg
worktableCell theme snap isRowHighlighted isProcessed rowBg highlightSymbol stateId sym =
    let
        cellBg =
            if isRowHighlighted && highlightSymbol == Just sym then
                theme.convTableCellHighlight
            else if isRowHighlighted then
                rowBg
            else if highlightSymbol == Just sym then
                theme.convTableColHighlight
            else
                "transparent"

        target =
            List.filter (\t -> t.from == stateId && t.symbol == sym) snap.transitions
                |> List.head
                |> Maybe.andThen (\t -> List.filter (\s -> s.id == t.to) snap.states |> List.head)
                |> Maybe.map .label

        cellText =
            if isProcessed then
                Maybe.withDefault "-" target
            else
                Maybe.withDefault "" target
    in
    td
        [ style "padding" "3px 8px"
        , style "text-align" "center"
        , style "border-top" ("1px solid " ++ theme.separatorColor)
        , style "background-color" cellBg
        , style "color" theme.textPrimary
        ]
        [ text cellText ]


-- SAVE MODAL


viewSaveModal : Theme.Theme -> Translations.Translations -> Model -> Html Msg
viewSaveModal theme t model =
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
                [ style "background" theme.modalBg
                , style "padding" "24px"
                , style "border-radius" "8px"
                , style "display" "flex"
                , style "flex-direction" "column"
                , style "gap" "12px"
                , style "min-width" "260px"
                ]
                [ div [ style "font-weight" "bold", style "font-size" "16px", style "color" theme.textPrimary ] [ text t.saveDfa ]
                , input
                    [ type_ "text"
                    , placeholder t.editorAutomatonNamePlaceholder
                    , value model.saveNameInput
                    , onInput UpdateSaveNameInput
                    , autofocus True
                    , style "padding" "8px"
                    , style "border" ("1px solid " ++ theme.inputBorder)
                    , style "border-radius" "5px"
                    , style "font-size" "14px"
                    , style "background-color" theme.inputBg
                    , style "color" theme.inputText
                    ]
                    []
                , button
                    [ onClick ConfirmSaveToStorage
                    , style "padding" "10px"
                    , style "background-color" theme.btnSecondaryBg
                    , style "color" "white"
                    , style "border" "none"
                    , style "border-radius" "5px"
                    , style "cursor" "pointer"
                    , style "font-size" "14px"
                    ]
                    [ text t.save ]
                , button
                    [ onClick DismissSaveModal
                    , style "padding" "8px"
                    , style "background-color" theme.btnDelete
                    , style "color" "white"
                    , style "border" "none"
                    , style "border-radius" "5px"
                    , style "cursor" "pointer"
                    , style "font-size" "13px"
                    ]
                    [ text t.cancel ]
                ]
            ]
