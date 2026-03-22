module Utils.Translations exposing
    ( AboutPageText
    , GuideErrorSectionText
    , GuideErrorText
    , GuideErrorsPageText
    , GuidePageText
    , GuideRowText
    , GuideSectionText
    , Language(..)
    , Translations
    , getTranslations
    , guideAboutPage
    , guideConversionPage
    , guideEditorPage
    , guideErrorsPage
    , guideSimulatorPage
    )


type Language
    = Slovak
    | English


type alias GuideRowText =
    { label : String
    , description : String
    }


type alias GuideErrorText =
    { error : String
    , cause : String
    }


type alias GuideSectionText =
    { title : String
    , rows : List GuideRowText
    , notes : List String
    , paragraphs : List String
    }


type alias GuidePageText =
    { intro : List String
    , sections : List GuideSectionText
    }


type alias GuideErrorSectionText =
    { title : String
    , rows : List GuideErrorText
    }


type alias GuideErrorsPageText =
    { intro : String
    , sections : List GuideErrorSectionText
    }


type alias AboutPageText =
    { sectionTitle : String
    , rows : List GuideRowText
    , contactPrefix : String
    }


type alias Translations =
    { darkMode : String
    , language : String
    , languageName : String
    , settings : String
    , guideTitle : String
    , guideTabSimulator : String
    , guideTabConversion : String
    , guideTabErrors : String
    , guideTabAbout : String
    , loadIntoEditor : String
    , notSelected : String
    , reset : String
    , build : String
    , delete : String
    , export : String
    , exportTooltip : String
    , save : String
    , saveTooltip : String
    , load : String
    , loadTooltip : String
    , shareViaUrl : String
    , shareViaUrlTooltip : String
    , simulate : String
    , guide : String
    , stepBack : String
    , stepForward : String
    , auto : String
    , pause : String
    , backToEditor : String
    , replaceAutomaton : String
    , saveDfa : String
    , stepLabel : String
    , cancel : String
    , ok : String
    , deleteStored : String
    , consoleTitle : String
    , automatonDefinition : String
    , copied : String
    , noStartStateSelected : String
    , currentState : String
    , stateLabel : String
    , remainingLabel : String
    , emptyInput : String
    , deadBranch : String
    , running : String
    , accepted : String
    , rejected : String
    , instancePrefix : String
    , loadMorePrefix : String
    , loadMoreMiddle : String
    , loadMoreSuffix : String
    , editorWelcome : String
    , editorAboutProjectLink : String
    , editorLoadedFromUrl : String
    , editorImportedFromFile : String
    , editorImportErrorPrefix : String
    , editorUrlCopied : String
    , editorDefinitionCopied : String
    , editorEnterName : String
    , editorSavedPrefix : String
    , editorLoadedPrefix : String
    , editorGenericErrorPrefix : String
    , editorActionCanceled : String
    , editorStateAddedPrefix : String
    , editorEditTransitionSymbol : String
    , editorStateDeletedPrefix : String
    , editorTransitionDeletedPrefix : String
    , editorEmptyName : String
    , editorStateExistsPrefix : String
    , editorStateExistsSuffix : String
    , editorStateRenamedPrefix : String
    , editorStateUpdatedPrefix : String
    , editorReset : String
    , editorLoopCannotBeEpsilon : String
    , editorTransitionExistsPrefix : String
    , editorTransitionExistsSuffix : String
    , editorEpsilonTransitionExists : String
    , editorEpsilonTransitionAdded : String
    , editorTransitionsExistPrefix : String
    , editorAllTransitionsExist : String
    , editorTransitionAddedPrefix : String
    , editorTransitionsAddedPrefix : String
    , editorTransitionsAddedSuffix : String
    , editorSelectTargetState : String
    , editorEnterTransitionSymbols : String
    , editorToolBuildMessage : String
    , editorToolDeleteMessage : String
    , editorAddStateRequirement : String
    , editorStartStateRequirement : String
    , editorEndStateRequirement : String
    , editorConvertRequirement : String
    , editorRecenter : String
    , editorEditSymbolLabel : String
    , editorSymbolsHint : String
    , editorEditStateTitle : String
    , editorStateNamePlaceholder : String
    , editorStartStateCheckbox : String
    , editorEndStateCheckbox : String
    , editorCompactStateCheckbox : String
    , editorLoadAutomatonTitle : String
    , editorLoadFromJson : String
    , editorSaveAutomatonTitle : String
    , editorAutomatonNamePlaceholder : String
    , simReady : String
    , simInputSetPrefix : String
    , simEfficientRunPrefix : String
    , simWordAccepted : String
    , simWordRejected : String
    , simTransitionThroughPrefix : String
    , simTransitionToStatePrefix : String
    , simMissingTransitionPrefix : String
    , simNoCurrentState : String
    , simEndOfInput : String
    , simStepBack : String
    , simStepForwardNfa : String
    , simAutomatonTab : String
    , simTreeTab : String
    , simInputWordLabel : String
    , simInputEmptyError : String
    , simInputUnknownSymbols : String
    , simMergeUnavailable : String
    , simMergeLabel : String
    , simMergeTooltip : String
    , simEfficientModeLabel : String
    , simEfficientModeTooltip : String
    , simInstantRun : String
    , simReachedStatesPrefix : String
    , simInstancePanelDisabled : String
    , convStarted : String
    , convFinished : String
    , convAutomatonReplaced : String
    , convDfaSavedPrefix : String
    , convStepDescription : String
    , convOriginalNfaStates : String
    , convSubsetTable : String
    , convStateColumn : String
    , convStartColumn : String
    , convEndColumn : String
    , convDfaStateColumn : String
    , convInitPrefix : String
    , convInitSuffix : String
    , convProcessingPrefix : String
    , convDeadStateSuffix : String
    , convMovePrefix : String
    , convClosurePrefix : String
    , convNewStateCreated : String
    , convStateAlreadyExists : String
    , convStateProcessedPrefix : String
    , convStateProcessedSuffix : String
    , convConstructionDone : String
    , example1Name : String
    , example1Desc : String
    , example2Name : String
    , example2Desc : String
    , example3Name : String
    , example3Desc : String
    , example4Name : String
    , example4Desc : String
    , example5Name : String
    , example5Desc : String
    , example6Name : String
    , example6Desc : String
    , guideExamplesSection : String
    , tutWelcomeTitle : String
    , tutWelcomeBody : String
    , tutContinueToTutorial : String
    , tutSkipTutorial : String
    , tutFinish : String
    , tutSkip : String
    , tutStep1 : String
    , tutStep2 : String
    , tutStep3 : String
    , tutStep4 : String
    , tutStep5 : String
    , tutStep6 : String
    , tutStep7 : String
    , tutStep8 : String
    , tutRelaunch : String
    }


skTranslations : Translations
skTranslations =
    { darkMode = "Tmavý režim"
    , language = "Jazyk"
    , languageName = "Slovenčina"
    , settings = "Nastavenia"
    , guideTitle = "Sprievodca simulátorom DFA/NFA"
    , guideTabSimulator = "Simulátor"
    , guideTabConversion = "Konverzia NFA->DFA"
    , guideTabErrors = "Chybové správy"
    , guideTabAbout = "O projekte"
    , loadIntoEditor = "Načítať do editora"
    , notSelected = "nebol vybratý"
    , reset = "Reset"
    , build = "Stavať"
    , delete = "Odstrániť"
    , export = "Export"
    , exportTooltip = "Exportovať"
    , save = "Uložiť"
    , saveTooltip = "Uložiť lokálne"
    , load = "Načítať"
    , loadTooltip = "Načítať lokálne"
    , shareViaUrl = "Zdieľať cez URL"
    , shareViaUrlTooltip = "Zdieľať cez URL"
    , simulate = "Simulovať"
    , guide = "Sprievodca"
    , stepBack = "Krok späť"
    , stepForward = "Krok vpred"
    , auto = "Auto"
    , pause = "Pauza"
    , backToEditor = "<- Editor"
    , replaceAutomaton = "Nahradiť automat"
    , saveDfa = "Uložiť DFA"
    , stepLabel = "Krok"
    , cancel = "Zrušiť"
    , ok = "OK"
    , deleteStored = "Vymazať"
    , consoleTitle = "Konzola"
    , automatonDefinition = "Definícia automatu"
    , copied = "Skopírované"
    , noStartStateSelected = "nebol vybratý počiatočný stav"
    , currentState = "Aktuálny stav"
    , stateLabel = "Stav"
    , remainingLabel = "Zostatok"
    , emptyInput = "(prázdny)"
    , deadBranch = "Mŕtva vetva"
    , running = "Beží"
    , accepted = "Akceptované"
    , rejected = "Zamietnuté"
    , instancePrefix = "Inštancia #"
    , loadMorePrefix = "Načítať ďalšie (zobrazených "
    , loadMoreMiddle = " z "
    , loadMoreSuffix = ")"
    , editorWelcome = "Vitajte v simulátore DFA/NFA. Dvojklikom na plátno pridajte stav."
    , editorAboutProjectLink = "O projekte"
    , editorLoadedFromUrl = "Automat načítaný z URL."
    , editorImportedFromFile = "Automat importovaný zo súboru."
    , editorImportErrorPrefix = "Chyba importu: "
    , editorUrlCopied = "URL skopírovaná do schránky."
    , editorDefinitionCopied = "Definícia automatu skopírovaná do schránky."
    , editorEnterName = "Zadajte názov automatu."
    , editorSavedPrefix = "Automat uložený: "
    , editorLoadedPrefix = "Automat načítaný: "
    , editorGenericErrorPrefix = "Chyba: "
    , editorActionCanceled = "Akcia zrušená."
    , editorStateAddedPrefix = "Pridaný stav: "
    , editorEditTransitionSymbol = "Upravte symbol prechodu."
    , editorStateDeletedPrefix = "Odstránený stav: "
    , editorTransitionDeletedPrefix = "Odstránený prechod: "
    , editorEmptyName = "Prázdny názov nie je povolený."
    , editorStateExistsPrefix = "Stav s názvom '"
    , editorStateExistsSuffix = "' už existuje."
    , editorStateRenamedPrefix = "Stav premenovaný na: "
    , editorStateUpdatedPrefix = "Stav upravený: "
    , editorReset = "Automat bol resetovaný."
    , editorLoopCannotBeEpsilon = "Slučka nemôže byť ε-prechodom."
    , editorTransitionExistsPrefix = "Prechod '"
    , editorTransitionExistsSuffix = "' už existuje."
    , editorEpsilonTransitionExists = "ε-prechod už existuje."
    , editorEpsilonTransitionAdded = "Pridaný ε-prechod."
    , editorTransitionsExistPrefix = "Prechod(y) už existujú: "
    , editorAllTransitionsExist = "Všetky prechody už existujú."
    , editorTransitionAddedPrefix = "Pridaný prechod: "
    , editorTransitionsAddedPrefix = "Pridaných "
    , editorTransitionsAddedSuffix = " prechodov."
    , editorSelectTargetState = "Vyberte cieľový stav pre prechod."
    , editorEnterTransitionSymbols = "Zadajte symbol(y) pre prechod (oddeľte medzerou)."
    , editorToolBuildMessage = "Nástroj: Stavať - dvojklik=nový stav, klik na stav=prechod, rýchly dvojklik=slučka, pravý klik=upraviť stav"
    , editorToolDeleteMessage = "Nástroj: Odstrániť - kliknite na stav alebo prechod"
    , editorAddStateRequirement = "Pridajte aspoň jeden stav."
    , editorStartStateRequirement = "Nastavte počiatočný stav."
    , editorEndStateRequirement = "Nastavte aspoň jeden koncový stav."
    , editorConvertRequirement = "Preveďte NFA (musí obsahovať eps-prechody alebo viacero prechodov na rovnakej abecede)."
    , editorRecenter = "Vycentrovať"
    , editorEditSymbolLabel = "Upraviť symbol:"
    , editorSymbolsHint = "Pre zadanie viacero symbolov oddeľte symboly medzerou.\nPrázdny symbol predstavuje \u{03B5}, alebo prázdne vstupné pole."
    , editorEditStateTitle = "Upraviť stav"
    , editorStateNamePlaceholder = "Názov stavu"
    , editorStartStateCheckbox = "Počiatočný stav"
    , editorEndStateCheckbox = "Koncový stav"
    , editorCompactStateCheckbox = "Kompaktný stav"
    , editorLoadAutomatonTitle = "Načítať automat"
    , editorLoadFromJson = "Načítať zo súboru .json"
    , editorSaveAutomatonTitle = "Uložiť automat"
    , editorAutomatonNamePlaceholder = "Názov automatu"
    , simReady = "Simulátor pripravený. Zadajte vstupné slovo."
    , simInputSetPrefix = "Vstup nastavený: "
    , simEfficientRunPrefix = "Efektívny beh: "
    , simWordAccepted = "Slovo je akceptované"
    , simWordRejected = "Slovo nie je akceptované"
    , simTransitionThroughPrefix = "Prechod cez '"
    , simTransitionToStatePrefix = "' do stavu "
    , simMissingTransitionPrefix = "Chyba: Neexistuje prechod pre symbol '"
    , simNoCurrentState = "Chyba: Nie je nastavený aktuálny stav."
    , simEndOfInput = "Koniec vstupu."
    , simStepBack = "Krok späť."
    , simStepForwardNfa = "Krok vpred (NFA)."
    , simAutomatonTab = "Automat"
    , simTreeTab = "Strom"
    , simInputWordLabel = "Vstupné slovo"
    , simInputEmptyError = "Vstupné slovo je prázdne"
    , simInputUnknownSymbols = "Slovo obsahuje symboly mimo abecedy"
    , simMergeUnavailable = "Zlúčenie stavov nie je dostupné pre automaty s ε-prechodmi"
    , simMergeLabel = "Zlúčiť stavy"
    , simMergeTooltip = "Bez zlúčenia môže počet inštancií rásť exponenciálne s dĺžkou vstupu (až k^n, kde k je priemer vetvení a n dĺžka vstupu). Zlúčenie redukuje počet aktívnych inštancií na najviac |Q| v každom kroku - rovnaký princíp ako algoritmus podmnožín. Odporúčané pre komplexné NFA."
    , simEfficientModeLabel = "Efektívny režim"
    , simEfficientModeTooltip = "Efektívny režim spustí simuláciu naraz bez budovania stromu inštancií. Vhodné pre komplexné NFA s dlhým vstupom, kde by klasická simulácia bola príliš pomalá."
    , simInstantRun = "Okamžitý beh"
    , simReachedStatesPrefix = "Dosiahnuté stavy: "
    , simInstancePanelDisabled = "Panel instancií je deaktivovaný v efektívnom režime."
    , convStarted = "Konverzia NFA -> DFA spustená."
    , convFinished = "Konverzia dokončená."
    , convAutomatonReplaced = "Automat nahradený konvertovaným DFA."
    , convDfaSavedPrefix = "DFA uložený: "
    , convStepDescription = "Popis kroku"
    , convOriginalNfaStates = "Povodne NFA stavy"
    , convSubsetTable = "Tabulka podmnozin"
    , convStateColumn = "Stav"
    , convStartColumn = "Poc."
    , convEndColumn = "Konc."
    , convDfaStateColumn = "Stav DFA"
    , convInitPrefix = "ε-uzáver počiatočného stavu = "
    , convInitSuffix = ". Toto je počiatočný stav DFA."
    , convProcessingPrefix = "Spracúvame "
    , convDeadStateSuffix = ". move = ∅. Mŕtvy stav (∅), vynechané."
    , convMovePrefix = ". move = "
    , convClosurePrefix = ", ε-uzáver = "
    , convNewStateCreated = ". Nový stav vytvorený."
    , convStateAlreadyExists = ". Stav už existuje."
    , convStateProcessedPrefix = "Stav "
    , convStateProcessedSuffix = " je plne spracovaný."
    , convConstructionDone = "Konštrukcia DFA je dokončená."
    , example1Name = "DFA – končí na 'a'"
    , example1Desc = "Prijíma reťazce nad {a,b} končiace symbolom 'a'. Príklad: a, ba, aba."
    , example2Name = "DFA – párny počet núl"
    , example2Desc = "Prijíma binárne reťazce s párnym počtom symbolov '0' (vrátane žiadnej nuly). Príklad: ε, 00, 11, 1001."
    , example3Name = "NFA – končí na '01'"
    , example3Desc = "Nedeterministický automat prijímajúci reťazce nad {0,1} končiace podreťazcom '01'. Príklad: 01, 101, 0101."
    , example4Name = "NFA s ε – prijíma 'a' alebo 'ab'"
    , example4Desc = "NFA s epsilon prechodom: q1 →ε→ q2 (akceptuje 'a'), q1 →b→ q3 (akceptuje 'ab'). Ukážka ε-prechodov."
    , example5Name = "NFA – predposledný symbol je '1'"
    , example5Desc = "Prijíma reťazce nad {0,1} dĺžky ≥ 2, kde predposledný symbol je '1'. Príklad: 10, 11, 010, 110."
    , example6Name = "ε-NFA – a*b*"
    , example6Desc = "Prijíma reťazce tvaru a⁰⁺b⁰⁺: nula alebo viac 'a', za nimi nula alebo viac 'b'."
    , guideExamplesSection = "Príklady automatov"
    , tutWelcomeTitle = "Vitajte v simulátore DFA/NFA"
    , tutWelcomeBody = "Nastavte jazyk a tému, potom pokračujte k tutoriálu."
    , tutContinueToTutorial = "Pokračovať k tutoriálu"
    , tutSkipTutorial = "Preskočiť tutoriál"
    , tutFinish = "Dokončiť"
    , tutSkip = "Preskočiť"
    , tutStep1 = "Dvojkliknite na plátno a vytvorte prvý stav."
    , tutStep2 = "Vytvorte druhý stav dvojklikom na iné miesto plátna."
    , tutStep3 = "Pravým klikom na stav otvorte modál a zaškrtnite Počiatočný stav."
    , tutStep4 = "Pravým klikom na druhý stav zaškrtnite Koncový stav."
    , tutStep5 = "Kliknite na jeden stav, potom na druhý, zadajte symbol (napr. a) a stlacte Enter alebo OK."
    , tutStep6 = "Automat je pripravený! Kliknite na tlačidlo Simulovať."
    , tutStep7 = "Zadajte vstupné slovo do textového poľa (napr. a)."
    , tutStep8 = "Kliknite na Krok dopredu alebo spustite automatický beh."
    , tutRelaunch = "Spustiť tutoriál"
    }


enTranslations : Translations
enTranslations =
    { darkMode = "Dark mode"
    , language = "Language"
    , languageName = "English"
    , settings = "Settings"
    , guideTitle = "DFA/NFA Simulator Guide"
    , guideTabSimulator = "Simulator"
    , guideTabConversion = "NFA\u{2192}DFA Conversion"
    , guideTabErrors = "Error Messages"
    , guideTabAbout = "About"
    , loadIntoEditor = "Load into editor"
    , notSelected = "not selected"
    , reset = "Reset"
    , build = "Build"
    , delete = "Delete"
    , export = "Export"
    , exportTooltip = "Export"
    , save = "Save"
    , saveTooltip = "Save locally"
    , load = "Load"
    , loadTooltip = "Load locally"
    , shareViaUrl = "Share via URL"
    , shareViaUrlTooltip = "Share via URL"
    , simulate = "Simulate"
    , guide = "Guide"
    , stepBack = "Step back"
    , stepForward = "Step forward"
    , auto = "Auto"
    , pause = "Pause"
    , backToEditor = "<- Editor"
    , replaceAutomaton = "Replace automaton"
    , saveDfa = "Save DFA"
    , stepLabel = "Step"
    , cancel = "Cancel"
    , ok = "OK"
    , deleteStored = "Delete"
    , consoleTitle = "Console"
    , automatonDefinition = "Automaton definition"
    , copied = "Copied"
    , noStartStateSelected = "no start state selected"
    , currentState = "Current state"
    , stateLabel = "State"
    , remainingLabel = "Remaining"
    , emptyInput = "(empty)"
    , deadBranch = "Dead branch"
    , running = "Running"
    , accepted = "Accepted"
    , rejected = "Rejected"
    , instancePrefix = "Instance #"
    , loadMorePrefix = "Load more (showing "
    , loadMoreMiddle = " of "
    , loadMoreSuffix = ")"
    , editorWelcome = "Welcome to the DFA/NFA simulator. Double-click the canvas to add a state."
    , editorAboutProjectLink = "About"
    , editorLoadedFromUrl = "Automaton loaded from URL."
    , editorImportedFromFile = "Automaton imported from file."
    , editorImportErrorPrefix = "Import error: "
    , editorUrlCopied = "URL copied to clipboard."
    , editorDefinitionCopied = "Automaton definition copied to clipboard."
    , editorEnterName = "Enter an automaton name."
    , editorSavedPrefix = "Automaton saved: "
    , editorLoadedPrefix = "Automaton loaded: "
    , editorGenericErrorPrefix = "Error: "
    , editorActionCanceled = "Action canceled."
    , editorStateAddedPrefix = "Added state: "
    , editorEditTransitionSymbol = "Edit the transition symbol."
    , editorStateDeletedPrefix = "Deleted state: "
    , editorTransitionDeletedPrefix = "Deleted transition: "
    , editorEmptyName = "An empty name is not allowed."
    , editorStateExistsPrefix = "A state named '"
    , editorStateExistsSuffix = "' already exists."
    , editorStateRenamedPrefix = "State renamed to: "
    , editorStateUpdatedPrefix = "State updated: "
    , editorReset = "Automaton was reset."
    , editorLoopCannotBeEpsilon = "A loop cannot be an ε-transition."
    , editorTransitionExistsPrefix = "Transition '"
    , editorTransitionExistsSuffix = "' already exists."
    , editorEpsilonTransitionExists = "An ε-transition already exists."
    , editorEpsilonTransitionAdded = "Added ε-transition."
    , editorTransitionsExistPrefix = "Transition(s) already exist: "
    , editorAllTransitionsExist = "All transitions already exist."
    , editorTransitionAddedPrefix = "Added transition: "
    , editorTransitionsAddedPrefix = "Added "
    , editorTransitionsAddedSuffix = " transitions."
    , editorSelectTargetState = "Select a target state for the transition."
    , editorEnterTransitionSymbols = "Enter transition symbol(s), separated by spaces."
    , editorToolBuildMessage = "Tool: Build - double click=new state, click state=transition, fast double click=self-loop, right click=edit state"
    , editorToolDeleteMessage = "Tool: Delete - click a state or transition"
    , editorAddStateRequirement = "Add at least one state."
    , editorStartStateRequirement = "Set a start state."
    , editorEndStateRequirement = "Set at least one end state."
    , editorConvertRequirement = "Convert an NFA (it must contain ε-transitions or multiple transitions for the same symbol)."
    , editorRecenter = "Center"
    , editorEditSymbolLabel = "Edit symbol:"
    , editorSymbolsHint = "To enter multiple symbols, separate with spaces.\nEmpty input represents \u{03B5}."
    , editorEditStateTitle = "Edit state"
    , editorStateNamePlaceholder = "State name"
    , editorStartStateCheckbox = "Start state"
    , editorEndStateCheckbox = "End state"
    , editorCompactStateCheckbox = "Compact state"
    , editorLoadAutomatonTitle = "Load automaton"
    , editorLoadFromJson = "Load from .json file"
    , editorSaveAutomatonTitle = "Save automaton"
    , editorAutomatonNamePlaceholder = "Automaton name"
    , simReady = "Simulator ready. Enter an input word."
    , simInputSetPrefix = "Input set: "
    , simEfficientRunPrefix = "Efficient run: "
    , simWordAccepted = "The word is accepted"
    , simWordRejected = "The word is not accepted"
    , simTransitionThroughPrefix = "Transition through '"
    , simTransitionToStatePrefix = "' to state "
    , simMissingTransitionPrefix = "Error: No transition exists for symbol '"
    , simNoCurrentState = "Error: No current state is set."
    , simEndOfInput = "End of input."
    , simStepBack = "Step back."
    , simStepForwardNfa = "Step forward (NFA)."
    , simAutomatonTab = "Automaton"
    , simTreeTab = "Tree"
    , simInputWordLabel = "Input word"
    , simInputEmptyError = "Input field empty"
    , simInputUnknownSymbols = "Word contains symbols not in alphabet"
    , simMergeUnavailable = "State merging is not available for automata with ε-transitions"
    , simMergeLabel = "Merge states"
    , simMergeTooltip = "Without merging, the number of instances can grow exponentially with input length (up to k^n, where k is the average branching factor and n is the input length). Merging reduces active instances to at most |Q| at each step - the same principle as the subset construction algorithm. Recommended for complex NFAs."
    , simEfficientModeLabel = "Efficient mode"
    , simEfficientModeTooltip = "Efficient mode runs the simulation at once without building the instance tree. Suitable for complex NFAs with long input where classic simulation would be too slow."
    , simInstantRun = "Instant run"
    , simReachedStatesPrefix = "Reached states: "
    , simInstancePanelDisabled = "The instance panel is disabled in efficient mode."
    , convStarted = "NFA -> DFA conversion started."
    , convFinished = "Conversion finished."
    , convAutomatonReplaced = "Automaton replaced with the converted DFA."
    , convDfaSavedPrefix = "DFA saved: "
    , convStepDescription = "Step description"
    , convOriginalNfaStates = "Original NFA states"
    , convSubsetTable = "Subset table"
    , convStateColumn = "State"
    , convStartColumn = "Start"
    , convEndColumn = "End"
    , convDfaStateColumn = "DFA state"
    , convInitPrefix = "ε-closure of the start state = "
    , convInitSuffix = ". This is the initial DFA state."
    , convProcessingPrefix = "Processing "
    , convDeadStateSuffix = ". move = ∅. Dead state (∅), skipped."
    , convMovePrefix = ". move = "
    , convClosurePrefix = ", ε-closure = "
    , convNewStateCreated = ". New state created."
    , convStateAlreadyExists = ". The state already exists."
    , convStateProcessedPrefix = "State "
    , convStateProcessedSuffix = " is fully processed."
    , convConstructionDone = "DFA construction is complete."
    , example1Name = "DFA – ends with 'a'"
    , example1Desc = "Accepts strings over {a,b} ending with 'a'. Example: a, ba, aba."
    , example2Name = "DFA – even number of zeros"
    , example2Desc = "Accepts binary strings with an even number of '0' symbols (including zero zeros). Example: ε, 00, 11, 1001."
    , example3Name = "NFA – ends with '01'"
    , example3Desc = "A nondeterministic automaton accepting strings over {0,1} that end with the substring '01'. Example: 01, 101, 0101."
    , example4Name = "NFA with ε – accepts 'a' or 'ab'"
    , example4Desc = "An NFA with an epsilon transition: q1 →ε→ q2 (accepts 'a'), q1 →b→ q3 (accepts 'ab'). Demonstrates ε-transitions."
    , example5Name = "NFA – second-to-last symbol is '1'"
    , example5Desc = "Accepts strings over {0,1} of length ≥ 2 where the second-to-last symbol is '1'. Example: 10, 11, 010, 110."
    , example6Name = "ε-NFA – a*b*"
    , example6Desc = "Accepts strings of the form a⁰⁺b⁰⁺: zero or more 'a' symbols followed by zero or more 'b' symbols."
    , guideExamplesSection = "Example automata"
    , tutWelcomeTitle = "Welcome to the DFA/NFA Simulator"
    , tutWelcomeBody = "Choose your language and theme, then start the tutorial."
    , tutContinueToTutorial = "Continue to Tutorial"
    , tutSkipTutorial = "Skip Tutorial"
    , tutFinish = "Finish"
    , tutSkip = "Skip"
    , tutStep1 = "Double-click on the canvas to create your first state."
    , tutStep2 = "Create a second state by double-clicking elsewhere on the canvas."
    , tutStep3 = "Right-click a state to open the modal and check Start state."
    , tutStep4 = "Right-click the other state and check End state."
    , tutStep5 = "Click one state, then another, enter a symbol (e.g. a) and press Enter or click OK."
    , tutStep6 = "Your automaton is ready! Click the Simulate button."
    , tutStep7 = "Type an input word into the text field (e.g. a)."
    , tutStep8 = "Click Step Forward or start Auto-run."
    , tutRelaunch = "Relaunch Tutorial"
    }


getTranslations : Language -> Translations
getTranslations lang =
    case lang of
        Slovak ->
            skTranslations

        English ->
            enTranslations


row : String -> String -> GuideRowText
row label description =
    { label = label, description = description }


errorRow : String -> String -> GuideErrorText
errorRow error cause =
    { error = error, cause = cause }


section : String -> List GuideRowText -> List String -> List String -> GuideSectionText
section title rows notes paragraphs =
    { title = title, rows = rows, notes = notes, paragraphs = paragraphs }


guideEditorPage : Language -> GuidePageText
guideEditorPage lang =
    case lang of
        Slovak ->
            { intro = [ "Editor slúži na budovanie deterministických (DFA) a nedeterministických (NFA) konečných automatov. Stavy a prechody vytvárate priamo na plátne." ]
            , sections =
                [ section "Akcie na plátne (nástroj Stavať)"
                    [ row "Pridanie stavu" "Dvojklik na prázdne plátno (predvolený názov q0, q1, ...)"
                    , row "Premenovanie stavu" "Pravý klik na stav -> upraviť názov v modáli"
                    , row "Nastavenie počiatočného stavu" "Pravý klik na stav -> zaškrtnúť Počiatočný stav"
                    , row "Nastavenie koncového stavu" "Pravý klik na stav -> zaškrtnúť Koncový stav"
                    , row "Pridanie prechodu" "Kliknutie na zdrojový stav, potom kliknutie na cieľový stav"
                    , row "Pridanie slučky (self-loop)" "Rýchly dvojklik na stav"
                    , row "Epsilon prechod" "Nechajte vstupné pole prázdne"
                    , row "Viac prechodov naraz" "Symboly oddeľujte čiarkou, napr. a,b"
                    , row "Úprava symbolu prechodu" "Dvojklik na symbol prechodu"
                    , row "Presun stavu" "Ťahanie stavu myšou"
                    , row "Zrušenie akcie / výberu" "Klik na prázdne plátno alebo Escape"
                    ]
                    []
                    []
                , section "Nástroje"
                    [ row "Stavať  (Shift+B)" "Predvolený nástroj: vytváranie stavov a prechodov"
                    , row "Odstrániť  (Shift+D)" "Klik na stav alebo prechod ho vymaže; opätovné kliknutie prepne späť na Stavať"
                    ]
                    []
                    []
                , section "Klávesové skratky"
                    [ row "Ctrl+Z / Ctrl+Y" "Späť / Dopredu (undo/redo)"
                    , row "Shift+B" "Nástroj Stavať"
                    , row "Shift+D" "Nástroj Odstrániť"
                    , row "Escape" "Zruší aktuálnu akciu (zatvorí vstupné polia, modály)"
                    ]
                    []
                    []
                , section "Navigácia plátna"
                    [ row "Koliesko myši (alebo +/- tlačidlá)" "Priblíženie / oddialenie"
                    , row "Ťahanie prázdneho plátna" "Posúvanie pohľadu (pan)"
                    ]
                    []
                    []
                , section "Súbory a ukladanie"
                    [ row "Export" "Stiahne automat ako súbor .json"
                    , row "Uložiť" "Uloží automat do lokálneho úložiska prehliadača s názvom"
                    , row "Načítať" "Načíta zo súboru .json alebo z lokálneho úložiska"
                    , row "Zdieľať cez URL" "Zakóduje automat do URL (hash); zdieľateľný link"
                    ]
                    [ "Lokálne úložisko je viazané na prehliadač a doménu. Automaty zo sprievodcu sa do neho neukladajú." ]
                    []
                , section "Konzola"
                    []
                    []
                    [ "Spodná lišta zobrazuje informačné a chybové správy. Konzola je skrývateľná - kliknutím na lištu ju zrolujete alebo rozbalíte." ]
                ]
            }

        English ->
            { intro = [ "The editor is used to build deterministic (DFA) and nondeterministic (NFA) finite automata. You create states and transitions directly on the canvas." ]
            , sections =
                [ section "Canvas actions (Build tool)"
                    [ row "Add state" "Double-click empty canvas (default name q0, q1, ...)"
                    , row "Rename state" "Right-click on a state -> edit the name in the modal"
                    , row "Set start state" "Right-click on a state -> check Start state"
                    , row "Set end state" "Right-click on a state -> check End state"
                    , row "Add transition" "Click the source state, then click the target state"
                    , row "Add self-loop" "Fast double-click on a state"
                    , row "Epsilon transition" "Leave the input field empty"
                    , row "Add multiple transitions" "Separate symbols with commas, e.g. a,b"
                    , row "Edit transition symbol" "Double-click the transition symbol"
                    , row "Move state" "Drag the state with the mouse"
                    , row "Cancel action / selection" "Click empty canvas or press Escape"
                    ]
                    []
                    []
                , section "Tools"
                    [ row "Build  (Shift+B)" "Default tool: create states and transitions"
                    , row "Delete  (Shift+D)" "Click a state or transition to remove it; click again to switch back to Build"
                    ]
                    []
                    []
                , section "Keyboard shortcuts"
                    [ row "Ctrl+Z / Ctrl+Y" "Back / Forward (undo/redo)"
                    , row "Shift+B" "Build tool"
                    , row "Shift+D" "Delete tool"
                    , row "Escape" "Cancels the current action (closes input fields and modals)"
                    ]
                    []
                    []
                , section "Canvas navigation"
                    [ row "Mouse wheel (or +/- buttons)" "Zoom in / out"
                    , row "Drag empty canvas" "Pan the view"
                    ]
                    []
                    []
                , section "Files and saving"
                    [ row "Export" "Downloads the automaton as a .json file"
                    , row "Save" "Saves the automaton to browser local storage with a name"
                    , row "Load" "Loads from a .json file or browser local storage"
                    , row "Share via URL" "Encodes the automaton into the URL hash; shareable link"
                    ]
                    [ "Local storage is tied to the browser and domain. Automata from the guide are not stored there." ]
                    []
                , section "Console"
                    []
                    []
                    [ "The bottom bar shows informational and error messages. The console can be collapsed or expanded by clicking the bar." ]
                ]
            }


guideSimulatorPage : Language -> GuidePageText
guideSimulatorPage lang =
    case lang of
        Slovak ->
            { intro = [ "Simulátor umožňuje spúšťať automat krok za krokom na zadanom vstupnom reťazci. Tlačidlo Simulovať je aktívne len vtedy, keď automat má počiatočný aj aspoň jeden koncový stav." ]
            , sections =
                [ section "Ovládanie"
                    [ row "Vstupné pole" "Zadajte reťazec, ktorý chcete simulovať (napr. aab)"
                    , row "Krok vpred" "Prečíta ďalší symbol a posunie simuláciu o jeden krok"
                    , row "Krok späť" "Vráti simuláciu do predchádzajúceho stavu"
                    , row "Reset" "Vráti simuláciu na začiatok (vstup zostane)"
                    , row "Auto / Pauza" "Spustí / pozastaví automatické krokovanie"
                    , row "Posuvník rýchlosti" "Nastaví interval krokovania (100 ms - 2 s)"
                    ]
                    []
                    []
                , section "DFA simulácia"
                    [ row "Aktívny stav" "Zvýraznený na plátne modrým orámovaním"
                    , row "Aktívny prechod" "Šípka prechodu sa zvýrazní pri každom kroku"
                    , row "Výsledok" "Zelená = Akceptované, červená = Zamietnuté"
                    ]
                    [ "DFA má vždy práve jednu aktívnu cestu - žiadny nedeterminizmus." ]
                    []
                , section "NFA simulácia"
                    [ row "Inštancie" "Každá inštancia sleduje jednu možnú cestu v automate"
                    , row "Panel inštancií (vľavo)" "Zoznam všetkých inštancií; klik = zvýrazní stav na plátne"
                    , row "Stav inštancie" "Modrá = bežiaca, zelená = akceptovala, červená = zamietnutá"
                    , row "Strom rozhodnutí (vpravo)" "Vizualizácia všetkých ciest vrátane eps-krokov; sivé uzly = ukončené predka"
                    , row "Klik na uzol stromu" "Zvýrazní zodpovedajúcu inštanciu a stav na plátne"
                    , row "Prepínače Plátno / Strom" "Zobraziť alebo skryť každú sekciu nezávisle"
                    , row "Zlúčiť stavy" "Ak zaškrtnuté: inštancie s rovnakým (stav, zostatok vstupu) sa zlúčia do jednej."
                    ]
                    [ "NFA akceptuje reťazec, ak aspoň jedna inštancia dosiahne akceptujúci stav po prečítaní celého vstupu." ]
                    []
                , section "Efektívny režim (NFA)"
                    [ row "Zaškrtnite Efektívny režim" "V pravom paneli NFA simulátora zapne efektívny režim."
                    , row "Okamžitý beh" "Spustí kompletnú simuláciu naraz bez budovania inštancií."
                    ]
                    [ "V efektívnom režime je krokovanie, auto-run a panel inštancií deaktivovaný." ]
                    []
                , section "eps-prechody v NFA"
                    [ row "eps-rozvinutie" "Po každom symbolickom kroku sa automaticky vytvoria eps-deti"
                    , row "Zobrazenie" "eps-kroky sú viditeľné v strome rozhodnutí ako samostatné úrovne"
                    ]
                    []
                    []
                ]
            }

        English ->
            { intro = [ "The simulator lets you run the automaton step by step on a given input string. The Simulate button is only active when the automaton has a start state and at least one end state." ]
            , sections =
                [ section "Controls"
                    [ row "Input field" "Enter the string you want to simulate (e.g. aab)"
                    , row "Step forward" "Reads the next symbol and advances the simulation by one step"
                    , row "Step back" "Returns the simulation to the previous state"
                    , row "Reset" "Returns the simulation to the start (input remains)"
                    , row "Auto / Pause" "Starts or pauses automatic stepping"
                    , row "Speed slider" "Sets the stepping interval (100 ms - 2 s)"
                    ]
                    []
                    []
                , section "DFA simulation"
                    [ row "Active state" "Highlighted on the canvas with a blue outline"
                    , row "Active transition" "The transition arrow is highlighted on every step"
                    , row "Result" "Green = accepted, red = rejected"
                    ]
                    [ "A DFA always has exactly one active path - no nondeterminism." ]
                    []
                , section "NFA simulation"
                    [ row "Instances" "Each instance follows one possible path through the automaton"
                    , row "Instance panel (left)" "List of all instances; click to highlight the state on the canvas"
                    , row "Instance status" "Blue = running, green = accepted, red = rejected"
                    , row "Decision tree (right)" "Visualization of all paths including eps steps; gray nodes = terminated ancestors"
                    , row "Click a tree node" "Highlights the corresponding instance and state on the canvas"
                    , row "Canvas / Tree toggles" "Show or hide each section independently"
                    , row "Merge states" "If checked: instances with the same (state, remaining input) are merged into one."
                    ]
                    [ "An NFA accepts a string if at least one instance reaches an accepting state after reading the full input." ]
                    []
                , section "Efficient mode (NFA)"
                    [ row "Enable Efficient mode" "Turns on efficient mode in the NFA simulator right panel."
                    , row "Instant run" "Runs the entire simulation at once without building instances."
                    ]
                    [ "In efficient mode, stepping, auto-run, and the instance panel are disabled." ]
                    []
                , section "eps-transitions in NFAs"
                    [ row "eps expansion" "After every symbolic step, eps children are created automatically"
                    , row "Display" "eps steps are visible in the decision tree as separate levels"
                    ]
                    []
                    []
                ]
            }


guideConversionPage : Language -> GuidePageText
guideConversionPage lang =
    case lang of
        Slovak ->
            { intro = [ "Konverzia NFA->DFA prevádza nedeterministický automat na ekvivalentný deterministický pomocou algoritmu podmnožín (subset construction)." ]
            , sections =
                [ section "Kľúčové pojmy"
                    [ row "eps-closure(S)" "Množina všetkých stavov dosiahnuteľných z množiny S cez eps-prechody (vrátane S)."
                    , row "move(S, a)" "Množina NFA stavov dosiahnuteľných z niektorého stavu S po symbole a (bez eps)."
                    , row "DFA stav" "Každý stav výsledného DFA zodpovedá podmnožine NFA stavov."
                    ]
                    [ "DFA stav je akceptujúci práve vtedy, keď obsahuje aspoň jeden akceptujúci NFA stav." ]
                    []
                , section "Algoritmus podmnožín (krok za krokom)"
                    [ row "1. Počiatočný stav" "Vypočítaj eps-closure({q0_NFA}) - to je počiatočný DFA stav."
                    , row "2. Výber z worklistu" "Vyber nespracovaný DFA stav S."
                    , row "3. Pre každý symbol a" "Vypočítaj T = eps-closure(move(S, a))."
                    , row "4. Nový stav?" "Ak T ešte neexistuje ako DFA stav, vytvor ho a pridaj do worklistu."
                    , row "5. Prechod" "Pridaj DFA prechod S ->a-> T."
                    , row "6. Označ S" "Označ DFA stav S ako spracovaný."
                    , row "7. Opakovanie" "Pokračuj, kým worklist nie je prázdny."
                    ]
                    []
                    []
                , section "Vizualizácia konverzie"
                    [ row "Plátno" "DFA stavy (podmnožiny NFA stavov); farebné zvýraznenie"
                    , row "Pravý panel - Popis kroku" "Textové vysvetlenie aktuálneho kroku algoritmu"
                    , row "Navigácia" "Pohyb cez jednotlivé kroky algoritmu dopredu/dozadu"
                    ]
                    []
                    []
                , section "Výstup konverzie"
                    [ row "Nahradiť automat" "Otvorí výsledný DFA v editore (nahradí aktuálny automat)"
                    , row "Uložiť DFA" "Uloží výsledný DFA do lokálneho úložiska prehliadača s názvom"
                    ]
                    [ "Tlačidlá Nahradiť a Uložiť sú aktívne až po dokončení posledného kroku konverzie." ]
                    []
                ]
            }

        English ->
            { intro = [ "NFA -> DFA conversion transforms a nondeterministic automaton into an equivalent deterministic one using the subset construction algorithm." ]
            , sections =
                [ section "Key concepts"
                    [ row "eps-closure(S)" "The set of all states reachable from set S via eps transitions (including S)."
                    , row "move(S, a)" "The set of NFA states reachable from some state in S on symbol a (without eps)."
                    , row "DFA state" "Each state of the resulting DFA corresponds to a subset of NFA states."
                    ]
                    [ "A DFA state is accepting iff it contains at least one accepting NFA state." ]
                    []
                , section "Subset construction (step by step)"
                    [ row "1. Initial state" "Compute eps-closure({q0_NFA}) - that is the initial DFA state."
                    , row "2. Pick from worklist" "Select an unprocessed DFA state S."
                    , row "3. For each symbol a" "Compute T = eps-closure(move(S, a))."
                    , row "4. New state?" "If T does not yet exist as a DFA state, create it and add it to the worklist."
                    , row "5. Transition" "Add DFA transition S ->a-> T."
                    , row "6. Mark S" "Mark DFA state S as processed."
                    , row "7. Repeat" "Continue until the worklist is empty."
                    ]
                    []
                    []
                , section "Conversion visualization"
                    [ row "Canvas" "DFA states (subsets of NFA states) with color highlighting"
                    , row "Right panel - Step description" "Text explanation of the current algorithm step"
                    , row "Navigation" "Move through individual algorithm steps forward/backward"
                    ]
                    []
                    []
                , section "Conversion output"
                    [ row "Replace automaton" "Opens the resulting DFA in the editor (replaces the current automaton)"
                    , row "Save DFA" "Saves the resulting DFA to browser local storage with a name"
                    ]
                    [ "The Replace and Save buttons become active only after the last conversion step is completed." ]
                    []
                ]
            }


guideErrorsPage : Language -> GuideErrorsPageText
guideErrorsPage lang =
    case lang of
        Slovak ->
            { intro = "Zoznam chýb a upozornení, ktoré sa môžu v aplikácii objaviť, vrátane ich príčiny a riešenia."
            , sections =
                [ { title = "Chyby v editore"
                  , rows =
                        [ errorRow "Prázdny názov nie je povolený" "Stav musí mať neprázdny názov. Zadajte aspoň jeden znak."
                        , errorRow "Stav s názvom '...' už existuje" "Každý stav musí mať unikátny názov. Zvoľte iný názov."
                        , errorRow "Slučka nemôže byť eps-prechodom" "Epsilon self-loop (stav na seba samého) nie je povolený."
                        , errorRow "Prechod '...' už existuje" "Duplikátny prechod: rovnaký (zdroj, symbol, cieľ) už existuje."
                        , errorRow "Symbol nemôže obsahovať medzery" "Symbol prechodu nesmie obsahovať medzery."
                        , errorRow "Chyba importu: ..." "Neplatný JSON súbor alebo formát nezodpovedá schéme automatu."
                        ]
                  }
                , { title = "Neaktívne tlačidlá (podmienky spustenia)"
                  , rows =
                        [ errorRow "Simulovať - 'Pridajte aspoň jeden stav'" "Automat nemá žiadne stavy. Dvojklikom na plátno pridajte stav."
                        , errorRow "Simulovať - 'Nastavte počiatočný stav'" "Automat nemá počiatočný stav. Dvojklik na stav -> zaškrtnúť Počiatočný stav."
                        , errorRow "Simulovať - 'Nastavte aspoň jeden koncový stav'" "Automat nemá žiadny akceptujúci stav. Nastavte ho cez modál stavu."
                        , errorRow "NFA->DFA - dostupné iba pre NFA" "Tlačidlo je neaktívne pre DFA (žiadne eps-prechody ani nedeterminizmus)."
                        ]
                  }
                ]
            }

        English ->
            { intro = "A list of errors and warnings that can appear in the app, including their cause and resolution."
            , sections =
                [ { title = "Editor errors"
                  , rows =
                        [ errorRow "An empty name is not allowed" "A state must have a non-empty name. Enter at least one character."
                        , errorRow "A state named '...' already exists" "Each state must have a unique name. Choose a different name."
                        , errorRow "A loop cannot be an eps-transition" "An epsilon self-loop is not allowed."
                        , errorRow "Transition '...' already exists" "Duplicate transition: the same (source, symbol, target) already exists."
                        , errorRow "A symbol cannot contain spaces" "A transition symbol must not contain spaces."
                        , errorRow "Import error: ..." "The JSON file is invalid or its format does not match the automaton schema."
                        ]
                  }
                , { title = "Disabled buttons (launch conditions)"
                  , rows =
                        [ errorRow "Simulate - 'Add at least one state'" "The automaton has no states. Double-click the canvas to add one."
                        , errorRow "Simulate - 'Set a start state'" "The automaton has no start state. Double-click a state and check Start state."
                        , errorRow "Simulate - 'Set at least one end state'" "The automaton has no accepting state. Set it in the state modal."
                        , errorRow "NFA->DFA - available only for NFAs" "The button is inactive for DFAs (no eps-transitions or nondeterminism)."
                        ]
                  }
                ]
            }


guideAboutPage : Language -> AboutPageText
guideAboutPage lang =
    case lang of
        Slovak ->
            { sectionTitle = "O projekte"
            , rows =
                [ row "Názov" "Simulátor konečných automatov (DFA/NFA)"
                , row "Typ" "Bakalárska práca"
                , row "Rok" "2026"
                , row "Škola" "STU FIIT"
                ]
            , contactPrefix = "Spätná väzba, otázky alebo hlásenie chýb - napíšte na: "
            }

        English ->
            { sectionTitle = "About the project"
            , rows =
                [ row "Name" "Finite automata simulator (DFA/NFA)"
                , row "Type" "Bachelor thesis"
                , row "Year" "2026"
                , row "School" "STU FIIT"
                ]
            , contactPrefix = "Feedback, questions, or bug reports - write to: "
            }
