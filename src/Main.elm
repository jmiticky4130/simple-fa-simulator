port module Main exposing (..)

import Browser
import Browser.Events
import Html exposing (Html, div, button, text, span, h3, p, ul, li, strong, a)
import Html.Attributes exposing (style, href, target)
import Html.Events exposing (onClick)
import Json.Decode as Decode
import Pages.Editor as Editor
import Pages.Simulator as Simulator
import Pages.Conversion as Conversion
import Shared exposing (AutomatonState)
import UndoList
import Utils.AutomatonCodec
import Utils.ExampleAutomata as ExampleAutomata
import Utils.Theme as Theme


port setUrlHash : String -> Cmd msg

port saveNamedAutomaton : { name : String, data : String } -> Cmd msg

port deleteNamedAutomaton : String -> Cmd msg

port requestStoredAutomata : () -> Cmd msg

port storedAutomataLoaded : (List { name : String, data : String } -> msg) -> Sub msg

port saveDarkMode : Bool -> Cmd msg


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
    }


type alias Flags =
    { urlData : Maybe String
    , darkMode : Bool
    }


flagsDecoder : Decode.Decoder Flags
flagsDecoder =
    Decode.map2 Flags
        (Decode.maybe (Decode.field "urlData" Decode.string))
        (Decode.field "darkMode" Decode.bool)


init : Decode.Value -> ( Model, Cmd Msg )
init flagsValue =
    let
        flags =
            case Decode.decodeValue flagsDecoder flagsValue of
                Ok f -> f
                Err _ -> { urlData = Nothing, darkMode = False }

        loadedAutomaton =
            flags.urlData
                |> Maybe.andThen (Decode.decodeString Utils.AutomatonCodec.decoder >> Result.toMaybe)

        editorInit =
            Editor.initWith loadedAutomaton

        simulatorInit =
            Simulator.init { states = [], transitions = [], nextStateId = 0 }

        conversionInit =
            Conversion.init { states = [], transitions = [], nextStateId = 0 }
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
      }
    , Cmd.none
    )


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
                        , conversionModel = Conversion.init model.editorModel.automaton.present
                      }
                    , Cmd.none
                    )

                Editor.SwitchToSimulator ->
                    let
                        currentAutomaton = model.editorModel.automaton.present
                        simulatorInit = Simulator.init currentAutomaton
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

                _ ->
                    let
                        newSimulatorModel =
                            Simulator.update simulatorMsg model.simulatorModel
                    in
                    ( { model | simulatorModel = newSimulatorModel }
                    , Cmd.none
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
                Html.map EditorMsg (Editor.view model.consoleOpen model.darkMode model.settingsOpen model.editorModel)

            SimulatorPage ->
                div
                    [ style "display" "flex"
                    , style "flex-direction" "column"
                    , style "height" "100vh"
                    ]
                    [ Html.map SimulatorMsg (Simulator.view model.consoleOpen model.darkMode model.settingsOpen model.simulatorModel)
                    ]

            ConversionPage ->
                Html.map ConversionMsg (Conversion.view model.consoleOpen model.darkMode model.settingsOpen model.conversionModel)

        , if model.showGuide then viewGuideModal theme model else text ""
        ]


main : Program Decode.Value Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


-- GUIDE MODAL


viewGuideModal : Theme.Theme -> Model -> Html Msg
viewGuideModal theme model =
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
            [ viewGuideHeader theme
            , viewGuideTabBar theme model.guideTab
            , div
                [ style "flex" "1"
                , style "overflow-y" "auto"
                , style "padding" "20px 24px"
                , style "font-family" "sans-serif"
                , style "font-size" "13px"
                , style "line-height" "1.65"
                , style "color" theme.modalText
                ]
                [ viewGuideContent theme model.guideTab ]
            ]
        ]


viewGuideHeader : Theme.Theme -> Html Msg
viewGuideHeader theme =
    div
        [ style "display" "flex"
        , style "align-items" "center"
        , style "padding" "14px 20px"
        , style "background-color" theme.toolbarBg
        , style "color" "white"
        , style "flex-shrink" "0"
        ]
        [ div [ style "font-size" "17px", style "font-weight" "bold", style "flex" "1" ]
            [ text "Sprievodca simulátorom DFA/NFA" ]
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


viewGuideTabBar : Theme.Theme -> GuideTab -> Html Msg
viewGuideTabBar theme current =
    div
        [ style "display" "flex"
        , style "background-color" theme.modalTabBg
        , style "flex-shrink" "0"
        ]
        [ guideTabBtn theme GuideEditor "Editor" current
        , guideTabBtn theme GuideSimulator "Simulátor" current
        , guideTabBtn theme GuideConversion "Konverzia NFA->DFA" current
        , guideTabBtn theme GuideErrors "Chybové správy" current
        , guideTabBtn theme GuideAbout "O projekte" current
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


viewGuideContent : Theme.Theme -> GuideTab -> Html Msg
viewGuideContent theme tab =
    case tab of
        GuideEditor ->
            viewGuideEditor theme

        GuideSimulator ->
            viewGuideSimulator theme

        GuideConversion ->
            viewGuideConversion theme

        GuideErrors ->
            viewGuideErrors theme

        GuideAbout ->
            viewGuideAbout theme


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


exampleCard : Theme.Theme -> ExampleAutomata.ExampleDef -> Html Msg
exampleCard theme ex =
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
            [ text "Načítať do editora" ]
        ]


-- EDITOR TAB


viewGuideEditor : Theme.Theme -> Html Msg
viewGuideEditor theme =
    div []
        [ guidePara theme "Editor slúži na budovanie deterministických (DFA) a nedeterministických (NFA) konečných automatov. Stavy a prechody vytvárate priamo na plátne."
        , guideSection theme "Akcie na plátne (nástroj Stavať)"
            [ guideRow theme "Pridanie stavu" "Dvojklik na prázdne plátno (predvolený názov q0, q1, ...)"
            , guideRow theme "Premenovanie stavu" "Rýchly dvojklik na stav -> upraviť názov v modáli"
            , guideRow theme "Nastavenie počiatočného stavu" "Rýchly dvojklik na stav -> zaškrtnúť Počiatočný stav"
            , guideRow theme "Nastavenie koncového stavu" "Rýchly dvojklik na stav -> zaškrtnúť Koncový stav"
            , guideRow theme "Pridanie prechodu" "Kliknutie na zdrojový stav, potom kliknutie na cieľový stav"
            , guideRow theme "Pridanie slučky (self-loop)" "Pomalý dvojklik na stav"
            , guideRow theme "Epsilon prechod" "Nechajte vstupné pole prázdne"
            , guideRow theme "Viac prechodov naraz" "Symboly oddeľujte čiarkou, napr. a,b"
            , guideRow theme "Úprava symbolu prechodu" "Dvojklik na symbol prechodu"
            , guideRow theme "Presun stavu" "Ťahanie stavu myšou"
            , guideRow theme "Zrušenie akcie / výberu" "Klik na prázdne plátno alebo Escape"
            ]
        , guideSection theme "Nástroje"
            [ guideRow theme "Stavať  (Shift+B)" "Predvolený nástroj: vytváranie stavov a prechodov"
            , guideRow theme "Odstrániť  (Shift+D)" "Klik na stav alebo prechod ho vymaže; opätovné kliknutie prepne späť na Stavať"
            ]
        , guideSection theme "Klávesové skratky"
            [ guideRow theme "Ctrl+Z / Ctrl+Y" "Späť / Dopredu (undo/redo)"
            , guideRow theme "Shift+B" "Nástroj Stavať"
            , guideRow theme "Shift+D" "Nástroj Odstrániť"
            , guideRow theme "Escape" "Zruší aktuálnu akciu (zatvorí vstupné polia, modály)"
            ]
        , guideSection theme "Navigácia plátna"
            [ guideRow theme "Koliesko myši (alebo +/- tlačidlá)" "Priblíženie / oddialenie"
            , guideRow theme "Ťahanie prázdneho plátna" "Posúvanie pohľadu (pan)"
            ]
        , guideSection theme "Súbory a ukladanie"
            [ guideRow theme "Export" "Stiahne automat ako súbor .json"
            , guideRow theme "Uložiť" "Uloží automat do lokálneho úložiska prehliadača s názvom"
            , guideRow theme "Načítať" "Načíta zo súboru .json alebo z lokálneho úložiska"
            , guideRow theme "Zdieľať cez URL" "Zakóduje automat do URL (hash); zdieľateľný link"
            , guideNote theme "Lokálne úložisko je viazané na prehliadač a doménu. Automaty zo sprievodcu sa do neho neukladajú."
            ]
        , guideSection theme "Konzola"
            [ guidePara theme "Spodná lišta zobrazuje informačné a chybové správy. Konzola je skrývateľná - kliknutím na lištu ju zrolujete alebo rozbalíte."
            ]
        , guideSection theme "Príklady automatov"
            [ div
                [ style "display" "flex"
                , style "flex-wrap" "wrap"
                , style "gap" "10px"
                ]
                (List.map (exampleCard theme) ExampleAutomata.examples)
            ]
        ]


-- SIMULATOR TAB


viewGuideSimulator : Theme.Theme -> Html Msg
viewGuideSimulator theme =
    div []
        [ guidePara theme "Simulátor umožňuje spúšťať automat krok za krokom na zadanom vstupnom reťazci. Tlačidlo Simulovať je aktívne len vtedy, keď automat má počiatočný aj aspoň jeden koncový stav."
        , guideSection theme "Ovládanie"
            [ guideRow theme "Vstupné pole" "Zadajte reťazec, ktorý chcete simulovať (napr. aab)"
            , guideRow theme "Krok vpred" "Prečíta ďalší symbol a posunie simuláciu o jeden krok"
            , guideRow theme "Krok späť" "Vráti simuláciu do predchádzajúceho stavu"
            , guideRow theme "Reset" "Vráti simuláciu na začiatok (vstup zostane)"
            , guideRow theme "Auto / Pauza" "Spustí / pozastaví automatické krokovanie"
            , guideRow theme "Posuvník rýchlosti" "Nastaví interval krokovania (100 ms - 2 s)"
            ]
        , guideSection theme "DFA simulácia"
            [ guideRow theme "Aktívny stav" "Zvýraznený na plátne modrým orámovaním"
            , guideRow theme "Aktívny prechod" "Šípka prechodu sa zvýrazní pri každom kroku"
            , guideRow theme "Výsledok" "Zelená = Akceptované, červená = Zamietnuté"
            , guideNote theme "DFA má vždy práve jednu aktívnu cestu - žiadny nedeterminizmus."
            ]
        , guideSection theme "NFA simulácia"
            [ guideRow theme "Inštancie" "Každá inštancia sleduje jednu možnú cestu v automate"
            , guideRow theme "Panel inštancií (vľavo)" "Zoznam všetkých inštancií; klik = zvýrazní stav na plátne"
            , guideRow theme "Stav inštancie" "Modrá = bežiaca, zelená = akceptovala, červená = zamietnutá"
            , guideRow theme "Strom rozhodnutí (vpravo)" "Vizualizácia všetkých ciest vrátane eps-krokov; sivé uzly = ukončené predka"
            , guideRow theme "Klik na uzol stromu" "Zvýrazní zodpovedajúcu inštanciu a stav na plátne"
            , guideRow theme "Prepínače Plátno / Strom" "Zobraziť alebo skryť každú sekciu nezávisle"
            , guideRow theme "Zlúčiť stavy" "Ak zaškrtnuté: inštancie s rovnakým (stav, zostatok vstupu) sa zlúčia do jednej."
            , guideNote theme "NFA akceptuje reťazec, ak aspoň jedna inštancia dosiahne akceptujúci stav po prečítaní celého vstupu."
            ]
        , guideSection theme "Efektívny režim (NFA)"
            [ guideRow theme "Zaškrtnite Efektívny režim" "V pravom paneli NFA simulátora zapne efektívny režim."
            , guideRow theme "Okamžitý beh" "Spustí kompletnú simuláciu naraz bez budovania inštancií."
            , guideNote theme "V efektívnom režime je krokovanie, auto-run a panel inštancií deaktivovaný."
            ]
        , guideSection theme "eps-prechody v NFA"
            [ guideRow theme "eps-rozvinutie" "Po každom symbolickom kroku sa automaticky vytvoria eps-deti"
            , guideRow theme "Zobrazenie" "eps-kroky sú viditeľné v strome rozhodnutí ako samostatné úrovne"
            ]
        ]


-- CONVERSION TAB


viewGuideConversion : Theme.Theme -> Html Msg
viewGuideConversion theme =
    div []
        [ guidePara theme "Konverzia NFA->DFA prevádza nedeterministický automat na ekvivalentný deterministický pomocou algoritmu podmnožín (subset construction)."
        , guideSection theme "Kľúčové pojmy"
            [ guideRow theme "eps-closure(S)" "Množina všetkých stavov dosiahnuteľných z množiny S cez eps-prechody (vrátane S)."
            , guideRow theme "move(S, a)" "Množina NFA stavov dosiahnuteľných z niektorého stavu S po symbole a (bez eps)."
            , guideRow theme "DFA stav" "Každý stav výsledného DFA zodpovedá podmnožine NFA stavov."
            , guideNote theme "DFA stav je akceptujúci práve vtedy, keď obsahuje aspoň jeden akceptujúci NFA stav."
            ]
        , guideSection theme "Algoritmus podmnožín (krok za krokom)"
            [ guideRow theme "1. Počiatočný stav" "Vypočítaj eps-closure({q0_NFA}) - to je počiatočný DFA stav."
            , guideRow theme "2. Výber z worklistu" "Vyber nespracovaný DFA stav S."
            , guideRow theme "3. Pre každý symbol a" "Vypočítaj T = eps-closure(move(S, a))."
            , guideRow theme "4. Nový stav?" "Ak T ešte neexistuje ako DFA stav, vytvor ho a pridaj do worklistu."
            , guideRow theme "5. Prechod" "Pridaj DFA prechod S ->a-> T."
            , guideRow theme "6. Označ S" "Označ DFA stav S ako spracovaný."
            , guideRow theme "7. Opakovanie" "Pokračuj, kým worklist nie je prázdny."
            ]
        , guideSection theme "Vizualizácia konverzie"
            [ guideRow theme "Plátno" "DFA stavy (podmnožiny NFA stavov); farebné zvýraznenie"
            , guideRow theme "Pravý panel - Popis kroku" "Textové vysvetlenie aktuálneho kroku algoritmu"
            , guideRow theme "Navigácia" "Pohyb cez jednotlivé kroky algoritmu dopredu/dozadu"
            ]
        , guideSection theme "Výstup konverzie"
            [ guideRow theme "Nahradiť automat" "Otvorí výsledný DFA v editore (nahradí aktuálny automat)"
            , guideRow theme "Uložiť DFA" "Uloží výsledný DFA do lokálneho úložiska prehliadača s názvom"
            , guideNote theme "Tlačidlá Nahradiť a Uložiť sú aktívne až po dokončení posledného kroku konverzie."
            ]
        ]


-- ERRORS TAB


viewGuideErrors : Theme.Theme -> Html Msg
viewGuideErrors theme =
    div []
        [ guidePara theme "Zoznam chýb a upozornení, ktoré sa môžu v aplikácii objaviť, vrátane ich príčiny a riešenia."
        , guideSection theme "Chyby v editore"
            [ guideErrorRow theme "Prázdny názov nie je povolený"
                "Stav musí mať neprázdny názov. Zadajte aspoň jeden znak."
            , guideErrorRow theme "Stav s názvom '...' už existuje"
                "Každý stav musí mať unikátny názov. Zvoľte iný názov."
            , guideErrorRow theme "Slučka nemôže byť eps-prechodom"
                "Epsilon self-loop (stav na seba samého) nie je povolený."
            , guideErrorRow theme "Prechod '...' už existuje"
                "Duplikátny prechod: rovnaký (zdroj, symbol, cieľ) už existuje."
            , guideErrorRow theme "Symbol nemôže obsahovať medzery"
                "Symbol prechodu nesmie obsahovať medzery."
            , guideErrorRow theme "Chyba importu: ..."
                "Neplatný JSON súbor alebo formát nezodpovedá schéme automatu."
            ]
        , guideSection theme "Neaktívne tlačidlá (podmienky spustenia)"
            [ guideErrorRow theme "Simulovať - 'Pridajte aspoň jeden stav'"
                "Automat nemá žiadne stavy. Dvojklikom na plátno pridajte stav."
            , guideErrorRow theme "Simulovať - 'Nastavte počiatočný stav'"
                "Automat nemá počiatočný stav. Dvojklik na stav -> zaškrtnúť Počiatočný stav."
            , guideErrorRow theme "Simulovať - 'Nastavte aspoň jeden koncový stav'"
                "Automat nemá žiadny akceptujúci stav. Nastavte ho cez modál stavu."
            , guideErrorRow theme "NFA->DFA - dostupné iba pre NFA"
                "Tlačidlo je neaktívne pre DFA (žiadne eps-prechody ani nedeterminizmus)."
            ]
        ]


-- ABOUT TAB


viewGuideAbout : Theme.Theme -> Html Msg
viewGuideAbout theme =
    div []
        [ guideSection theme "O projekte"
            [ guideRow theme "Názov" "Simulátor konečných automatov (DFA/NFA)"
            , guideRow theme "Typ" "Bakalárska práca"
            , guideRow theme "Rok" "2026"
            , guideRow theme "Škola" "STU FIIT"
            ]
        , div
            [ style "margin-top" "16px"
            , style "font-size" "15px"
            , style "color" theme.modalText
            ]
            [ text "Spätná väzba, otázky alebo hlásenie chýb - napíšte na: "
            , a
                [ href "mailto:xmiticky@stuba.sk"
                , style "color" theme.btnPrimary
                , style "font-weight" "bold"
                ]
                [ text "xmiticky@stuba.sk" ]
            ]
        ]
