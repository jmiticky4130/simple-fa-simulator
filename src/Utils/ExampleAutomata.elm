module Utils.ExampleAutomata exposing (examples, ExampleDef)

import Shared exposing (AutomatonState)
import Utils.Translations as Translations exposing (Language(..))


type alias ExampleDef =
    { name : String
    , description : String
    , automaton : AutomatonState
    }


examples : Language -> List ExampleDef
examples lang =
    let
        t = Translations.getTranslations lang
    in
    [ example1 t, example2 t, example3 t, example4 t, example5 t, example6 t ]


-- 1: DFA – accepts strings over {a,b} ending with 'a'
example1 : Translations.Translations -> ExampleDef
example1 t =
    { name = t.example1Name
    , description = t.example1Desc
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
example2 : Translations.Translations -> ExampleDef
example2 t =
    { name = t.example2Name
    , description = t.example2Desc
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
example3 : Translations.Translations -> ExampleDef
example3 t =
    { name = t.example3Name
    , description = t.example3Desc
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
example4 : Translations.Translations -> ExampleDef
example4 t =
    { name = t.example4Name
    , description = t.example4Desc
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
example5 : Translations.Translations -> ExampleDef
example5 t =
    { name = t.example5Name
    , description = t.example5Desc
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
example6 : Translations.Translations -> ExampleDef
example6 t =
    { name = t.example6Name
    , description = t.example6Desc
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
