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


port setUrlHash : String -> Cmd msg

port saveNamedAutomaton : { name : String, data : String } -> Cmd msg

port deleteNamedAutomaton : String -> Cmd msg

port requestStoredAutomata : () -> Cmd msg

port storedAutomataLoaded : (List { name : String, data : String } -> msg) -> Sub msg


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
    }


init : Maybe String -> ( Model, Cmd Msg )
init maybeJson =
    let
        loadedAutomaton =
            maybeJson
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
    div []
        [ case model.currentPage of
            EditorPage ->
                Html.map EditorMsg (Editor.view model.consoleOpen model.editorModel)

            SimulatorPage ->
                div
                    [ style "display" "flex"
                    , style "flex-direction" "column"
                    , style "height" "100vh"
                    ]
                    [ Html.map SimulatorMsg (Simulator.view model.consoleOpen model.simulatorModel)
                    ]

            ConversionPage ->
                Html.map ConversionMsg (Conversion.view model.consoleOpen model.conversionModel)

        , if model.showGuide then viewGuideModal model else text ""
        ]


main : Program (Maybe String) Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


-- ─── GUIDE MODAL ─────────────────────────────────────────────────────────────


viewGuideModal : Model -> Html Msg
viewGuideModal model =
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
            [ style "background" "white"
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
            [ viewGuideHeader
            , viewGuideTabBar model.guideTab
            , div
                [ style "flex" "1"
                , style "overflow-y" "auto"
                , style "padding" "20px 24px"
                , style "font-family" "sans-serif"
                , style "font-size" "13px"
                , style "line-height" "1.65"
                , style "color" "#212121"
                ]
                [ viewGuideContent model.guideTab ]
            ]
        ]


viewGuideHeader : Html Msg
viewGuideHeader =
    div
        [ style "display" "flex"
        , style "align-items" "center"
        , style "padding" "14px 20px"
        , style "background-color" "#1a2f4a"
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
            [ text "×" ]
        ]


viewGuideTabBar : GuideTab -> Html Msg
viewGuideTabBar current =
    div
        [ style "display" "flex"
        , style "background-color" "#263238"
        , style "flex-shrink" "0"
        ]
        [ guideTabBtn GuideEditor "Editor" current
        , guideTabBtn GuideSimulator "Simulátor" current
        , guideTabBtn GuideConversion "Konverzia NFA→DFA" current
        , guideTabBtn GuideErrors "Chybové správy" current
        , guideTabBtn GuideAbout "O projekte" current
        ]


guideTabBtn : GuideTab -> String -> GuideTab -> Html Msg
guideTabBtn tab label current =
    button
        [ onClick (SetGuideTab tab)
        , style "padding" "10px 18px"
        , style "background-color"
            (if tab == current then "#37474f" else "transparent")
        , style "color" "white"
        , style "border" "none"
        , style "border-bottom"
            (if tab == current then "2px solid #4fc3f7" else "2px solid transparent")
        , style "cursor" "pointer"
        , style "font-size" "13px"
        , style "font-weight"
            (if tab == current then "bold" else "normal")
        ]
        [ text label ]


viewGuideContent : GuideTab -> Html Msg
viewGuideContent tab =
    case tab of
        GuideEditor ->
            viewGuideEditor

        GuideSimulator ->
            viewGuideSimulator

        GuideConversion ->
            viewGuideConversion

        GuideErrors ->
            viewGuideErrors

        GuideAbout ->
            viewGuideAbout


-- ─── GUIDE HELPERS ───────────────────────────────────────────────────────────


guideSection : String -> List (Html Msg) -> Html Msg
guideSection title children =
    div [ style "margin-bottom" "18px" ]
        (div
            [ style "font-weight" "bold"
            , style "font-size" "14px"
            , style "color" "#1a2f4a"
            , style "border-bottom" "1px solid #cfd8dc"
            , style "padding-bottom" "4px"
            , style "margin-bottom" "8px"
            ]
            [ text title ]
            :: children
        )


guideRow : String -> String -> Html Msg
guideRow key val =
    div
        [ style "display" "flex"
        , style "gap" "10px"
        , style "margin-bottom" "5px"
        ]
        [ span
            [ style "font-weight" "bold"
            , style "min-width" "195px"
            , style "color" "#37474f"
            , style "flex-shrink" "0"
            ]
            [ text key ]
        , span [ style "color" "#424242" ] [ text val ]
        ]


guideNote : String -> Html Msg
guideNote txt =
    div
        [ style "background-color" "#e8f5e9"
        , style "padding" "8px 12px"
        , style "border-radius" "4px"
        , style "border-left" "3px solid #43a047"
        , style "font-size" "12px"
        , style "color" "#1b5e20"
        , style "margin-bottom" "10px"
        ]
        [ text txt ]


guidePara : String -> Html Msg
guidePara txt =
    div
        [ style "margin-bottom" "12px"
        , style "color" "#424242"
        ]
        [ text txt ]


guideCode : String -> Html Msg
guideCode txt =
    span
        [ style "font-family" "monospace"
        , style "background" "#f5f5f5"
        , style "padding" "1px 5px"
        , style "border-radius" "3px"
        , style "font-size" "12px"
        , style "color" "#c62828"
        ]
        [ text txt ]


guideErrorRow : String -> String -> Html Msg
guideErrorRow err cause =
    div
        [ style "display" "flex"
        , style "gap" "10px"
        , style "margin-bottom" "8px"
        , style "padding" "8px 10px"
        , style "background" "#fff8f8"
        , style "border-left" "3px solid #e53935"
        , style "border-radius" "3px"
        ]
        [ span
            [ style "font-family" "monospace"
            , style "font-size" "12px"
            , style "color" "#c62828"
            , style "min-width" "240px"
            , style "flex-shrink" "0"
            , style "font-weight" "bold"
            ]
            [ text err ]
        , span [ style "font-size" "12px", style "color" "#424242" ] [ text cause ]
        ]


exampleCard : ExampleAutomata.ExampleDef -> Html Msg
exampleCard ex =
    div
        [ style "border" "1px solid #cfd8dc"
        , style "border-radius" "6px"
        , style "padding" "12px 14px"
        , style "background" "#fafafa"
        , style "display" "flex"
        , style "flex-direction" "column"
        , style "gap" "6px"
        , style "flex" "1"
        , style "min-width" "200px"
        ]
        [ div [ style "font-weight" "bold", style "font-size" "13px", style "color" "#1a2f4a" ]
            [ text ex.name ]
        , div [ style "font-size" "12px", style "color" "#616161", style "flex" "1" ]
            [ text ex.description ]
        , button
            [ onClick (GuideLoadExample ex.automaton)
            , style "padding" "6px 12px"
            , style "background-color" "#0277bd"
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


-- ─── EDITOR TAB ──────────────────────────────────────────────────────────────


viewGuideEditor : Html Msg
viewGuideEditor =
    div []
        [ guidePara "Editor slúži na budovanie deterministických (DFA) a nedeterministických (NFA) konečných automatov. Stavy a prechody vytvárate priamo na plátne."
        , guideSection "Akcie na plátne (nástroj Stavať)"
            [ guideRow "Pridanie stavu" "Dvojklik na prázdne plátno (predvolený názov q0, q1, …)"
            , guideRow "Premenovanie stavu" "Rýchly dvojklik na stav → upraviť názov v modáli"
            , guideRow "Nastavenie počiatočného stavu" "Rýchly dvojklik na stav → zaškrtnúť Počiatočný stav"
            , guideRow "Nastavenie koncového stavu" "Rýchly dvojklik na stav → zaškrtnúť Koncový stav"
            , guideRow "Pridanie prechodu" "Kliknutie na zdrojový stav, potom kliknutie na cieľový stav"
            , guideRow "Pridanie slučky (self-loop)" "Pomalý dvojklik na stav"
            , guideRow "Epsilon prechod" "Nechajte vstupné pole prázdne"
            , guideRow "Viac prechodov naraz" "Symboly oddeľte čiarkou, napr. a,b"
            , guideRow "Úprava symbolu prechodu" "Dvojklik na symbol prechodu"
            , guideRow "Presun stavu" "Ťahanie stavu myšou"
            , guideRow "Zrušenie akcie / výberu" "Klik na prázdne plátno alebo Escape"
            ]
        , guideSection "Nástroje"
            [ guideRow "Stavať  (Shift+B)" "Predvolený nástroj: vytváranie stavov a prechodov"
            , guideRow "Odstrániť  (Shift+D)" "Klik na stav alebo prechod ho vymaže; opätovné kliknutie prepne späť na Stavať"
            ]
        , guideSection "Klávesové skratky"
            [ guideRow "Ctrl+Z / Ctrl+Y" "Späť / Dopredu (undo/redo)"
            , guideRow "Shift+B" "Nástroj Stavať"
            , guideRow "Shift+D" "Nástroj Odstrániť"
            , guideRow "Escape" "Zruší aktuálnu akciu (zatvorí vstupné polia, modály)"
            ]
        , guideSection "Navigácia plátna"
            [ guideRow "Koliesko myši (alebo ± tlačidlá)" "Priblíženie / oddialenie"
            , guideRow "Ťahanie prázdneho plátna" "Posúvanie pohľadu (pan)"
            ]
        , guideSection "Súbory a ukladanie"
            [ guideRow "Export" "Stiahne automat ako súbor .json"
            , guideRow "Uložiť" "Uloží automat do lokálneho úložiska prehliadača s názvom"
            , guideRow "Načítať" "Načíta zo súboru .json alebo z lokálneho úložiska"
            , guideRow "Zdieľať cez URL" "Zakóduje automat do URL (hash); zdieľateľný link"
            , guideNote "Lokálne úložisko je viazané na prehliadač a doménu. Automaty zo sprievodcu sa do neho neukladajú."
            ]
        , guideSection "Konzola"
            [ guidePara "Spodná lišta zobrazuje informačné a chybové správy. Konzola je skrývateľná – kliknutím na lištu ju zrolujete alebo rozbalíte."
            ]
        , guideSection "Príklady automatov"
            [ div
                [ style "display" "flex"
                , style "flex-wrap" "wrap"
                , style "gap" "10px"
                ]
                (List.map exampleCard ExampleAutomata.examples)
            ]
        ]


-- ─── SIMULATOR TAB ───────────────────────────────────────────────────────────


viewGuideSimulator : Html Msg
viewGuideSimulator =
    div []
        [ guidePara "Simulátor umožňuje spúšťať automat krok za krokom na zadanom vstupnom reťazci. Tlačidlo Simulovať je aktívne len vtedy, keď automat má počiatočný aj aspoň jeden koncový stav."
        , guideSection "Ovládanie"
            [ guideRow "Vstupné pole" "Zadajte reťazec, ktorý chcete simulovať (napr. aab)"
            , guideRow "Krok vpred" "Prečíta ďalší symbol a posunie simuláciu o jeden krok"
            , guideRow "Krok späť" "Vráti simuláciu do predchádzajúceho stavu"
            , guideRow "Reset" "Vráti simuláciu na začiatok (vstup zostane)"
            , guideRow "▶ Auto / ⏸ Pauza" "Spustí / pozastaví automatické krokovanie"
            , guideRow "Posuvník rýchlosti" "Nastaví interval krokovania (100 ms – 2 s)"
            ]
        , guideSection "DFA simulácia"
            [ guideRow "Aktívny stav" "Zvýraznený na plátne modrým orámovaním"
            , guideRow "Aktívny prechod" "Šípka prechodu sa zvýrazní pri každom kroku"
            , guideRow "Výsledok" "Zelená = Akceptované, červená = Zamietnuté"
            , guideNote "DFA má vždy práve jednu aktívnu cestu — žiadny nedeterminizmus."
            ]
        , guideSection "NFA simulácia"
            [ guideRow "Inštancie" "Každá inštancia sleduje jednu možnú cestu automate"
            , guideRow "Panel inštancií (vľavo)" "Zoznam všetkých inštancií; klik = zvýrazní stav na plátne"
            , guideRow "Stav inštancie" "Modrá = bežiaca, zelená = akceptovala, červená = zamietnutá"
            , guideRow "Strom rozhodnutí (vpravo)" "Vizualizácia všetkých ciest vrátane ε-krokov; sivé uzly = ukončené predka"
            , guideRow "Klik na uzol stromu" "Zvýrazní zodpovedajúcu inštanciu a stav na plátne"
            , guideRow "Prepínače Plátno / Strom" "Zobraziť alebo skryť každú sekciu nezávisle"
            , guideRow "Zlúčiť stavy" "Ak zaškrtnuté: inštancie s rovnakým (stav, zostatok vstupu) sa zlúčia do jednej. Bez zlučovania môže počet inštancií rásť exponenciálne (až k^n, kde k je priemerný počet vetvení a n dĺžka vstupu). Zlučovanie obmedzuje počet aktívnych inštancií na najviac |Q| v každom kroku. Odporúčané pre komplexné NFA."
            , guideNote "NFA akceptuje reťazec, ak aspoň jedna inštancia dosiahne akceptujúci stav po prečítaní celého vstupu."
            ]
        , guideSection "Efektívny režim (NFA)"
            [ guideRow "Zaškrtnite \"Efektívny režim\"" "V pravom paneli NFA simulátora zapne efektívny režim, ktorý nahradí strom inštancií zobrazením výsledku priamo na plátne."
            , guideRow "Okamžitý beh" "Spustí kompletnú simuláciu naraz bez budovania inštancií. Výsledok (akceptované/zamietnuté) a dosiahnuté stavy sa zobrazia okamžite na plátne."
            , guideNote "V efektívnom režime je krokovanie, auto-run a panel inštancií deaktivovaný. Vhodné pre komplexné NFA s dlhým vstupom."
            ]
        , guideSection "ε-prechody v NFA"
            [ guideRow "ε-rozvinutie" "Po každom symbolickom kroku sa automaticky vytvoria ε-deti"
            , guideRow "Zobrazenie" "ε-kroky sú viditeľné v strome rozhodnutí ako samostatné úrovne"
            ]
        ]


-- ─── CONVERSION TAB ──────────────────────────────────────────────────────────


viewGuideConversion : Html Msg
viewGuideConversion =
    div []
        [ guidePara "Konverzia NFA→DFA prevádza nedeterministický automat na ekvivalentný deterministický pomocou algoritmu podmnožín (subset construction). Tlačidlo NFA→DFA je aktívne len pre NFA; pre DFA je neaktívne."
        , guideSection "Kľúčové pojmy"
            [ guideRow "ε-closure(S)" "Množina všetkých stavov dosiahnuteľných z množiny S cez ε-prechody (vrátane S). Príklad: ak q0→ε→q1, potom ε-closure({q0}) = {q0, q1}."
            , guideRow "move(S, a)" "Množina NFA stavov dosiahnuteľných z niektorého stavu S po symbole a (bez ε). Príklad: ak q0→a→q1 a q0→a→q2, potom move({q0}, a) = {q1, q2}."
            , guideRow "DFA stav" "Každý stav výsledného DFA zodpovedá podmnožine NFA stavov."
            , guideNote "DFA stav je akceptujúci práve vtedy, keď obsahuje aspoň jeden akceptujúci NFA stav."
            ]
        , guideSection "Algoritmus podmnožín (krok za krokom)"
            [ guideRow "1. Počiatočný stav" "Vypočítaj ε-closure({q₀_NFA}) — to je počiatočný DFA stav. Pridaj ho do pracovného zoznamu (worklist)."
            , guideRow "2. Výber zo worklistu" "Vyber nepracovaný DFA stav S."
            , guideRow "3. Pre každý symbol a" "Vypočítaj T = ε-closure(move(S, a))."
            , guideRow "4. Nový stav?" "Ak T ešte neexistuje ako DFA stav, vytvor ho a pridaj do worklistu."
            , guideRow "5. Prechod" "Pridaj DFA prechod S →a→ T."
            , guideRow "6. Označ S" "Označ DFA stav S ako spracovaný."
            , guideRow "7. Opakovanie" "Pokračuj, kým worklist nie je prázdny."
            ]
        , guideSection "Vizualizácia konverzie"
            [ guideRow "Plátno" "DFA stavy (podmnožiny NFA stavov); farebné zvýraznenie: žltá = aktívny, sivá = spracovaný, svetlomodrá = novo vytvorený"
            , guideRow "Pravý panel – Popis kroku" "Textové vysvetlenie aktuálneho kroku algoritmu v slovenčine"
            , guideRow "Pravý panel – Tabuľka podmnožín" "Prehľad všetkých DFA stavov a ich prechodov; zvýraznené sú riadok a stĺpec aktuálneho kroku"
            , guideRow "Navigácia ⏮ ◀ ▶ ⏭" "Pohyb cez jednotlivé kroky algoritmu dopredu/dozadu"
            , guideRow "Ťahanie stavov" "DFA stavy na plátne je možné presúvať"
            ]
        , guideSection "Výstup konverzie"
            [ guideRow "Nahradiť automat" "Otvorí výsledný DFA v editore (nahradí aktuálny automat)"
            , guideRow "Uložiť DFA" "Uloží výsledný DFA do lokálneho úložiska prehliadača s názvom"
            , guideNote "Tlačidlá Nahradiť a Uložiť sú aktívne až po dokončení posledného kroku konverzie."
            ]
        ]


-- ─── ERRORS TAB ──────────────────────────────────────────────────────────────


viewGuideErrors : Html Msg
viewGuideErrors =
    div []
        [ guidePara "Zoznam chýb a upozornení, ktoré sa môžu v aplikácii objaviť, vrátane ich príčiny a riešenia."
        , guideSection "Chyby v editore"
            [ guideErrorRow "Prázdny názov nie je povolený"
                "Stav musí mať neprázdny názov. Zadajte aspoň jeden znak."
            , guideErrorRow "Stav s názvom '...' už existuje"
                "Každý stav musí mať unikátny názov. Zvoľte iný názov."
            , guideErrorRow "Slučka nemôže byť ε-prechodom"
                "Epsilon self-loop (stav na seba samého) nie je povolený."
            , guideErrorRow "Prechod '...' už existuje"
                "Duplikátny prechod: rovnaký (zdroj, symbol, cieľ) už existuje."
            , guideErrorRow "Symbol nemôže obsahovať medzery"
                "Symbol prechodu nesmie obsahovať medzery (napr. použite 'ab' nie 'a b')."
            , guideErrorRow "Chyba importu: ..."
                "Neplatný JSON súbor alebo formát nezodpovedá schéme automatu."
            , guideErrorRow "Zadajte názov automatu"
                "Pri ukladaní do lokálneho úložiska musíte zadať neprázdny názov."
            ]
        , guideSection "Neaktívne tlačidlá (podmienky spustenia)"
            [ guideErrorRow "Simulovať – 'Pridajte aspoň jeden stav'"
                "Automat nemá žiadne stavy. Dvojklikom na plátno pridajte stav."
            , guideErrorRow "Simulovať – 'Nastavte počiatočný stav'"
                "Automat nemá počiatočný stav. Dvojklik na stav → zaškrtnúť 'Počiatočný stav'."
            , guideErrorRow "Simulovať – 'Nastavte aspoň jeden koncový stav'"
                "Automat nemá žiadny akceptujúci stav. Nastavte ho cez modál stavu."
            , guideErrorRow "NFA→DFA – dostupné iba pre NFA"
                "Tlačidlo je neaktívne pre DFA (žiadne ε-prechody ani nedeterminizmus)."
            ]
        ]


-- ─── ABOUT TAB ───────────────────────────────────────────────────────────────


viewGuideAbout : Html Msg
viewGuideAbout =
    div []
        [ guideSection
            [ guideRow "Názov" "Simulátor konečných automatov (DFA/NFA)"
            , guideRow "Typ" "Bakalárska práca"
            , guideRow "Rok" "2026"
            , guideRow "Škola" "STU FIIT"
            ]
        , div
            [ style "margin-top" "16px"
            , style "font-size" "15px"
            , style "color" "#424242"
            ]
            [ text "Spätná väzba, otázky alebo hlásenie chýb – napíšte na: "
            , a
                [ href "mailto:xmiticky@stuba.sk"
                , style "color" "#0277bd"
                , style "font-weight" "bold"
                ]
                [ text "xmiticky@stuba.sk" ]
            ]
        ]

