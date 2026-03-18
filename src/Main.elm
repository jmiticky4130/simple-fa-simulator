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

port copyToClipboard : String -> Cmd msg

port scrollToBottom : String -> Cmd msg


type Page
    = EditorPage
    | SimulatorPage
    | ConversionPage


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
    }


type alias Flags =
    { urlData : Maybe String
    , darkMode : Bool
    , language : String
    }


flagsDecoder : Decode.Decoder Flags
flagsDecoder =
    Decode.map3 Flags
        (Decode.maybe (Decode.field "urlData" Decode.string))
        (Decode.field "darkMode" Decode.bool)
        (Decode.field "language" Decode.string)


init : Decode.Value -> ( Model, Cmd Msg )
init flagsValue =
    let
        flags =
            case Decode.decodeValue flagsDecoder flagsValue of
                Ok f -> f
                Err _ -> { urlData = Nothing, darkMode = False, language = "sk" }

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
                    in
                    ( { model
                        | currentPage = SimulatorPage
                        , simulatorModel = simulatorInit
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
                    in
                    ( { model | editorModel = newEditorModel }
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
                    in
                    ( { model | simulatorModel = newSimulatorModel }
                    , if shouldScrollTree then
                        scrollToBottom "nfa-tree-scroll"
                      else
                        Cmd.none
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


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.currentPage of
        EditorPage ->
            Sub.batch
                [ Browser.Events.onKeyDown (keyDecoder model)
                , storedAutomataLoaded (\list -> EditorMsg (Editor.StorageAutomataLoaded list))
                ]

        SimulatorPage ->
            Sub.map SimulatorMsg (Simulator.subscriptions model.simulatorModel)

        ConversionPage ->
            Sub.none


keyDecoder : Model -> Decode.Decoder Msg
keyDecoder model =
    Decode.map3 (\key ctrl shift ->
        if ctrl && (key == "z" || key == "Z") then EditorMsg Editor.Undo
        else if ctrl && (key == "y" || key == "Y") then EditorMsg Editor.Redo
        else if shift && (key == "b" || key == "B") then EditorMsg (Editor.ChangeTool Editor.BuildTool)
        else if shift && (key == "d" || key == "D") then EditorMsg (Editor.ChangeTool Editor.DeleteTool)
        else if key == "Escape" then
            if model.showGuide then CloseGuide
            else if model.settingsOpen then CloseSettings
            else if model.editorModel.showSaveModal then EditorMsg Editor.DismissSaveModal
            else if model.editorModel.showLoadModal then EditorMsg Editor.DismissLoadModal
            else EditorMsg Editor.CancelAction
        else EditorMsg Editor.NoOp
    )
    (Decode.field "key" Decode.string)
    (Decode.field "ctrlKey" Decode.bool)
    (Decode.field "shiftKey" Decode.bool)


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
                Html.map EditorMsg (Editor.view model.consoleOpen model.darkMode model.settingsOpen model.language model.editorModel)

            SimulatorPage ->
                div
                    [ style "display" "flex"
                    , style "flex-direction" "column"
                    , style "height" "100vh"
                    ]
                    [ Html.map SimulatorMsg (Simulator.view model.consoleOpen model.darkMode model.settingsOpen model.language model.simulatorModel)
                    ]

            ConversionPage ->
                Html.map ConversionMsg (Conversion.view model.consoleOpen model.darkMode model.settingsOpen model.language model.conversionModel)

        , if model.showGuide then viewGuideModal theme t model else text ""
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
