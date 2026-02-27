# DFA/NFA Simulator

Webový editor a simulátor deterministických (DFA) a nedeterministických (NFA) konečných automatov napísaný v jazyku Elm. Aplikácia umožňuje vizuálne vytvárať automaty, upravovať ich a krokovať simuláciu vstupné ho slova.

## Spustenie projektu lokálne

### Požiadavky
- [Elm 0.19.1](https://elm-lang.org/) nainštalovaný na počítači

### Inštalácia a spustenie

1. **Naklonujte repozitár**:
   ```bash
	git clone https://github.com/jmiticky4130/simple-fa-simulator.git
	cd simple-fa-simulator
   ```

2. **Skompilujte projekt**:
   ```bash
   elm make src/Main.elm --output=elm.js
   ```
3. **Spustite aplikáciu**
   ```bash
   elm reactor
   ```

4. **Otvorte aplikáciu**:
   Otvorte súbor `index.html` v Elm reactor UI.

---

## Používateľská príručka

### Nástroje (Toolbar)

| Nástroj | Klávesová skratka | Funkcia |
|---------|-------------------|---------|
| Stavať | Shift+B | Predvolený nástroj – vytváranie stavov a prechodov na plátne |
| Odstrániť | Shift+D | Klik na stav alebo prechod ho vymaže; opätovné kliknutie prepne späť na Stavať |
| Undo / Redo | Ctrl+Z / Ctrl+Y | Vrátenie / zopakovanie zmeny |

### Akcie na plátne (nástroj Stavať)

| Čo chcem urobiť | Ako to dosiahnuť |
|-----------------|-----------------|
| Pridanie stavu | Dvojklik na prázdne plátno (predvolený názov q0, q1, …) |
| Premenovanie stavu | Rýchly dvojklik na stav → upraviť názov v modáli |
| Nastavenie počiatočného stavu | Rýchly dvojklik na stav → zaškrtnúť Počiatočný stav |
| Nastavenie koncového stavu | Rýchly dvojklik na stav → zaškrtnúť Koncový stav |
| Pridanie prechodu | Kliknutie na zdrojový stav, potom kliknutie na cieľový stav |
| Pridanie slučky (self-loop) | Pomalý dvojklik na stav |
| Epsilon prechod | Nechajte vstupné pole prázdne |
| Viac prechodov naraz | Symboly oddeľte čiarkou, napr. a,b |
| Úprava symbolu prechodu | Dvojklik na symbol prechodu |
| Presun stavu | Ťahanie stavu myšou |
| Posúvanie plátna | Ťahanie prázdneho plátna |
| Priblíženie / oddialenie | Koliesko myši alebo ± tlačidlá |
| Zrušenie akcie / výberu | Klik na prázdne plátno alebo Escape |

### Vytvorenie automatu – krok za krokom

1. **Vytvorte stavy**: dvojklikom na prázdne plátno (automatické mená q0, q1, …)

2. **Nastavte počiatočný a koncový stav**: rýchlym dvojklikom na stav otvorte modál → zaškrtnite *Počiatočný stav* alebo *Koncový stav*

3. **Vytvorte prechody**: kliknite na zdrojový stav, potom na cieľový stav → zadajte symbol
   - Viac symbolov naraz: oddeľte čiarkou, napr. `a,b`
   - Epsilon prechod: nechajte pole prázdne alebo zadajte `ε`
   - Slučka (self-loop): kliknite na zdrojový stav, potom znovu na ten istý (pomalý dvojklik)

4. **Skontrolujte formálny zápis**: pravý panel zobrazuje Q, q₀, F, Σ a prechodovú funkciu δ a označenie DFA / NFA

### Simulácia

1. Prepnite do režimu **Simulátor** (tlačidlo v toolbare, aktívne keď má automat počiatočný aj aspoň jeden koncový stav)
2. Zadajte vstupné slovo v pravom paneli
3. Použite tlačidlá na **krokovanie** (vpred / späť) alebo spustite automatický beh
4. Sledujte:
   - Aktuálny stav (zvýraznený na plátne)
   - Zostávajúci vstup
   - Výsledok (akceptované / zamietnuté)
5. V režime **NFA**: ľavý panel zobrazuje všetky paralelné inštancie výpočtu, vpravo je strom rozhodnutí
6. Pre komplexné NFA odporúčame zapnúť **Zlúčiť stavy**: bez zlučovania môže počet inštancií rásť exponenciálne (až k^n, kde k je priemerný počet vetvení a n je dĺžka vstupu); zlučovanie obmedzuje počet aktívnych inštancií na najviac |Q|

### Konzola

Spodná lišta zobrazuje informačné a chybové správy. Konzola je **skrývateľná** – kliknutím na lištu ju zrolujete alebo rozbalíte.

## Architektúra projektu

```
src/
├── Main.elm              # Hlavný modul, prepínanie Editor/Simulator
├── Shared.elm            # Dátové typy (State, Transition, AutomatonState)
├── Components/
│   ├── Toolbar.elm       # Horná lišta s nástrojmi
│   ├── Canvas.elm        # SVG plátno na kreslenie automatu
│   ├── Console.elm       # Konzola so správami
│   ├── AutomatonDisplay.elm  # Formálny zápis automatu
│   ├── SimulateToolbar.elm   # Ovládanie simulácie
│   └── SimulationStatus.elm  # Stav simulácie
├── Pages/
│   ├── Editor.elm        # Stránka editora
│   └── Simulator.elm     # Stránka simulátora
└── Utils/
    └── AutomatonHelpers.elm  # Pomocné funkcie
```

## Technológie a knižnice

- **Elm 0.19.1** – funkcionálny jazyk pre frontend
- **elm/svg** – SVG grafika (stavy, prechody)
- **elm/html** – HTML rendering
- **elm/json** – práca s JSON
- **elm-community/undo-redo** – podpora undo/redo

---

## Často kladené otázky

**Ako zmením symbol na prechode?**
Dvojklikom na symbol prechodu otvoríte vstupné pole predvyplnené aktuálnym symbolom – upravte ho a potvrďte Enterom.

**Môžem mať viac počiatočných stavov?**
Nie, automat má len jeden počiatočný stav. Nastavením nového sa predošlý odznačí.

**Môžem mať viac koncových stavov?**
Áno. Rýchlym dvojklikom na stav otvorte modál a zaškrtnite / odškrtnite *Koncový stav*.

**Ako vytvorím slučku (prechod do toho istého stavu)?**
Kliknite raz na stav (vyberie sa ako zdrojový), potom naňho kliknite znova pomaly – otvorí sa vstupné pole pre symbol slučky.

**Ako presuniem stav?**
V nástroji Stavať stačí ťahať stav myšou.

**Ako skryjem konzolu?**
Kliknite na lištu konzoly v spodnej časti obrazovky.

---