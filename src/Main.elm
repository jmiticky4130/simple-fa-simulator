port module Main exposing (..)

import Browser
import Browser.Events
import Html exposing (Html, div, button, text, span, h3, p, ul, li, strong, a)
import Html.Attributes exposing (style, href, target)
import Html.Events exposing (onClick)
import Json.Decode as Decode
import Set
import Pages.Editor as Editor
import Pages.Simulator as Simulator
import Pages.Conversion as Conversion
import Shared exposing (AutomatonState)
import UndoList
import Utils.AutomatonCodec
import Utils.ExampleAutomata as ExampleAutomata
import Utils.Theme as Theme
import Utils.Translations as Translations exposing (Language(..))


port setUrlHash : String -> Cmd msg

port saveNamedAutomaton : { name : String, data : String } -> Cmd msg

port deleteNamedAutomaton : String -> Cmd msg

port requestStoredAutomata : () -> Cmd msg

port storedAutomataLoaded : (List { name : String, data : String } -> msg) -> Sub msg

port saveDarkMode : Bool -> Cmd msg

port saveLanguage : String -> Cmd msg

port saveTutorialSeen : () -> Cmd msg

port copyToClipboard : String -> Cmd msg

port scrollToBottom : String -> Cmd msg


type Page
    = EditorPage
    | SimulatorPage
    | ConversionPage


type TutorialStep
    = TutWelcome
    | TutCreateState1
    | TutCreateState2
    | TutSetStart
    | TutSetEnd
    | TutCreateTransition
    | TutSimulateButton
    | TutEnterInput
    | TutRunSimulation


type GuideTab
    = GuideEditor
    | GuideSimulator
    | GuideConversion
    | GuideErrors
    | GuideAbout


type alias Model =
    { currentPage : Page
    , editorModel : Editor.Model
    , simulatorModel : Simulator.Model
    , conversionModel : Conversion.Model
    , showGuide : Bool
    , guideTab : GuideTab
    , consoleOpen : Bool
    , darkMode : Bool
    , settingsOpen : Bool
    , language : Language
    , windowWidth : Int
    , windowHeight : Int
    , tutorialStep : Maybe TutorialStep
    }


type alias Flags =
    { urlData : Maybe String
    , darkMode : Bool
    , language : String
    , windowWidth : Int
    , windowHeight : Int
    , hasSeenTutorial : Bool
    }


flagsDecoder : Decode.Decoder Flags
flagsDecoder =
    Decode.map6 Flags
        (Decode.maybe (Decode.field "urlData" Decode.string))
        (Decode.field "darkMode" Decode.bool)
        (Decode.field "language" Decode.string)
        (Decode.field "windowWidth" Decode.int)
        (Decode.field "windowHeight" Decode.int)
        (Decode.field "hasSeenTutorial" Decode.bool)


init : Decode.Value -> ( Model, Cmd Msg )
init flagsValue =
    let
        flags =
            case Decode.decodeValue flagsDecoder flagsValue of
                Ok f -> f
                Err _ -> { urlData = Nothing, darkMode = False, language = "sk", windowWidth = 1200, windowHeight = 800, hasSeenTutorial = False }

        lang =
            if flags.language == "en" then English else Slovak

        loadedAutomaton =
            flags.urlData
                |> Maybe.andThen (Decode.decodeString Utils.AutomatonCodec.decoder >> Result.toMaybe)

        editorInit =
            Editor.initWith lang loadedAutomaton

        simulatorInit =
            Simulator.init lang { states = [], transitions = [], nextStateId = 0 }

        conversionInit =
            Conversion.init lang { states = [], transitions = [], nextStateId = 0 }
    in
    ( { currentPage = EditorPage
      , editorModel = editorInit
      , simulatorModel = simulatorInit
      , conversionModel = conversionInit
      , showGuide = False
      , guideTab = GuideEditor
      , consoleOpen = True
      , darkMode = flags.darkMode
      , settingsOpen = False
      , language = lang
      , windowWidth = flags.windowWidth
      , windowHeight = flags.windowHeight
      , tutorialStep = if not flags.hasSeenTutorial then Just TutWelcome else Nothing
      }
    , Cmd.none
    )


setLanguageForAllPages : Language -> Model -> Model
setLanguageForAllPages newLang model =
    let
        currentEditorModel =
            model.editorModel

        currentSimulatorModel =
            model.simulatorModel

        currentConversionModel =
            model.conversionModel

        editorModel =
            { currentEditorModel | language = newLang }

        simulatorModel =
            { currentSimulatorModel | language = newLang }

        conversionModel =
            { currentConversionModel | language = newLang }
    in
    { model
        | language = newLang
        , editorModel = editorModel
        , simulatorModel = simulatorModel
        , conversionModel = conversionModel
    }


type Msg
    = EditorMsg Editor.Msg
    | SimulatorMsg Simulator.Msg
    | ConversionMsg Conversion.Msg
    | SwitchToEditor
    | CloseGuide
    | SetGuideTab GuideTab
    | GuideLoadExample AutomatonState
    | NoOp
    | ToggleDarkMode
    | ToggleSettings
    | CloseSettings
    | ToggleLanguage
    | WindowResize Int Int
    | StartTutorial
    | TutorialSkip
    | TutorialWelcomeContinue


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EditorMsg editorMsg ->
            case editorMsg of
                Editor.ToggleConsole ->
                    ( { model | consoleOpen = not model.consoleOpen }, Cmd.none )

                Editor.ShowGuide ->
                    ( { model | showGuide = True, guideTab = GuideEditor }, Cmd.none )

                Editor.ShowAboutGuide ->
                    ( { model | showGuide = True, guideTab = GuideAbout }, Cmd.none )

                Editor.SwitchToConversion ->
                    ( { model
                        | currentPage = ConversionPage
                                                , conversionModel = Conversion.init model.language model.editorModel.automaton.present
                      }
                    , Cmd.none
                    )

                Editor.SwitchToSimulator ->
                    let
                        currentAutomaton = model.editorModel.automaton.present
                        simulatorInit = Simulator.init model.language currentAutomaton
                        newTutorialStep =
                            case model.tutorialStep of
                                Just TutSimulateButton -> Just TutEnterInput
                                other -> other
                    in
                    ( { model
                        | currentPage = SimulatorPage
                        , simulatorModel = simulatorInit
                        , tutorialStep = newTutorialStep
                      }
                    , Cmd.none
                    )

                Editor.ShareUrl ->
                    let
                        ( newEditorModel, editorCmd ) =
                            Editor.update editorMsg model.editorModel
                    in
                    ( { model | editorModel = newEditorModel }
                    , Cmd.batch [ Cmd.map EditorMsg editorCmd, setUrlHash (Utils.AutomatonCodec.encode model.editorModel.automaton.present) ]
                    )

                Editor.ConfirmSave ->
                    let
                        name = String.trim model.editorModel.saveNameInput
                        ( newEditorModel, editorCmd ) =
                            Editor.update editorMsg model.editorModel
                    in
                    if String.isEmpty name then
                        ( { model | editorModel = newEditorModel }
                        , Cmd.map EditorMsg editorCmd
                        )
                    else
                        ( { model | editorModel = newEditorModel }
                        , Cmd.batch
                            [ Cmd.map EditorMsg editorCmd
                            , saveNamedAutomaton { name = name, data = Utils.AutomatonCodec.encode model.editorModel.automaton.present }
                            ]
                        )

                Editor.LoadRequested ->
                    let
                        ( newEditorModel, editorCmd ) =
                            Editor.update editorMsg model.editorModel
                    in
                    ( { model | editorModel = newEditorModel }
                    , Cmd.batch [ Cmd.map EditorMsg editorCmd, requestStoredAutomata () ]
                    )

                Editor.LoadFromStorage ->
                    let
                        ( newEditorModel, editorCmd ) =
                            Editor.update editorMsg model.editorModel
                    in
                    ( { model | editorModel = newEditorModel }
                    , Cmd.batch [ Cmd.map EditorMsg editorCmd, requestStoredAutomata () ]
                    )

                Editor.DeleteStoredAutomaton name ->
                    let
                        ( newEditorModel, editorCmd ) =
                            Editor.update editorMsg model.editorModel
                    in
                    ( { model | editorModel = newEditorModel }
                    , Cmd.batch [ Cmd.map EditorMsg editorCmd, deleteNamedAutomaton name, requestStoredAutomata () ]
                    )

                Editor.ToggleSettings ->
                    ( { model | settingsOpen = not model.settingsOpen }, Cmd.none )

                Editor.ToggleDarkMode ->
                    let
                        newDark = not model.darkMode
                    in
                    ( { model | darkMode = newDark }, saveDarkMode newDark )

                Editor.ToggleLanguage ->
                    let
                        newLang = if model.language == Slovak then English else Slovak
                        langStr = if newLang == English then "en" else "sk"
                    in
                    ( setLanguageForAllPages newLang model
                    , saveLanguage langStr
                    )

                Editor.CopyDefinition ->
                    let
                        ( newEditorModel, editorCmd ) =
                            Editor.update editorMsg model.editorModel
                        automaton = model.editorModel.automaton.present
                        t = Translations.getTranslations model.language
                        defText = formatDefinitionText t.notSelected automaton.states automaton.transitions
                    in
                    ( { model | editorModel = newEditorModel }
                    , Cmd.batch [ Cmd.map EditorMsg editorCmd, copyToClipboard defText ]
                    )

                _ ->
                    let
                        ( newEditorModel, editorCmd ) =
                            Editor.update editorMsg model.editorModel
                        newTutorialStep =
                            advanceTutorialEditor model.tutorialStep newEditorModel
                    in
                    ( { model | editorModel = newEditorModel, tutorialStep = newTutorialStep }
                    , Cmd.map EditorMsg editorCmd
                    )

        SimulatorMsg simulatorMsg ->
            let
                sim =
                    model.simulatorModel
            in
            case simulatorMsg of
                Simulator.ToggleConsole ->
                    ( { model | consoleOpen = not model.consoleOpen }, Cmd.none )

                Simulator.SwitchToEditor ->
                    ( { model
                        | currentPage = EditorPage
                        , simulatorModel = { sim | autoRunning = False }
                      }
                    , Cmd.none
                    )

                Simulator.ShowGuide ->
                    ( { model | showGuide = True, guideTab = GuideSimulator }, Cmd.none )

                Simulator.ToggleSettings ->
                    ( { model | settingsOpen = not model.settingsOpen }, Cmd.none )

                Simulator.ToggleDarkMode ->
                    let
                        newDark = not model.darkMode
                    in
                    ( { model | darkMode = newDark }, saveDarkMode newDark )

                Simulator.ToggleLanguage ->
                    let
                        newLang = if model.language == Slovak then English else Slovak
                        langStr = if newLang == English then "en" else "sk"
                    in
                    ( setLanguageForAllPages newLang model
                    , saveLanguage langStr
                    )

                _ ->
                    let
                        newSimulatorModel =
                            Simulator.update simulatorMsg model.simulatorModel

                        shouldScrollTree =
                            newSimulatorModel.showTree
                                && newSimulatorModel.mode == Simulator.NfaMode
                                && (case simulatorMsg of
                                        Simulator.StepForward -> True
                                        Simulator.AutoStep _ -> True
                                        _ -> False
                                   )

                        ( newTutorialStep, tutorialCmd ) =
                            advanceTutorialSimulator model.tutorialStep simulatorMsg newSimulatorModel
                    in
                    ( { model | simulatorModel = newSimulatorModel, tutorialStep = newTutorialStep }
                    , Cmd.batch
                        [ if shouldScrollTree then scrollToBottom "nfa-tree-scroll" else Cmd.none
                        , tutorialCmd
                        ]
                    )

        ConversionMsg convMsg ->
            case convMsg of
                Conversion.ToggleConsole ->
                    ( { model | consoleOpen = not model.consoleOpen }, Cmd.none )

                Conversion.SwitchToEditor ->
                    ( { model | currentPage = EditorPage }, Cmd.none )

                Conversion.ShowGuide ->
                    ( { model | showGuide = True, guideTab = GuideConversion }, Cmd.none )

                Conversion.ToggleSettings ->
                    ( { model | settingsOpen = not model.settingsOpen }, Cmd.none )

                Conversion.ToggleDarkMode ->
                    let
                        newDark = not model.darkMode
                    in
                    ( { model | darkMode = newDark }, saveDarkMode newDark )

                Conversion.ToggleLanguage ->
                    let
                        newLang = if model.language == Slovak then English else Slovak
                        langStr = if newLang == English then "en" else "sk"
                    in
                    ( setLanguageForAllPages newLang model
                    , saveLanguage langStr
                    )

                Conversion.ReplaceAutomaton ->
                    let
                        builtDfa =
                            Conversion.conversionResultToAutomaton model.conversionModel

                        em =
                            model.editorModel
                    in
                    ( { model
                        | currentPage = EditorPage
                        , editorModel = { em | automaton = UndoList.new builtDfa em.automaton }
                      }
                    , Cmd.none
                    )

                Conversion.ConfirmSaveToStorage ->
                    let
                        name =
                            String.trim model.conversionModel.saveNameInput

                        builtDfa =
                            Conversion.conversionResultToAutomaton model.conversionModel

                        newConvModel =
                            Conversion.update Conversion.DismissSaveModal model.conversionModel
                    in
                    ( { model | conversionModel = newConvModel }
                    , if String.isEmpty name then
                        Cmd.none
                      else
                        saveNamedAutomaton { name = name, data = Utils.AutomatonCodec.encode builtDfa }
                    )

                _ ->
                    ( { model | conversionModel = Conversion.update convMsg model.conversionModel }
                    , Cmd.none
                    )

        SwitchToEditor ->
            ( { model | currentPage = EditorPage }
            , Cmd.none
            )

        CloseGuide ->
            ( { model | showGuide = False }, Cmd.none )

        SetGuideTab tab ->
            ( { model | guideTab = tab }, Cmd.none )

        GuideLoadExample automaton ->
            let
                em = model.editorModel
            in
            ( { model
                | currentPage = EditorPage
                , showGuide = False
                , editorModel = { em | automaton = UndoList.fresh automaton }
              }
            , Cmd.none
            )

        NoOp ->
            ( model, Cmd.none )

        ToggleDarkMode ->
            let
                newDark = not model.darkMode
            in
            ( { model | darkMode = newDark }, saveDarkMode newDark )

        ToggleSettings ->
            ( { model | settingsOpen = not model.settingsOpen }, Cmd.none )

        CloseSettings ->
            ( { model | settingsOpen = False }, Cmd.none )

        ToggleLanguage ->
            let
                newLang = if model.language == Slovak then English else Slovak
                langStr = if newLang == English then "en" else "sk"
            in
            ( setLanguageForAllPages newLang model
            , saveLanguage langStr
            )

        WindowResize w h ->
            ( { model | windowWidth = w, windowHeight = h }, Cmd.none )

        TutorialWelcomeContinue ->
            ( { model | tutorialStep = Just TutCreateState1 }, Cmd.none )

        TutorialSkip ->
            ( { model | tutorialStep = Nothing }, saveTutorialSeen () )

        StartTutorial ->
            let
                em = model.editorModel
                emptyAutomaton = { states = [], transitions = [], nextStateId = 0 }
            in
            ( { model
                | tutorialStep = Just TutCreateState1
                , showGuide = False
                , currentPage = EditorPage
                , editorModel = { em | automaton = UndoList.fresh emptyAutomaton }
              }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        resizeSub = Browser.Events.onResize WindowResize
    in
    case model.currentPage of
        EditorPage ->
            Sub.batch
                [ Browser.Events.onKeyDown (keyDecoder model)
                , storedAutomataLoaded (\list -> EditorMsg (Editor.StorageAutomataLoaded list))
                , resizeSub
                ]

        SimulatorPage ->
            Sub.batch
                [ Sub.map SimulatorMsg (Simulator.subscriptions model.simulatorModel)
                , resizeSub
                ]

        ConversionPage ->
            resizeSub


keyDecoder : Model -> Decode.Decoder Msg
keyDecoder model =
    Decode.map4 (\key ctrl shift tagName ->
        let
            isTyping = tagName == "INPUT" || tagName == "TEXTAREA"
        in
        if key == "Escape" then
            if model.tutorialStep /= Nothing then TutorialSkip
            else if model.showGuide then CloseGuide
            else if model.settingsOpen then CloseSettings
            else if model.editorModel.showSaveModal then EditorMsg Editor.DismissSaveModal
            else if model.editorModel.showLoadModal then EditorMsg Editor.DismissLoadModal
            else EditorMsg Editor.CancelAction
        else if isTyping then EditorMsg Editor.NoOp
        else if ctrl && (key == "z" || key == "Z") then EditorMsg Editor.Undo
        else if ctrl && (key == "y" || key == "Y") then EditorMsg Editor.Redo
        else if shift && (key == "b" || key == "B") then EditorMsg (Editor.ChangeTool Editor.BuildTool)
        else if shift && (key == "d" || key == "D") then EditorMsg (Editor.ChangeTool Editor.DeleteTool)
        else EditorMsg Editor.NoOp
    )
    (Decode.field "key" Decode.string)
    (Decode.field "ctrlKey" Decode.bool)
    (Decode.field "shiftKey" Decode.bool)
    (Decode.at [ "target", "tagName" ] Decode.string)


view : Model -> Html Msg
view model =
    let
        theme = Theme.getTheme model.darkMode
        t = Translations.getTranslations model.language
    in
    div []
        [ if model.settingsOpen then
            div
                [ style "position" "fixed"
                , style "top" "0"
                , style "left" "0"
                , style "width" "100%"
                , style "height" "100%"
                , style "z-index" "1999"
                , onClick CloseSettings
                ]
                []
          else
            text ""
        , case model.currentPage of
            EditorPage ->
                Html.map EditorMsg (Editor.view model.consoleOpen model.darkMode model.settingsOpen model.language model.windowWidth model.windowHeight (model.tutorialStep == Just TutSimulateButton) model.editorModel)

            SimulatorPage ->
                div
                    [ style "display" "flex"
                    , style "flex-direction" "column"
                    , style "height" "100vh"
                    ]
                    [ Html.map SimulatorMsg (Simulator.view model.consoleOpen model.darkMode model.settingsOpen model.language (model.tutorialStep == Just TutEnterInput) (model.tutorialStep == Just TutRunSimulation) model.windowWidth model.windowHeight model.simulatorModel)
                    ]

            ConversionPage ->
                Html.map ConversionMsg (Conversion.view model.consoleOpen model.darkMode model.settingsOpen model.language model.conversionModel)

        , if model.showGuide then viewGuideModal theme t model else text ""
        , case model.tutorialStep of
            Just TutWelcome ->
                viewTutorialWelcome theme t model
            Just step ->
                div []
                    [ viewTutorialVeils theme step model.currentPage
                    , viewTutorialTooltip theme t step
                    ]
            Nothing ->
                text ""
        ]


-- TUTORIAL HELPERS


advanceTutorialEditor : Maybe TutorialStep -> Editor.Model -> Maybe TutorialStep
advanceTutorialEditor step edModel =
    let
        states = edModel.automaton.present.states
        transitions = edModel.automaton.present.transitions
    in
    case step of
        Just TutCreateState1 ->
            if List.length states >= 1 then Just TutCreateState2 else step
        Just TutCreateState2 ->
            if List.length states >= 2 then Just TutSetStart else step
        Just TutSetStart ->
            if List.any .isStart states then Just TutSetEnd else step
        Just TutSetEnd ->
            if List.any .isEnd states then Just TutCreateTransition else step
        Just TutCreateTransition ->
            if List.length transitions >= 1 then Just TutSimulateButton else step
        _ ->
            step


advanceTutorialSimulator : Maybe TutorialStep -> Simulator.Msg -> Simulator.Model -> ( Maybe TutorialStep, Cmd Msg )
advanceTutorialSimulator step simMsg simModel =
    case step of
        Just TutEnterInput ->
            if simModel.inputString /= "" then
                ( Just TutRunSimulation, Cmd.none )
            else
                ( step, Cmd.none )

        Just TutRunSimulation ->
            case simMsg of
                Simulator.StepForward ->
                    ( Nothing, saveTutorialSeen () )

                Simulator.AutoStep _ ->
                    ( Nothing, saveTutorialSeen () )

                _ ->
                    ( step, Cmd.none )

        _ ->
            ( step, Cmd.none )


tutorialStepIndex : TutorialStep -> Int
tutorialStepIndex step =
    case step of
        TutWelcome -> 0
        TutCreateState1 -> 1
        TutCreateState2 -> 2
        TutSetStart -> 3
        TutSetEnd -> 4
        TutCreateTransition -> 5
        TutSimulateButton -> 6
        TutEnterInput -> 7
        TutRunSimulation -> 8


tutorialStepText : Translations.Translations -> TutorialStep -> String
tutorialStepText t step =
    case step of
        TutWelcome -> ""
        TutCreateState1 -> t.tutStep1
        TutCreateState2 -> t.tutStep2
        TutSetStart -> t.tutStep3
        TutSetEnd -> t.tutStep4
        TutCreateTransition -> t.tutStep5
        TutSimulateButton -> t.tutStep6
        TutEnterInput -> t.tutStep7
        TutRunSimulation -> t.tutStep8


-- TUTORIAL VIEWS


viewTutorialWelcome : Theme.Theme -> Translations.Translations -> Model -> Html Msg
viewTutorialWelcome theme t model =
    div
        [ style "position" "fixed"
        , style "top" "0"
        , style "left" "0"
        , style "width" "100%"
        , style "height" "100%"
        , style "background-color" "rgba(0,0,0,0.7)"
        , style "z-index" "3000"
        , style "display" "flex"
        , style "align-items" "center"
        , style "justify-content" "center"
        ]
        [ div
            [ style "background" theme.modalBg
            , style "border-radius" "12px"
            , style "width" "420px"
            , style "max-width" "96vw"
            , style "padding" "32px"
            , style "box-shadow" "0 8px 32px rgba(0,0,0,0.5)"
            , style "font-family" "sans-serif"
            ]
            [ div
                [ style "font-size" "22px"
                , style "font-weight" "bold"
                , style "color" theme.textPrimary
                , style "margin-bottom" "10px"
                ]
                [ text t.tutWelcomeTitle ]
            , div
                [ style "font-size" "14px"
                , style "color" theme.textSecondary
                , style "margin-bottom" "24px"
                , style "line-height" "1.6"
                ]
                [ text t.tutWelcomeBody ]
            , div
                [ style "display" "flex"
                , style "align-items" "center"
                , style "justify-content" "space-between"
                , style "margin-bottom" "12px"
                ]
                [ div [ style "color" theme.textSecondary, style "font-size" "14px" ]
                    [ text t.darkMode ]
                , tutorialPillToggle ToggleDarkMode model.darkMode
                ]
            , div
                [ style "display" "flex"
                , style "align-items" "center"
                , style "justify-content" "space-between"
                , style "margin-bottom" "28px"
                ]
                [ div [ style "color" theme.textSecondary, style "font-size" "14px" ]
                    [ text t.language ]
                , button
                    [ onClick ToggleLanguage
                    , style "background" "#37474f"
                    , style "color" "white"
                    , style "border" "none"
                    , style "border-radius" "4px"
                    , style "padding" "4px 12px"
                    , style "font-size" "13px"
                    , style "cursor" "pointer"
                    ]
                    [ text t.languageName ]
                ]
            , button
                [ onClick TutorialWelcomeContinue
                , style "width" "100%"
                , style "padding" "13px"
                , style "background-color" theme.btnPrimary
                , style "color" "white"
                , style "border" "none"
                , style "border-radius" "6px"
                , style "font-size" "15px"
                , style "font-weight" "bold"
                , style "cursor" "pointer"
                , style "margin-bottom" "10px"
                ]
                [ text t.tutContinueToTutorial ]
            , div
                [ style "text-align" "center" ]
                [ button
                    [ onClick TutorialSkip
                    , style "background" "none"
                    , style "border" "none"
                    , style "color" theme.textMuted
                    , style "font-size" "13px"
                    , style "cursor" "pointer"
                    , style "text-decoration" "underline"
                    ]
                    [ text t.tutSkipTutorial ]
                ]
            ]
        ]


tutorialPillToggle : msg -> Bool -> Html msg
tutorialPillToggle onToggle isOn =
    div
        [ onClick onToggle
        , style "width" "40px"
        , style "height" "20px"
        , style "border-radius" "10px"
        , style "background-color" (if isOn then "#0288d1" else "#546e7a")
        , style "cursor" "pointer"
        , style "position" "relative"
        , style "flex-shrink" "0"
        ]
        [ div
            [ style "position" "absolute"
            , style "top" "2px"
            , style "left" (if isOn then "22px" else "2px")
            , style "width" "16px"
            , style "height" "16px"
            , style "border-radius" "50%"
            , style "background-color" "white"
            ]
            []
        ]


viewTutorialVeils : Theme.Theme -> TutorialStep -> Page -> Html Msg
viewTutorialVeils theme step currentPage =
    let
        veilLeft top left width height =
            div
                [ style "position" "fixed"
                , style "top" top
                , style "left" left
                , style "width" width
                , style "height" height
                , style "background-color" theme.tutorialVeilBg
                , style "z-index" "500"
                ]
                []

        veilRight top right width height =
            div
                [ style "position" "fixed"
                , style "top" top
                , style "right" right
                , style "width" width
                , style "height" height
                , style "background-color" theme.tutorialVeilBg
                , style "z-index" "500"
                ]
                []

        canvasPhaseVeils =
            div []
                [ veilLeft "0" "0" "100%" "80px"
                , veilRight "80px" "0" "302px" "calc(100vh - 80px)"
                ]
    in
    case currentPage of
        EditorPage ->
            case step of
                TutCreateState1 -> canvasPhaseVeils
                TutCreateState2 -> canvasPhaseVeils
                TutSetStart -> canvasPhaseVeils
                TutSetEnd -> canvasPhaseVeils
                TutCreateTransition -> canvasPhaseVeils

                TutSimulateButton ->
                    div []
                        [ veilLeft "80px" "0" "calc(100% - 302px)" "calc(100vh - 80px)"
                        , veilRight "80px" "0" "302px" "calc(100vh - 80px)"
                        ]

                _ ->
                    text ""

        _ ->
            text ""


viewTutorialTooltip : Theme.Theme -> Translations.Translations -> TutorialStep -> Html Msg
viewTutorialTooltip theme t step =
    let
        idx = tutorialStepIndex step
        total = 8
        instructionText = tutorialStepText t step
        showSkipOnly = step == TutSimulateButton
    in
    div
        [ style "position" "fixed"
        , style "bottom" "200px"
        , style "left" "calc((100vw - 302px) * 0.2)"
        , style "width" "calc((100vw - 302px) * 0.6)"
        , style "background-color" theme.tutorialTooltipBg
        , style "color" theme.tutorialTooltipText
        , style "z-index" "502"
        , style "display" "flex"
        , style "align-items" "center"
        , style "padding" "16px 20px"
        , style "box-sizing" "border-box"
        , style "border-radius" "12px"
        , style "box-shadow" "0 6px 32px rgba(0,0,0,0.6), 0 0 0 1px rgba(255,255,255,0.08)"
        , style "border" "2px solid rgba(255,255,255,0.5)"
        , style "gap" "16px"
        , style "font-family" "sans-serif"
        ]
        [ div
            [ style "background-color" "rgba(255,255,255,0.2)"
            , style "border-radius" "20px"
            , style "padding" "4px 12px"
            , style "font-size" "12px"
            , style "font-weight" "bold"
            , style "white-space" "nowrap"
            , style "flex-shrink" "0"
            ]
            [ text (String.fromInt idx ++ " / " ++ String.fromInt total) ]
        , div
            [ style "flex" "1"
            , style "font-size" "14px"
            , style "line-height" "1.5"
            ]
            [ text instructionText ]
        , div
            [ style "display" "flex"
            , style "gap" "8px"
            , style "flex-shrink" "0"
            ]
            [ button
                [ onClick TutorialSkip
                , style "background-color" "rgba(255,255,255,0.12)"
                , style "color" theme.tutorialTooltipText
                , style "border" "1px solid rgba(255,255,255,0.3)"
                , style "border-radius" "6px"
                , style "padding" "6px 14px"
                , style "font-size" "13px"
                , style "cursor" "pointer"
                ]
                [ text t.tutSkip ]
            , if showSkipOnly then
                text ""
              else if step == TutRunSimulation then
                button
                    [ onClick TutorialSkip
                    , style "background-color" theme.btnPrimary
                    , style "color" "white"
                    , style "border" "none"
                    , style "border-radius" "6px"
                    , style "padding" "6px 14px"
                    , style "font-size" "13px"
                    , style "font-weight" "bold"
                    , style "cursor" "pointer"
                    ]
                    [ text t.tutFinish ]
              else
                text ""
            ]
        ]


formatDefinitionText : String -> List Shared.State -> List Shared.Transition -> String
formatDefinitionText notSelected states transitions =
    let
        q = "Q = { " ++ String.join ", " (List.map .label states) ++ " }"

        alphabet =
            List.map .symbol transitions
                |> Set.fromList
                |> Set.toList
                |> List.sort

        sigma = "\u{03A3} = { " ++ String.join ", " alphabet ++ " }"

        startLabel =
            List.filter .isStart states
                |> List.head
                |> Maybe.map .label
                |> Maybe.withDefault notSelected

        q0 = "q0 = " ++ startLabel

        endLabels = List.filter .isEnd states |> List.map .label
        f = "F = { " ++ String.join ", " endLabels ++ " }"

        stateLabel id =
            List.filter (\s -> s.id == id) states
                |> List.head
                |> Maybe.map .label
                |> Maybe.withDefault "?"

        deltaLines =
            List.sortBy (\t -> ( t.from, t.to, t.symbol )) transitions
                |> List.map (\t -> "\u{03B4}(" ++ stateLabel t.from ++ ", " ++ t.symbol ++ ") = " ++ stateLabel t.to)
    in
    String.join "\n" ([ q, sigma, q0, f ] ++ deltaLines)


main : Program Decode.Value Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


-- GUIDE MODAL


viewGuideModal : Theme.Theme -> Translations.Translations -> Model -> Html Msg
viewGuideModal theme t model =
    div
        [ style "position" "fixed"
        , style "top" "0"
        , style "left" "0"
        , style "width" "100%"
        , style "height" "100%"
        , style "background-color" "rgba(0,0,0,0.6)"
        , style "z-index" "3000"
        , style "display" "flex"
        , style "align-items" "center"
        , style "justify-content" "center"
        , onClick CloseGuide
        ]
        [ div
            [ style "background" theme.modalBg
            , style "border-radius" "10px"
            , style "width" "740px"
            , style "max-width" "96vw"
            , style "max-height" "88vh"
            , style "display" "flex"
            , style "flex-direction" "column"
            , style "overflow" "hidden"
            , style "box-shadow" "0 8px 32px rgba(0,0,0,0.4)"
            , Html.Events.stopPropagationOn "click" (Decode.succeed ( NoOp, True ))
            ]
            [ viewGuideHeader theme t
            , viewGuideTabBar theme t model.guideTab
            , div
                [ style "flex" "1"
                , style "overflow-y" "auto"
                , style "padding" "20px 24px"
                , style "font-family" "sans-serif"
                , style "font-size" "13px"
                , style "line-height" "1.65"
                , style "color" theme.modalText
                ]
                [ viewGuideContent theme t model.language model.guideTab ]
            ]
        ]


viewGuideHeader : Theme.Theme -> Translations.Translations -> Html Msg
viewGuideHeader theme t =
    div
        [ style "display" "flex"
        , style "align-items" "center"
        , style "padding" "14px 20px"
        , style "background-color" theme.toolbarBg
        , style "color" "white"
        , style "flex-shrink" "0"
        ]
        [ div [ style "font-size" "17px", style "font-weight" "bold", style "flex" "1" ]
            [ text t.guideTitle ]
        , button
            [ onClick StartTutorial
            , style "background-color" "#00796b"
            , style "border" "none"
            , style "color" "white"
            , style "font-size" "13px"
            , style "font-weight" "bold"
            , style "cursor" "pointer"
            , style "padding" "6px 12px"
            , style "border-radius" "4px"
            , style "margin-right" "8px"
            ]
            [ text t.tutRelaunch ]
        , button
            [ onClick CloseGuide
            , style "background" "none"
            , style "border" "none"
            , style "color" "white"
            , style "font-size" "22px"
            , style "cursor" "pointer"
            , style "padding" "0 2px"
            , style "line-height" "1"
            ]
            [ text "x" ]
        ]


viewGuideTabBar : Theme.Theme -> Translations.Translations -> GuideTab -> Html Msg
viewGuideTabBar theme t current =
    div
        [ style "display" "flex"
        , style "background-color" theme.modalTabBg
        , style "flex-shrink" "0"
        ]
        [ guideTabBtn theme GuideEditor "Editor" current
        , guideTabBtn theme GuideSimulator t.guideTabSimulator current
        , guideTabBtn theme GuideConversion t.guideTabConversion current
        , guideTabBtn theme GuideErrors t.guideTabErrors current
        , guideTabBtn theme GuideAbout t.guideTabAbout current
        ]


guideTabBtn : Theme.Theme -> GuideTab -> String -> GuideTab -> Html Msg
guideTabBtn theme tab label current =
    button
        [ onClick (SetGuideTab tab)
        , style "padding" "10px 18px"
        , style "background-color"
            (if tab == current then theme.modalTabActiveBg else "transparent")
        , style "color" "white"
        , style "border" "none"
        , style "border-bottom"
            (if tab == current then ("2px solid " ++ theme.modalTabActiveBorder) else "2px solid transparent")
        , style "cursor" "pointer"
        , style "font-size" "13px"
        , style "font-weight"
            (if tab == current then "bold" else "normal")
        ]
        [ text label ]


viewGuideContent : Theme.Theme -> Translations.Translations -> Language -> GuideTab -> Html Msg
viewGuideContent theme t lang tab =
    case tab of
        GuideEditor ->
            viewGuideEditor theme t lang

        GuideSimulator ->
            viewGuideSimulator theme lang

        GuideConversion ->
            viewGuideConversion theme lang

        GuideErrors ->
            viewGuideErrors theme lang

        GuideAbout ->
            viewGuideAbout theme lang


renderGuidePage : Theme.Theme -> Translations.GuidePageText -> List (Html Msg) -> Html Msg
renderGuidePage theme page extraSections =
    div []
        (List.map (guidePara theme) page.intro
            ++ List.map
                (\sectionText ->
                    guideSection theme sectionText.title
                        (List.map (\rowText -> guideRow theme rowText.label rowText.description) sectionText.rows
                            ++ List.map (guidePara theme) sectionText.paragraphs
                            ++ List.map (guideNote theme) sectionText.notes
                        )
                )
                page.sections
            ++ extraSections
        )


renderGuideErrorsPage : Theme.Theme -> Translations.GuideErrorsPageText -> Html Msg
renderGuideErrorsPage theme page =
    div []
        (guidePara theme page.intro
            :: List.map
                (\sectionText ->
                    guideSection theme sectionText.title
                        (List.map (\err -> guideErrorRow theme err.error err.cause) sectionText.rows)
                )
                page.sections
        )


-- GUIDE HELPERS


guideSection : Theme.Theme -> String -> List (Html Msg) -> Html Msg
guideSection theme title children =
    div [ style "margin-bottom" "18px" ]
        (div
            [ style "font-weight" "bold"
            , style "font-size" "14px"
            , style "color" theme.modalSectionTitle
            , style "border-bottom" ("1px solid " ++ theme.modalBorder)
            , style "padding-bottom" "4px"
            , style "margin-bottom" "8px"
            ]
            [ text title ]
            :: children
        )


guideRow : Theme.Theme -> String -> String -> Html Msg
guideRow theme key val =
    div
        [ style "display" "flex"
        , style "gap" "10px"
        , style "margin-bottom" "5px"
        ]
        [ span
            [ style "font-weight" "bold"
            , style "min-width" "195px"
            , style "color" theme.textSecondary
            , style "flex-shrink" "0"
            ]
            [ text key ]
        , span [ style "color" theme.modalText ] [ text val ]
        ]


guideNote : Theme.Theme -> String -> Html Msg
guideNote theme txt =
    div
        [ style "background-color" theme.modalNoteBg
        , style "padding" "8px 12px"
        , style "border-radius" "4px"
        , style "border-left" "3px solid #43a047"
        , style "font-size" "12px"
        , style "color" theme.modalNoteText
        , style "margin-bottom" "10px"
        ]
        [ text txt ]


guidePara : Theme.Theme -> String -> Html Msg
guidePara theme txt =
    div
        [ style "margin-bottom" "12px"
        , style "color" theme.modalText
        ]
        [ text txt ]


guideCode : Theme.Theme -> String -> Html Msg
guideCode theme txt =
    span
        [ style "font-family" "monospace"
        , style "background" theme.modalCodeBg
        , style "padding" "1px 5px"
        , style "border-radius" "3px"
        , style "font-size" "12px"
        , style "color" theme.modalCodeText
        ]
        [ text txt ]


guideErrorRow : Theme.Theme -> String -> String -> Html Msg
guideErrorRow theme err cause =
    div
        [ style "display" "flex"
        , style "gap" "10px"
        , style "margin-bottom" "8px"
        , style "padding" "8px 10px"
        , style "background" theme.modalErrorBg
        , style "border-left" "3px solid #e53935"
        , style "border-radius" "3px"
        ]
        [ span
            [ style "font-family" "monospace"
            , style "font-size" "12px"
            , style "color" theme.modalCodeText
            , style "min-width" "240px"
            , style "flex-shrink" "0"
            , style "font-weight" "bold"
            ]
            [ text err ]
        , span [ style "font-size" "12px", style "color" theme.modalText ] [ text cause ]
        ]


exampleCard : Theme.Theme -> Translations.Translations -> ExampleAutomata.ExampleDef -> Html Msg
exampleCard theme t ex =
    div
        [ style "border" ("1px solid " ++ theme.exampleCardBorder)
        , style "border-radius" "6px"
        , style "padding" "12px 14px"
        , style "background" theme.exampleCardBg
        , style "display" "flex"
        , style "flex-direction" "column"
        , style "gap" "6px"
        , style "flex" "1"
        , style "min-width" "200px"
        ]
        [ div [ style "font-weight" "bold", style "font-size" "13px", style "color" theme.modalSectionTitle ]
            [ text ex.name ]
        , div [ style "font-size" "12px", style "color" theme.textMuted, style "flex" "1" ]
            [ text ex.description ]
        , button
            [ onClick (GuideLoadExample ex.automaton)
            , style "padding" "6px 12px"
            , style "background-color" theme.btnPrimary
            , style "color" "white"
            , style "border" "none"
            , style "border-radius" "4px"
            , style "cursor" "pointer"
            , style "font-size" "12px"
            , style "align-self" "flex-start"
            , style "margin-top" "4px"
            ]
            [ text t.loadIntoEditor ]
        ]


-- EDITOR TAB


viewGuideEditor : Theme.Theme -> Translations.Translations -> Language -> Html Msg
viewGuideEditor theme t lang =
    renderGuidePage theme (Translations.guideEditorPage lang)
        [ guideSection theme t.guideExamplesSection
            [ div
                [ style "display" "flex"
                , style "flex-wrap" "wrap"
                , style "gap" "10px"
                ]
                (List.map (exampleCard theme t) (ExampleAutomata.examples lang))
            ]
        ]


-- SIMULATOR TAB


viewGuideSimulator : Theme.Theme -> Language -> Html Msg
viewGuideSimulator theme lang =
    renderGuidePage theme (Translations.guideSimulatorPage lang) []


-- CONVERSION TAB


viewGuideConversion : Theme.Theme -> Language -> Html Msg
viewGuideConversion theme lang =
    renderGuidePage theme (Translations.guideConversionPage lang) []


-- ERRORS TAB


viewGuideErrors : Theme.Theme -> Language -> Html Msg
viewGuideErrors theme lang =
    renderGuideErrorsPage theme (Translations.guideErrorsPage lang)


-- ABOUT TAB


viewGuideAbout : Theme.Theme -> Language -> Html Msg
viewGuideAbout theme lang =
    let
        about =
            Translations.guideAboutPage lang
    in
    div []
        [ guideSection theme about.sectionTitle
            (List.map (\rowText -> guideRow theme rowText.label rowText.description) about.rows)
        , div
            [ style "margin-top" "16px"
            , style "font-size" "15px"
            , style "color" theme.modalText
            ]
            [ text about.contactPrefix
            , a
                [ href "mailto:xmiticky@stuba.sk"
                , style "color" theme.btnPrimary
                , style "font-weight" "bold"
                ]
                [ text "xmiticky@stuba.sk" ]
            ]
        ]
