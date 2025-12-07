# Rýchly štart - DFA/NFA Simulator

## Spustenie aplikácie

### Krok 1: Kompilácia
V termináli v koreňovom priečinku projektu spustite:
```bash
elm make src/Main.elm --output=elm.js
```

### Krok 2: Otvorenie v prehliadači
Otvorte súbor `index.html` vo vašom prehliadači (Firefox, Chrome, Edge, Safari)

## Základné použitie

### Prvé kroky s automatom

1. **Vytvorte stavy**:
   - Kliknite na tlačidlo "Pridať stav" v hornej lište
   - Kliknite na biele plátno na vytvorenie stavu
   - Vytvorte aspoň 2-3 stavy

2. **Nastavte počiatočný stav**:
   - Kliknite na "Počiatočný stav"
   - Kliknite na jeden z vytvorených stavov
   - Zobrazí sa šípka smerujúca do tohto stavu

3. **Vytvorte prechody**:
   - Kliknite na "Pridať prechod"
   - Kliknite na prvý stav (odkiaľ má ísť prechod)
   - Kliknite na druhý stav (kam má ísť prechod)
   - Vytvorí sa prechod so symbolom "a"

4. **Nastavte koncový stav**:
   - Kliknite na "Koncový stav"
   - Kliknite na stav, ktorý má byť akceptujúci
   - Stav získa dvojitý okraj

5. **Kontrola automatu**:
   - Pozrite sa do pravého panelu "Definícia automatu"
   - Uvidíte formálny zápis vášho automatu:
     - Q = množina stavov
     - q₀ = počiatočný stav
     - F = koncové stavy
     - δ = tabuľka prechodov

### Príklad: Vytvorenie jednoduchého automatu

**Cieľ**: Vytvoriť automat, ktorý akceptuje reťazce končiace na "ab"

1. Vytvorte 3 stavy (q0, q1, q2)
2. Nastavte q0 ako počiatočný stav
3. Nastavte q2 ako koncový stav
4. Pridajte prechody:
   - q0 → q0 (symbol: b)
   - q0 → q1 (symbol: a)
   - q1 → q2 (symbol: b)
   - q1 → q1 (symbol: a)
   - q2 → q1 (symbol: a)
   - q2 → q0 (symbol: b)

## Rozloženie obrazovky

```
┌─────────────────────────────────────────────────────┐
│  [Výber] [Pridať stav] [Pridať prechod] ...        │ ← Toolbar
├──────────────────────────────────┬──────────────────┤
│                                  │ Definícia auto-  │
│                                  │ matu:            │
│         Plátno                   │                  │
│      (Canvas)                    │ Q = {q0, q1,...} │ ← Automat Display
│                                  │ q₀ = q0          │
│                                  │ F = {q2}         │
│                                  │                  │
│                                  │ Prechodová f.:   │
│                                  │ [Tabuľka]        │
├──────────────────────────────────┴──────────────────┤
│ > Vítajte v simulátore...                          │ ← Console
│ > Pridaný stav: q0                                 │
└─────────────────────────────────────────────────────┘
```

## Ovládanie

### Nástroje (Toolbar)

| Nástroj | Funkcia | Použitie |
|---------|---------|----------|
| Výber | Výber stavov | Kliknite na stav pre jeho označenie |
| Pridať stav | Vytvorenie nového stavu | Kliknite na plátno |
| Pridať prechod | Vytvorenie prechodu | Kliknite na 2 stavy postupne |
| Odstrániť | Odstránenie prvkov | Kliknite na stav/prechod |
| Upraviť | Úprava prvkov | (Pre budúce rozšírenie) |
| Počiatočný stav | Nastavenie q₀ | Kliknite na stav |
| Koncový stav | Nastavenie koncového stavu | Kliknite na stav (môže byť viac) |

### Vizuálne označenia

- **Normálny stav**: Sivý kruh
- **Vybraný stav**: Modrý kruh
- **Stav v procese pridávania prechodu**: Zlatý kruh
- **Koncový stav**: Dvojitý okraj (hrubší)
- **Počiatočný stav**: Šípka smerujúca do stavu
- **Prechod**: Čierna čiara s modrým symbolom

## Konzola

V spodnej časti obrazovky sa zobrazujú správy:
- ✓ Úspešné akcie (pridanie stavov, prechodov)
- ⚠ Upozornenia
- ✗ Chyby

Posledných 10 správ je vždy viditeľných.

## Často kladené otázky

**Q: Ako zmením symbol na prechode?**
A: Momentálne sa používa predvolený symbol "a". Funkcia úpravy bude pridaná v budúcich verziách.

**Q: Môžem mať viac počiatočných stavov?**
A: Nie, DFA môže mať len jeden počiatočný stav. Pri nastavení nového počiatočného stavu sa predošlý automaticky odstráni.

**Q: Môžem mať viac koncových stavov?**
A: Áno! Kliknutím na "Koncový stav" môžete pridať alebo odobrať koncové stavy.

**Q: Ako vytvorím slučku (prechod do toho istého stavu)?**
A: Pri vytváraní prechodu kliknite dvakrát na ten istý stav.

**Q: Ako presuniem stav?**
A: Funkcia drag & drop bude pridaná v budúcich verziách. Momentálne môžete stav odstrániť a vytvoriť nový na požadovanej pozícii.

## Ďalšie kroky

Po vytvorení základného automatu môžete:
- Experimentovať s rôznymi štruktúrami
- Vytvoriť komplexnejšie automaty
- Sledovať formálny zápis v pravom paneli
- Pripraviť sa na budúce funkcie (simulácia, export, atď.)

## Podpora

Pre hlásenie chýb alebo návrhy na vylepšenie, prosím kontaktujte autora projektu.
