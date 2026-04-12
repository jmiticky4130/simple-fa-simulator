# DFA/NFA Simulator

Interaktívny editor a simulátor konečných automatov (DFA aj NFA) napísaný v Elm 0.19.1.

Aplikácia je určená pre výučbu a experimentovanie: kreslenie automatov, kroková simulácia, NFA strom vetvení, konverzia NFA -> DFA, import/export a zdieľanie cez URL.

## Prehľad funkcií

- Vizualny editor stavov a prechodov s undo/redo.
- Simulácia DFA aj NFA (krok vpred/vzad, auto-run, nastaviteľná rýchlosť).
- Podpora epsilon prechodov (`ε`).
- NFA strom rozhodnutí + panel inštancií.
- Režim `Zlúčiť stavy` na obmedzenie explózie počtu inštancií.
- Efektívny NFA režim pre veľké vstupy (bez stromu, s okamžitým výsledkom).
- Konverzia NFA -> DFA po krokoch.
- Ukladanie, načítanie, export a URL share.
- SK/EN prepínanie jazyka a light/dark režim.

## Rýchly štart

### Požiadavky

- [Elm 0.19.1](https://elm-lang.org/)

### Spustenie lokálne

1. Naklonujte projekt:

```bash
git clone https://github.com/jmiticky4130/simple-fa-simulator.git
cd simple-fa-simulator
```

2. Skompilujte Elm aplikáciu:

```bash
elm make src/Main.elm --output=elm.js
```

3. Spustite Elm Reactor:

```bash
elm reactor
```

4. V prehliadači otvorte `index.html` cez Reactor UI.

## Ovládanie editora

### Klávesové skratky

| Akcia | Skratka |
|---|---|
| Undo | Ctrl+Z |
| Redo | Ctrl+Y |
| Build tool | Shift+B |
| Delete tool | Shift+D |
| Zrušiť akciu/výber | Escape |

### Build tool (najčastejšie akcie)

| Cieľ | Akcia |
|---|---|
| Pridať stav | Dvojklik na prázdne plátno |
| Upraviť stav (názov, počiatočný, koncový) | Pravý klik na stav |
| Vytvoriť prechod | Klik na zdrojový stav, potom klik na cieľový |
| Upraviť symbol prechodu | Pravý klik na prechod alebo jeho popis |
| Self-loop | Klik na stav a potom znovu na ten istý stav |
| Presun stavu | Ťahanie stavu |
| Pan plátna | Ťahanie prázdnej plochy |
| Zoom | Koliesko myši alebo tlačidlá +/- |

Poznámky:

- Prázdny symbol vytvorí `ε` prechod.
- Viac symbolov zadávajte oddelené medzerou (napr. `a b ε`).

## Simulácia

1. Prepnite do simulátora (vyžaduje aspoň 1 počiatočný a 1 koncový stav).
2. Zadajte vstupné slovo.
3. Spustite krokovanie alebo auto-run.
4. Sledujte aktuálny stav, zvyšný vstup a verdikt.

NFA režim navyše ponúka:

- strom vetvenia,
- panel inštancií,
- prepínač `Zlúčiť stavy`,
- efektívny režim pre rozsiahle simulácie.

## Konverzia NFA -> DFA

Ak je automat NFA, v editore je dostupná konverzná stránka s krokmi subset konštrukcie a možnosťou uložiť výsledný DFA späť do editora.

## Štruktúra projektu (src)

```text
src/
├── Main.elm
├── Shared.elm
├── Components/
│   ├── AutomatonDisplay.elm
│   ├── Canvas.elm
│   ├── Console.elm
│   ├── ConversionCanvas.elm
│   ├── NfaInstancePanel.elm
│   ├── NfaTreeView.elm
│   ├── SimulateToolbar.elm
│   ├── SimulationStatus.elm
│   └── Toolbar.elm
├── Pages/
│   ├── Conversion.elm
│   ├── Editor.elm
│   └── Simulator.elm
└── Utils/
	├── AutomatonCodec.elm
	├── AutomatonHelpers.elm
	├── ConversionHelpers.elm
	├── ExampleAutomata.elm
	├── Theme.elm
	└── Translations.elm
```