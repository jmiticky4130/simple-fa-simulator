# DFA/NFA Simulator

Simulátor deterministických a nedeterministických konečných automatov vytvorený v Elm.

## Štruktúra projektu

```
elm_proj/
├── src/
│   ├── Main.elm                      # Hlavný modul s logikou aplikácie
│   ├── View.elm                      # Hlavný view modul
│   ├── Components/                    # Komponenty UI
│   │   ├── Toolbar.elm               # Horná lišta s nástrojmi
│   │   ├── Canvas.elm                # Plátno na kreslenie automatu
│   │   ├── Console.elm               # Konzola pre správy
│   │   └── AutomatonDisplay.elm      # Formálny zápis automatu
│   ├── Views/                         # Ďalšie views (pre budúce rozšírenie)
│   └── Utils/                         # Pomocné funkcie
│       └── AutomatonHelpers.elm       # Funkcie pre prácu s automatmi
├── elm.json                           # Elm dependencies
└── index.html                         # HTML súbor pre spustenie aplikácie
```

## Komponenty

### 1. Toolbar (Horná lišta)
Obsahuje nástroje na prácu s automatom:
- **Výber** - Výber a posúvanie stavov
- **Pridať stav** - Kliknutím na plátno pridáte nový stav
- **Pridať prechod** - Kliknite na dva stavy pre vytvorenie prechodu
- **Odstrániť** - Odstránenie stavov a prechodov
- **Upraviť** - Úprava popisov stavov a symbolov prechodov
- **Počiatočný stav** - Nastavenie počiatočného stavu
- **Koncový stav** - Nastavenie koncového stavu (môže byť viacero)

### 2. Canvas (Plátno)
Interaktívne plátno na kreslenie automatu:
- **Stavy** - Zobrazené ako kruhy
- **Koncové stavy** - Dvojitý kruh (hrubší okraj)
- **Počiatočný stav** - Šípka smerujúca do stavu
- **Prechody** - Čiary so šípkami medzi stavmi
- **Symboly** - Popisky na prechodoch

### 3. Console (Konzola)
Spodný panel zobrazujúci správy o akciách:
- Informácie o pridaných/odstránených stavoch
- Informácie o pridaných/odstránených prechodoch
- Upozornenia a chyby

### 4. Automaton Display (Zápis automatu)
Pravý panel s formálnym zápisom automatu:
- **Q** - Množina stavov
- **q₀** - Počiatočný stav
- **F** - Množina koncových stavov
- **δ** - Prechodová funkcia (tabuľka prechodov)

## Použitie

### Spustenie aplikácie

1. Kompilácia:
```bash
elm make src/Main.elm --output=elm.js
```

2. Otvorte `index.html` v prehliadači

### Ako používať

1. **Pridanie stavov**:
   - Kliknite na tlačidlo "Pridať stav"
   - Kliknite na plátno kde chcete stav vytvoriť
   - Stavy sa automaticky označujú ako q0, q1, q2, ...

2. **Vytvorenie prechodov**:
   - Kliknite na tlačidlo "Pridať prechod"
   - Kliknite na zdrojový stav
   - Kliknite na cieľový stav
   - Prechod sa vytvorí s predvoleným symbolom "a"

3. **Nastavenie počiatočného stavu**:
   - Kliknite na tlačidlo "Počiatočný stav"
   - Kliknite na stav, ktorý má byť počiatočný
   - Zobrazí sa šípka smerujúca do stavu

4. **Nastavenie koncových stavov**:
   - Kliknite na tlačidlo "Koncový stav"
   - Kliknite na stav, ktorý má byť koncový
   - Stav získa dvojitý okraj
   - Môžete nastaviť viacero koncových stavov

5. **Odstránenie**:
   - Kliknite na tlačidlo "Odstrániť"
   - Kliknite na stav alebo prechod, ktorý chcete odstrániť

## Technológie

- **Elm 0.19.1** - Funkcionálny jazyk pre frontend
- **HTML/CSS** - Štýlovanie a rozloženie
- **Pure Elm** - Žiadne JavaScript závislosti

## Knižnice

- `elm/browser` - Browser API
- `elm/core` - Základné funkcie Elm
- `elm/html` - HTML rendering
- `elm/json` - JSON spracovanie
- `MacCASOutreach/graphicsvg` - Grafická knižnica
- `rundis/elm-bootstrap` - Bootstrap komponenty
- `ianmackenzie/elm-units` - Jednotky merania

## Budúce rozšírenia

- Simulácia behu automatu na vstupnom reťazci
- Export/import automatu (JSON)
- Konverzia NFA -> DFA
- Minimalizácia DFA
- Testovanie ekvivalencie automatov
- Regulárne výrazy -> NFA
- Úprava symbolov na prechodoch
- Úprava názvov stavov
- Drag & drop pre stavy

## Licencia

Tento projekt bol vytvorený pre akademické účely.
