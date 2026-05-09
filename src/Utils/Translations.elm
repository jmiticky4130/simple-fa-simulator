module Utils.Translations exposing
    ( AboutPageText
    , GuideErrorSectionText
    , GuideErrorText
    , GuideErrorsPageText
    , GuideInfoPageText
    , GuideInfoSectionText
    , GuideInfoText
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
    , guideInfoPage
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


type alias GuideInfoText =
    { message : String
    , when : String
    }


type alias GuideInfoSectionText =
    { title : String
    , rows : List GuideInfoText
    }


type alias GuideInfoPageText =
    { intro : String
    , sections : List GuideInfoSectionText
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
    , guideTabInfo : String
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
    , incompleteDfaLabel : String
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
    , editorTransitionDeletedAll : String
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
    , convWithSymbol : String
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
    , tutTipEscape : String
    , tutStep1 : String
    , tutStep2 : String
    , tutStep3 : String
    , tutStep4 : String
    , tutStep5 : String
    , tutStep6 : String
    , tutStep7 : String
    , tutStep8 : String
    , tutStepUndoRedo : String
    , tutStepTools : String
    , tutStepFiles : String
    , tutStepConvert : String
    , tutUnderstand : String
    , tutRelaunch : String
    , simWhyNfaTitle : String
    , simWhyIncompleteDfaTitle : String
    , simWhyNfaIncomplete : String
    , simWhyNfaNondet : String
    , simWhyNfaEpsilon : String
    , editorConvertRequirementIncomplete : String
    , editorAddDeadState : String
    , editorAddDeadStateInfo : String
    , editorDeadStateAdded : String
    , gridMode : String
    , tapeExpandLabel : String
    , tapeCollapseLabel : String
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
    , guideTabInfo = "Informačné správy"
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
    , backToEditor = "Editor"
    , replaceAutomaton = "Nahradiť automat"
    , saveDfa = "Uložiť DFA"
    , stepLabel = "Krok"
    , cancel = "Zrušiť"
    , ok = "OK"
    , deleteStored = "Vymazať"
    , consoleTitle = "Konzola"
    , automatonDefinition = "Definícia automatu"
    , incompleteDfaLabel = "Neúplný DFA"
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
    , editorTransitionDeletedAll = "Odstránené všetky prechody."
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
    , editorTransitionsAddedPrefix = "Pridané"
    , editorTransitionsAddedSuffix = " prechody."
    , editorSelectTargetState = "Vyberte cieľový stav pre prechod."
    , editorEnterTransitionSymbols = "Zadajte symbol(y) pre prechod (oddeľte medzerou)."
    , editorToolBuildMessage = "Nástroj: Stavať - dvojklik na plátno=nový stav, klik na stav=prechod, klik na prechod=upraviť symbol, dvojklik na stav=slučka, pravý klik na stav=upraviť stav"
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
    , simInstancePanelDisabled = "Panel inštancií je deaktivovaný v efektívnom režime."
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
    , convWithSymbol = " so symbolom '"
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
    , tutTipEscape = "zruší aktuálnu akciu"
    , tutStep1 = "Dvojkliknite na plátno a vytvorte prvý stav."
    , tutStep2 = "Vytvorte druhý stav dvojklikom na iné miesto plátna."
    , tutStep3 = "Pravým klikom na stav otvorte modál a zaškrtnite Počiatočný stav."
    , tutStep4 = "Pravým klikom na druhý stav zaškrtnite Koncový stav."
    , tutStep5 = "Kliknite na jeden stav, potom na druhý, zadajte symbol (napr. a) a stlacte Enter alebo OK."
    , tutStep6 = "Automat je pripravený! Kliknite na tlačidlo Simulovať."
    , tutStep7 = "Zadajte vstupné slovo do textového poľa (napr. a)."
    , tutStep8 = "Kliknite na Krok dopredu alebo spustite automatický beh."
    , tutStepUndoRedo = "Reset vymaže celý automat. Späť/Vpred vráti alebo zopakuje posledný krok (Ctrl+Z / Ctrl+Y)."
    , tutStepTools = "Nástroj Stavať (Shift+B) slúži na vytváranie stavov a prechodov. Nástroj Mazať (Shift+D) odstraňuje stavy a prechody kliknutím."
    , tutStepFiles = "Export uloží automat ako JSON súbor. Uložiť/Načítať pracuje s lokálnym úložiskom prehliadača. Zdieľať vytvorí URL odkaz."
    , tutStepConvert = "NFA->DFA spustí podmnožinovú konštrukciu (aktívne len ak je automat NFA). Doplniť mŕtvy stav doplní chýbajúce prechody."
    , tutUnderstand = "Rozumiem"
    , tutRelaunch = "Spustiť tutoriál"
    , simWhyNfaTitle = "Prečo NFA?"
    , simWhyIncompleteDfaTitle = "Prečo neúplný DFA?"
    , simWhyNfaIncomplete = "Automat je neúplný — niektorým stavom chýbajú prechody pre symboly abecedy. Použite tlačidlo 'Doplniť mŕtvy stav' na doplnenie formálne správneho DFA."
    , simWhyNfaNondet = "Viacero prechodov z rovnakého stavu s rovnakým symbolom."
    , simWhyNfaEpsilon = "Obsahuje ε-prechody."
    , editorConvertRequirementIncomplete = "Neúplný DFA — nie je nedeterministický automat"
    , editorAddDeadState = "Doplniť mŕtvy stav"
    , editorAddDeadStateInfo = "Automat je neúplný DFA — niektorým stavom chýbajú prechody pre niektoré symboly abecedy. Kliknutím pridáte mŕtvy stav, ktorý zachytí všetky chýbajúce prechody. Automat tak bude formálne úplný DFA."
    , editorDeadStateAdded = "Mŕtvy stav bol pridaný. Automat je teraz úplný DFA."
    , gridMode = "Mriežka"
    , tapeExpandLabel = "Zobraziť všetky"
    , tapeCollapseLabel = "Zbaliť"
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
    , guideTabInfo = "Info Messages"
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
    , backToEditor = "Editor"
    , replaceAutomaton = "Replace automaton"
    , saveDfa = "Save DFA"
    , stepLabel = "Step"
    , cancel = "Cancel"
    , ok = "OK"
    , deleteStored = "Delete"
    , consoleTitle = "Console"
    , automatonDefinition = "Automaton definition"
    , incompleteDfaLabel = "Incomplete DFA"
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
    , editorTransitionDeletedAll = "All transitions deleted."
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
    , editorToolBuildMessage = "Tool: Build - double click on empty canvas=new state, click two states=transition, click transition=edit symbol, double click on state=self-loop, right click state=edit state"
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
    , convWithSymbol = " with symbol: "
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
    , tutTipEscape = "cancels the current action"
    , tutStep1 = "Double-click on the canvas to create your first state."
    , tutStep2 = "Create a second state by double-clicking elsewhere on the canvas."
    , tutStep3 = "Right-click a state to open the modal and check Start state."
    , tutStep4 = "Right-click the other state and check End state."
    , tutStep5 = "Click one state, then another, enter a symbol (e.g. a) and press Enter or click OK."
    , tutStep6 = "Your automaton is ready! Click the Simulate button."
    , tutStep7 = "Type an input word into the text field (e.g. a)."
    , tutStep8 = "Click Step Forward or start Auto-run."
    , tutStepUndoRedo = "Reset clears the entire automaton. Undo/Redo reverts or repeats the last action (Ctrl+Z / Ctrl+Y)."
    , tutStepTools = "Build tool (Shift+B) creates states and transitions. Delete tool (Shift+D) removes states and transitions by clicking."
    , tutStepFiles = "Export saves the automaton as a JSON file. Save/Load works with browser local storage. Share creates a URL link."
    , tutStepConvert = "NFA->DFA runs subset construction (active only for NFA). Add dead state fills in missing transitions."
    , tutUnderstand = "Understand"
    , tutRelaunch = "Relaunch Tutorial"
    , simWhyNfaTitle = "Why NFA?"
    , simWhyIncompleteDfaTitle = "Why incomplete DFA?"
    , simWhyNfaNondet = "Non-deterministic — multiple transitions from same state with same symbol."
    , simWhyNfaIncomplete = "Automaton is incomplete — some states are missing transitions for alphabet symbols. Use 'Add dead state' to complete the automaton as a formally correct DFA."
    , simWhyNfaEpsilon = "Contains ε-transitions."
    , editorConvertRequirementIncomplete = "Incomplete DFA — not a non-deterministic automaton"
    , editorAddDeadState = "Add dead state"
    , editorAddDeadStateInfo = "The automaton is an incomplete DFA — some states are missing transitions for certain alphabet symbols. Clicking this adds a dead (trap) state that catches all missing transitions, making the automaton a formally complete DFA."
    , editorDeadStateAdded = "Dead state added. The automaton is now a complete DFA."
    , gridMode = "Grid"
    , tapeExpandLabel = "Show all"
    , tapeCollapseLabel = "Collapse"
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
                    , row "Úprava symbolu prechodu" "Klik na symbol prechodu"
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
                    , row "Edit transition symbol" "Click the transition symbol"
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
            { intro = "Zoznam chybových správ, ktoré sa zobrazujú v konzole aplikácie, vrátane ich príčiny."
            , sections =
                [ { title = "Chyby v editore"
                  , rows =
                        [ errorRow "Zadajte názov automatu." "Pokus o uloženie automatu bez zadaného názvu."
                        , errorRow "Prázdny názov nie je povolený." "Stav musí mať neprázdny názov. Zadajte aspoň jeden znak."
                        , errorRow "Stav s názvom '...' už existuje." "Každý stav musí mať unikátny názov. Zvoľte iný názov."
                        , errorRow "Slučka nemôže byť ε-prechodom." "Epsilon self-loop (stav na seba samého) nie je povolený."
                        , errorRow "ε-prechod už existuje." "Medzi danými dvoma stavmi už existuje ε-prechod."
                        , errorRow "Prechod(y) už existujú: ..." "Niektoré z vložených symbolov už majú prechod medzi týmito stavmi."
                        , errorRow "Chyba importu: ..." "Neplatný JSON súbor alebo formát nezodpovedá schéme automatu."
                        , errorRow "Chyba: ..." "Generická chyba (napr. chyba pri spracovaní URL alebo dekódovaní JSON)."
                        ]
                  }
                , { title = "Chyby simulátora"
                  , rows =
                        [ errorRow "Chyba: Neexistuje prechod pre symbol '...'" "DFA nemá definovaný prechod pre daný symbol z aktuálneho stavu. Simulácia je zablokovaná (neúplný DFA)."
                        , errorRow "Chyba: Nie je nastavený aktuálny stav." "Interná chyba — stav simulátora nie je inicializovaný. Spustite simuláciu znovu."
                        ]
                  }
                , { title = "Neaktívne tlačidlá (podmienky spustenia)"
                  , rows =
                        [ errorRow "Simulovať — 'Pridajte aspoň jeden stav'" "Automat nemá žiadne stavy. Dvojklikom na plátno pridajte stav."
                        , errorRow "Simulovať — 'Nastavte počiatočný stav'" "Automat nemá počiatočný stav. Pravý klik na stav -> zaškrtnúť Počiatočný stav."
                        , errorRow "Simulovať — 'Nastavte aspoň jeden koncový stav'" "Automat nemá žiadny akceptujúci stav. Nastavte ho cez modál stavu."
                        , errorRow "NFA->DFA — dostupné iba pre NFA" "Tlačidlo je neaktívne pre DFA (žiadne ε-prechody ani nedeterminizmus)."
                        ]
                  }
                ]
            }

        English ->
            { intro = "A list of error messages shown in the console, including their cause."
            , sections =
                [ { title = "Editor errors"
                  , rows =
                        [ errorRow "Enter an automaton name." "Attempted to save the automaton without entering a name."
                        , errorRow "An empty name is not allowed." "A state must have a non-empty name. Enter at least one character."
                        , errorRow "A state named '...' already exists." "Each state must have a unique name. Choose a different name."
                        , errorRow "A loop cannot be an ε-transition." "Epsilon self-loops are not allowed."
                        , errorRow "An ε-transition already exists." "An epsilon transition between these two states already exists."
                        , errorRow "Transition(s) already exist: ..." "Some of the entered symbols already have a transition between these states."
                        , errorRow "Import error: ..." "The JSON file is invalid or its format does not match the automaton schema."
                        , errorRow "Error: ..." "A generic error (e.g. bad URL or JSON decode failure)."
                        ]
                  }
                , { title = "Simulator errors"
                  , rows =
                        [ errorRow "Error: No transition exists for symbol '...'" "The DFA has no transition for this symbol from the current state. Simulation is blocked (incomplete DFA)."
                        , errorRow "Error: No current state is set." "Internal error — simulator state not initialised. Restart the simulation."
                        ]
                  }
                , { title = "Disabled buttons (launch conditions)"
                  , rows =
                        [ errorRow "Simulate — 'Add at least one state'" "The automaton has no states. Double-click the canvas to add one."
                        , errorRow "Simulate — 'Set a start state'" "The automaton has no start state. Right-click a state and check Start state."
                        , errorRow "Simulate — 'Set at least one end state'" "The automaton has no accepting state. Set it via the state modal."
                        , errorRow "NFA->DFA — available only for NFAs" "The button is inactive for DFAs (no ε-transitions or nondeterminism)."
                        ]
                  }
                ]
            }


infoRow : String -> String -> GuideInfoText
infoRow message when =
    { message = message, when = when }


guideInfoPage : Language -> GuideInfoPageText
guideInfoPage lang =
    case lang of
        Slovak ->
            { intro = "Prehľad informačných správ, ktoré konzola zobrazuje pri úspešnom vykonaní akcií. Správy potvrdzujú každú zmenu automatu a uľahčujú orientáciu v aplikácii."
            , sections =
                [ { title = "Vítanie a načítavanie"
                  , rows =
                        [ infoRow "Vitajte v simulátore DFA/NFA. Dvojklikom na plátno pridajte stav." "Prvé otvorenie aplikácie bez automatu v URL"
                        , infoRow "Automat načítaný z URL." "Stránka otvorená s #a=... v adrese (zdieľaný odkaz)"
                        , infoRow "Automat importovaný zo súboru." "Úspešný import súboru .json"
                        , infoRow "Automat načítaný: <meno>" "Načítanie pomenovaného automatu z lokálneho úložiska prehliadača"
                        ]
                  }
                , { title = "Ukladanie a zdieľanie"
                  , rows =
                        [ infoRow "URL skopírovaná do schránky." "Klik na tlačidlo Zdieľať cez URL"
                        , infoRow "Definícia automatu skopírovaná do schránky." "Klik na Kopírovať definíciu v paneli definície automatu"
                        , infoRow "Automat uložený: <meno>" "Úspešné uloženie automatu do lokálneho úložiska"
                        ]
                  }
                , { title = "Stavy"
                  , rows =
                        [ infoRow "Pridaný stav: q0" "Dvojklik na prázdne plátno (názov je predvolený)"
                        , infoRow "Mŕtvy stav bol pridaný. Automat je teraz úplný DFA." "Klik na tlačidlo Doplniť mŕtvy stav"
                        , infoRow "Vyberte cieľový stav pre prechod." "1. klik pri tvorbe prechodu (označenie zdrojového stavu)"
                        , infoRow "Zadajte symbol(y) pre prechod (oddeľte medzerou)." "2. klik pri tvorbe prechodu (označenie cieľového stavu)"
                        , infoRow "Stav premenovaný na: <label>" "Potvrdenie nového mena stavu v modáli"
                        , infoRow "Stav upravený: <label>" "Zmena vlastností stavu (počiatočný / koncový) v modáli"
                        , infoRow "Odstránený stav: <label>" "Klik nástrojom Odstrániť na stav"
                        ]
                  }
                , { title = "Prechody"
                  , rows =
                        [ infoRow "Pridaný prechod: <symbol>" "Potvrdenie jedného symbolu prechodu"
                        , infoRow "Pridané N prechody." "Potvrdenie viacerých symbolov naraz (napr. a b)"
                        , infoRow "Pridaný ε-prechod." "Prázdny vstup = ε-prechod (nie je slučka)"
                        , infoRow "Upravte symbol prechodu." "Pravý klik na prechod — otvorenie editácie symbolu"
                        , infoRow "Odstránený prechod: <symbol>" "Klik nástrojom Odstrániť na symbol prechodu"
                        , infoRow "Odstránené všetky prechody." "Vymazanie všetkých prechodov medzi dvoma stavmi"
                        , infoRow "Všetky prechody už existujú." "Všetky zadané symboly sú duplicitné (nie je chyba, len upozornenie)"
                        ]
                  }
                , { title = "Nástroje a ovládanie"
                  , rows =
                        [ infoRow "Nástroj: Stavať — ..." "Prepnutie na nástroj Stavať (Shift+B alebo klik na tlačidlo)"
                        , infoRow "Nástroj: Odstrániť — ..." "Prepnutie na nástroj Odstrániť (Shift+D alebo klik na tlačidlo)"
                        , infoRow "Akcia zrušená." "Stlačenie klávesy Escape (zatvorenie modálov, zrušenie výberu)"
                        , infoRow "Automat bol resetovaný." "Klik na tlačidlo Reset"
                        ]
                  }
                , { title = "Simulátor"
                  , rows =
                        [ infoRow "Simulátor pripravený. Zadajte vstupné slovo." "Otvorenie stránky simulátora"
                        , infoRow "Vstup nastavený: <slovo>" "Potvrdenie vstupného slova"
                        , infoRow "Prechod cez '<symbol>' do stavu <stav>" "DFA krok vpred — úspešný prechod"
                        , infoRow "Koniec vstupu." "DFA krok vpred — vstupný reťazec bol plne prečítaný"
                        , infoRow "Krok späť." "Klik na tlačidlo Krok späť (DFA aj NFA)"
                        , infoRow "Krok vpred (NFA)." "NFA krok vpred"
                        , infoRow "Efektívny beh: Slovo je akceptované / nie je akceptované" "Klik na Okamžitý beh v efektívnom režime"
                        ]
                  }
                , { title = "Konverzia NFA -> DFA"
                  , rows =
                        [ infoRow "Konverzia NFA -> DFA spustená." "Otvorenie stránky konverzie"
                        , infoRow "Konverzia dokončená." "Skok na posledný krok konverzie"
                        , infoRow "Automat nahradený konvertovaným DFA." "Klik na tlačidlo Nahradiť automat"
                        , infoRow "DFA uložený: <meno>" "Klik na Uložiť DFA s menom"
                        ]
                  }
                ]
            }

        English ->
            { intro = "A list of informational messages shown in the console when actions are completed successfully. They confirm every change to the automaton and help you track what happened."
            , sections =
                [ { title = "Welcome and loading"
                  , rows =
                        [ infoRow "Welcome to the DFA/NFA simulator. Double-click the canvas to add a state." "Application opened without a saved automaton in the URL"
                        , infoRow "Automaton loaded from URL." "Page opened with #a=... in the address (shared link)"
                        , infoRow "Automaton imported from file." "JSON file imported successfully"
                        , infoRow "Automaton loaded: <name>" "Named automaton loaded from browser local storage"
                        ]
                  }
                , { title = "Saving and sharing"
                  , rows =
                        [ infoRow "URL copied to clipboard." "Share via URL button clicked"
                        , infoRow "Automaton definition copied to clipboard." "Copy definition button clicked in the definition panel"
                        , infoRow "Automaton saved: <name>" "Automaton saved to local storage successfully"
                        ]
                  }
                , { title = "States"
                  , rows =
                        [ infoRow "Added state: q0" "Double-click on empty canvas (default name assigned)"
                        , infoRow "Dead state added. The automaton is now a complete DFA." "Add dead state button clicked"
                        , infoRow "Select a target state for the transition." "1st click while building a transition (source state selected)"
                        , infoRow "Enter transition symbol(s), separated by spaces." "2nd click while building a transition (target state selected)"
                        , infoRow "State renamed to: <label>" "New state name confirmed in the modal"
                        , infoRow "State updated: <label>" "State properties changed (start / end) in the modal"
                        , infoRow "Deleted state: <label>" "Delete tool clicked on a state"
                        ]
                  }
                , { title = "Transitions"
                  , rows =
                        [ infoRow "Added transition: <symbol>" "Single transition symbol confirmed"
                        , infoRow "Added N transitions." "Multiple symbols confirmed at once (e.g. a b)"
                        , infoRow "Added ε-transition." "Empty input = epsilon transition (not a self-loop)"
                        , infoRow "Edit the transition symbol." "Right-click on a transition — open symbol editor"
                        , infoRow "Deleted transition: <symbol>" "Delete tool clicked on a transition symbol"
                        , infoRow "All transitions deleted." "All transitions between two states removed"
                        , infoRow "All transitions already exist." "All entered symbols are duplicates (not an error, just a notice)"
                        ]
                  }
                , { title = "Tools and controls"
                  , rows =
                        [ infoRow "Tool: Build — ..." "Switched to Build tool (Shift+B or button click)"
                        , infoRow "Tool: Delete — ..." "Switched to Delete tool (Shift+D or button click)"
                        , infoRow "Action canceled." "Escape key pressed (closes modals, cancels selection)"
                        , infoRow "Automaton was reset." "Reset button clicked"
                        ]
                  }
                , { title = "Simulator"
                  , rows =
                        [ infoRow "Simulator ready. Enter an input word." "Simulator page opened"
                        , infoRow "Input set: <word>" "Input word confirmed"
                        , infoRow "Transition through '<symbol>' to state <state>" "DFA step forward — successful transition"
                        , infoRow "End of input." "DFA step forward — full input has been consumed"
                        , infoRow "Step back." "Step back button clicked (DFA and NFA)"
                        , infoRow "Step forward (NFA)." "NFA step forward"
                        , infoRow "Efficient run: The word is accepted / not accepted" "Instant run clicked in efficient mode"
                        ]
                  }
                , { title = "NFA -> DFA Conversion"
                  , rows =
                        [ infoRow "NFA -> DFA conversion started." "Conversion page opened"
                        , infoRow "Conversion finished." "Jump to the last conversion step"
                        , infoRow "Automaton replaced with the converted DFA." "Replace automaton button clicked"
                        , infoRow "DFA saved: <name>" "Save DFA clicked with a name"
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
                , row "Autor" "Jakub Mitický"
                , row "Vedúci práce" "Ing. Ivan Kapustík"
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
                , row "Author" "Jakub Mitický"
                , row "Supervisor" "Ing. Ivan Kapustík"
                ]
            , contactPrefix = "Feedback, questions, or bug reports - write to: "
            }
