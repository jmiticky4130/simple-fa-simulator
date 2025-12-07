# DFA/NFA Simulator

Webový editor a simulátor deterministických (DFA) a nedeterministických (NFA) konečných automatov napísaný v jazyku Elm. Aplikácia umožňuje vizuálne vytvárať automaty, upravovať ich a krokovať simuláciu vstupného slova.

## Spustenie projektu lokálne

### Požiadavky
- [Elm 0.19.1](https://elm-lang.org/) nainštalovaný na počítači

### Inštalácia a spustenie

1. **Naklonujte repozitár**:
   ```bash
   git clone https://github.com/<username>/elm-automaton-simulator.git
   cd elm-automaton-simulator
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

| Nástroj | Funkcia | Použitie |
|---------|---------|----------|
| Výber | Výber a presun stavov | Kliknite na stav, ťahajte myšou |
| Pridať stav | Vytvorenie nového stavu | Kliknite na plátno |
| Pridať prechod | Vytvorenie prechodu | Kliknite na 2 stavy postupne |
| Odstrániť | Odstránenie prvkov | Kliknite na stav/prechod |
| Počiatočný stav | Nastavenie q₀ | Kliknite na stav |
| Koncový stav | Nastavenie koncového stavu | Kliknite na stav (môže byť viac) |
| Undo/Redo | Vrátenie/opakovanie akcie | Tlačidlá v toolbare |

### Vizuálne označenia

| Prvok | Význam |
|-------|--------|
| Sivý kruh | Normálny stav |
| Zlatý kruh | Stav v procese pridávania prechodu |
| Zelený kruh | Aktívny stav (počas simulácie) |
| Dvojitý kruh | Koncový (akceptujúci) stav |
| Šípka do stavu | Počiatočný stav |
| Čierna čiara s modrým symbolom | Prechod |

### Vytvorenie automatu – krok za krokom

1. **Vytvorte stavy**:
   - Kliknite na „Pridať stav"
   - Klikajte na plátno pre vytvorenie stavov (automatickicé pomenovania: q0, q1, q2, ...)

2. **Nastavte počiatočný stav**:
   - Kliknite na „Počiatočný stav"
   - Kliknite na stav → zobrazí sa šípka

3. **Vytvorte prechody**:
   - Kliknite na „Pridať prechod"
   - Kliknite na zdrojový stav, potom na cieľový stav
   - Pre slučku (self-loop) kliknite dvakrát na ten istý stav
   - Zadajte symbol, alebo symboly oddelené čiarkou.

4. **Nastavte koncové stavy**:
   - Kliknite na „Koncový stav"
   - Kliknite na stav → získa dvojitý kruh

5. **Skontrolujte formálny zápis**:
   - Pravý panel zobrazuje Q, q₀, F a prechodovú tabuľku δ

### Simulácia

1. Prepnite do režimu **Simulátor** (tlačidlo v toolbare)
2. Zadajte vstupné slovo
3. Použite tlačidlá na **krokovanie** simulácie (vpred/späť)
4. Sledujte:
   - Aktuálny stav (zvýraznený zelenou)
   - Zostávajúci vstup
   - Výsledok (akceptované / neakceptované)

### Konzola

V spodnej časti obrazovky sa zobrazujú správy:
- Úspešné akcie (pridanie stavov, prechodov)
- Upozornenia
- Chyby

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
- **rundis/elm-bootstrap** – štýlovanie UI komponentov

---

## Často kladené otázky

**Ako zmením symbol na prechode?**  
Treba najprv vymazať prechod a následne vytvoriť nový s požadovaným symbolom .

**Môžem mať viac počiatočných stavov?**  
Nie, DFA má len jeden počiatočný stav. Pri nastavení nového sa predošlý odstráni - presune sa.

**Môžem mať viac koncových stavov?**  
Áno, kliknutím na „Koncový stav" môžete pridať/odobrať koncové stavy.

**Ako vytvorím slučku (prechod do toho istého stavu)?**  
Pri vytváraní prechodu kliknite dvakrát na ten istý stav.

**Ako presuniem stavy?**  
Vyberte nástroj „Výber" a ťahajte stav myšou (drag & drop).

---