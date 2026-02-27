module Utils.ExampleAutomata exposing (examples, ExampleDef)

import Shared exposing (AutomatonState)


type alias ExampleDef =
    { name : String
    , description : String
    , automaton : AutomatonState
    }


examples : List ExampleDef
examples =
    [ example1, example2, example3, example4, example5, example6 ]


-- 1: DFA – accepts strings over {a,b} ending with 'a'
example1 : ExampleDef
example1 =
    { name = "DFA – končí na 'a'"
    , description = "Prijíma reťazce nad {a,b} končiace symbolom 'a'. Príklad: a, ba, aba."
    , automaton =
        { states =
            [ { id = 0, x = 200, y = 280, label = "q0", isStart = True, isEnd = False }
            , { id = 1, x = 520, y = 280, label = "q1", isStart = False, isEnd = True }
            ]
        , transitions =
            [ { from = 0, to = 1, symbol = "a" }
            , { from = 0, to = 0, symbol = "b" }
            , { from = 1, to = 1, symbol = "a" }
            , { from = 1, to = 0, symbol = "b" }
            ]
        , nextStateId = 2
        }
    }


-- 2: DFA – accepts binary strings with even number of '0's
example2 : ExampleDef
example2 =
    { name = "DFA – párny počet núl"
    , description = "Prijíma binárne reťazce s párnym počtom symbolov '0' (vrátane žiadnej nuly). Príklad: ε, 00, 11, 1001."
    , automaton =
        { states =
            [ { id = 0, x = 200, y = 280, label = "even", isStart = True, isEnd = True }
            , { id = 1, x = 520, y = 280, label = "odd", isStart = False, isEnd = False }
            ]
        , transitions =
            [ { from = 0, to = 1, symbol = "0" }
            , { from = 0, to = 0, symbol = "1" }
            , { from = 1, to = 0, symbol = "0" }
            , { from = 1, to = 1, symbol = "1" }
            ]
        , nextStateId = 2
        }
    }


-- 3: NFA – accepts strings over {0,1} ending with "01"
example3 : ExampleDef
example3 =
    { name = "NFA – končí na '01'"
    , description = "Nedeterministický automat prijímajúci reťazce nad {0,1} končiace podreťazcom '01'. Príklad: 01, 101, 0101."
    , automaton =
        { states =
            [ { id = 0, x = 150, y = 280, label = "q0", isStart = True, isEnd = False }
            , { id = 1, x = 370, y = 280, label = "q1", isStart = False, isEnd = False }
            , { id = 2, x = 590, y = 280, label = "q2", isStart = False, isEnd = True }
            ]
        , transitions =
            [ { from = 0, to = 0, symbol = "0" }
            , { from = 0, to = 0, symbol = "1" }
            , { from = 0, to = 1, symbol = "0" }
            , { from = 1, to = 2, symbol = "1" }
            ]
        , nextStateId = 3
        }
    }


-- 4: NFA with ε-transitions – accepts "a" or "ab"
example4 : ExampleDef
example4 =
    { name = "NFA s ε – prijíma 'a' alebo 'ab'"
    , description = "NFA s epsilon prechodom: q1 →ε→ q2 (akceptuje 'a'), q1 →b→ q3 (akceptuje 'ab'). Ukážka ε-prechodov."
    , automaton =
        { states =
            [ { id = 0, x = 150, y = 280, label = "q0", isStart = True, isEnd = False }
            , { id = 1, x = 360, y = 280, label = "q1", isStart = False, isEnd = False }
            , { id = 2, x = 570, y = 170, label = "q2", isStart = False, isEnd = True }
            , { id = 3, x = 570, y = 390, label = "q3", isStart = False, isEnd = True }
            ]
        , transitions =
            [ { from = 0, to = 1, symbol = "a" }
            , { from = 1, to = 2, symbol = "ε" }
            , { from = 1, to = 3, symbol = "b" }
            ]
        , nextStateId = 4
        }
    }


-- 5: NFA – second-to-last symbol is '1' over {0,1}
example5 : ExampleDef
example5 =
    { name = "NFA – predposledný symbol je '1'"
    , description = "Prijíma reťazce nad {0,1} dĺžky ≥ 2, kde predposledný symbol je '1'. Príklad: 10, 11, 010, 110."
    , automaton =
        { states =
            [ { id = 0, x = 150, y = 280, label = "q0", isStart = True, isEnd = False }
            , { id = 1, x = 370, y = 280, label = "q1", isStart = False, isEnd = False }
            , { id = 2, x = 590, y = 280, label = "q2", isStart = False, isEnd = True }
            ]
        , transitions =
            [ { from = 0, to = 0, symbol = "0" }
            , { from = 0, to = 0, symbol = "1" }
            , { from = 0, to = 1, symbol = "1" }
            , { from = 1, to = 2, symbol = "0" }
            , { from = 1, to = 2, symbol = "1" }
            ]
        , nextStateId = 3
        }
    }


-- 6: ε-NFA – accepts a^n b^m for n, m >= 0
example6 : ExampleDef
example6 =
    { name = "ε-NFA – a*b*"
    , description = "Prijíma reťazce tvaru a⁰⁺b⁰⁺: nula alebo viac 'a', za nimi nula alebo viac 'b'."
    , automaton =
        { states =
            [ { id = 0, x = 200, y = 280, label = "q0", isStart = True, isEnd = True }
            , { id = 1, x = 520, y = 280, label = "q1", isStart = False, isEnd = True }
            ]
        , transitions =
            [ { from = 0, to = 0, symbol = "a" }
            , { from = 0, to = 1, symbol = "ε" }
            , { from = 1, to = 1, symbol = "b" }
            ]
        , nextStateId = 2
        }
    }
