module Utils.AutomatonCodec exposing
    ( encode, decoder
    , encodeCompact, decodeCompact
    )

import Bitwise
import Dict
import Json.Encode as E
import Json.Decode as D exposing (Decoder)
import Shared exposing (AutomatonState, State, Transition)


encode : AutomatonState -> String
encode a =
    E.encode 0 (encodeValue a)


encodeValue : AutomatonState -> E.Value
encodeValue a =
    E.object
        [ ( "states", E.list encodeState a.states )
        , ( "transitions", E.list encodeTransition a.transitions )
        , ( "nextStateId", E.int a.nextStateId )
        ]


encodeState : State -> E.Value
encodeState s =
    E.object
        [ ( "id", E.int s.id )
        , ( "x", E.float s.x )
        , ( "y", E.float s.y )
        , ( "label", E.string s.label )
        , ( "isStart", E.bool s.isStart )
        , ( "isEnd", E.bool s.isEnd )
        , ( "isCompact", E.bool s.isCompact )
        , ( "startAngle", E.float s.startAngle )
        ]


encodeTransition : Transition -> E.Value
encodeTransition t =
    E.object
        [ ( "from", E.int t.from )
        , ( "to", E.int t.to )
        , ( "symbol", E.string t.symbol )
        , ( "bend", E.float t.bend )
        ]


decoder : Decoder AutomatonState
decoder =
    D.map3 AutomatonState
        (D.field "states" (D.list stateDecoder))
        (D.field "transitions" (D.list transitionDecoder))
        (D.field "nextStateId" D.int)


stateDecoder : Decoder State
stateDecoder =
    D.map8 State
        (D.field "id" D.int)
        (D.field "x" D.float)
        (D.field "y" D.float)
        (D.field "label" D.string)
        (D.field "isStart" D.bool)
        (D.field "isEnd" D.bool)
        (D.oneOf [ D.field "isCompact" D.bool, D.succeed False ])
        (D.oneOf [ D.field "startAngle" D.float, D.succeed pi ])


transitionDecoder : Decoder Transition
transitionDecoder =
    D.map4 Transition
        (D.field "from" D.int)
        (D.field "to" D.int)
        (D.field "symbol" D.string)
        (D.oneOf [ D.field "bend" D.float, D.succeed 0 ])



-- COMPACT URL FORMAT
--
-- Grammar:
--   <states>|<transitions>
--   state := x,y,flags,label              joined by ;
--   trans := from-to:symbol               joined by ;
--   flags := decimal int, bitmask: 1=isStart, 2=isEnd, 4=isCompact
--   from/to/x/y are base36 integers; ids are list-position (0..n-1)
--
-- Reserved characters in labels/symbols (`;`, `|`, `,`, `:`, `-`, `%`)
-- are percent-escaped so split is unambiguous. Everything else is passed
-- through; the JS layer additionally lz-string-compresses the result.


encodeCompact : AutomatonState -> String
encodeCompact a =
    let
        idIndex : Dict.Dict Int Int
        idIndex =
            a.states
                |> List.indexedMap (\i s -> ( s.id, i ))
                |> Dict.fromList

        statesPart =
            a.states
                |> List.map encodeStateCompact
                |> String.join ";"

        transitionsPart =
            a.transitions
                |> List.filterMap (encodeTransitionCompact idIndex)
                |> String.join ";"
    in
    statesPart ++ "|" ++ transitionsPart


encodeStateCompact : State -> String
encodeStateCompact s =
    let
        flags =
            (if s.isStart then 1 else 0)
                + (if s.isEnd then 2 else 0)
                + (if s.isCompact then 4 else 0)
    in
    String.join ","
        [ intToBase36 (round s.x)
        , intToBase36 (round s.y)
        , String.fromInt flags
        , escapeField s.label
        ]


encodeTransitionCompact : Dict.Dict Int Int -> Transition -> Maybe String
encodeTransitionCompact idx t =
    Maybe.map2
        (\f to -> intToBase36 f ++ "-" ++ intToBase36 to ++ ":" ++ escapeField t.symbol)
        (Dict.get t.from idx)
        (Dict.get t.to idx)


decodeCompact : String -> Result String AutomatonState
decodeCompact raw =
    case String.split "|" raw of
        [ statesStr, transStr ] ->
            let
                stateChunks =
                    if String.isEmpty statesStr then [] else String.split ";" statesStr

                transChunks =
                    if String.isEmpty transStr then [] else String.split ";" transStr

                statesResult =
                    stateChunks
                        |> List.indexedMap (\i c -> decodeStateCompact i c)
                        |> sequenceResults

                transResult =
                    transChunks
                        |> List.map decodeTransitionCompact
                        |> sequenceResults
            in
            Result.map2
                (\states transitions ->
                    { states = states
                    , transitions = transitions
                    , nextStateId = List.length states
                    }
                )
                statesResult
                transResult

        _ ->
            Err "Compact URL: expected exactly one '|' separator"


decodeStateCompact : Int -> String -> Result String State
decodeStateCompact assignedId chunk =
    case String.split "," chunk of
        [ xStr, yStr, flagsStr, labelEsc ] ->
            Result.map3
                (\x y flags ->
                    { id = assignedId
                    , x = toFloat x
                    , y = toFloat y
                    , label = unescapeField labelEsc
                    , isStart = Bitwise.and flags 1 /= 0
                    , isEnd = Bitwise.and flags 2 /= 0
                    , isCompact = Bitwise.and flags 4 /= 0
                    , startAngle = pi
                    }
                )
                (base36ToInt xStr)
                (base36ToInt yStr)
                (String.toInt flagsStr |> Result.fromMaybe ("Bad flags: " ++ flagsStr))

        _ ->
            Err ("Bad state chunk: " ++ chunk)


decodeTransitionCompact : String -> Result String Transition
decodeTransitionCompact chunk =
    case String.split ":" chunk of
        [ endpoints, symbolEsc ] ->
            case String.split "-" endpoints of
                [ fromStr, toStr ] ->
                    Result.map2
                        (\f to ->
                            { from = f, to = to, symbol = unescapeField symbolEsc, bend = 0 }
                        )
                        (base36ToInt fromStr)
                        (base36ToInt toStr)

                _ ->
                    Err ("Bad transition endpoints: " ++ endpoints)

        _ ->
            Err ("Bad transition chunk: " ++ chunk)


sequenceResults : List (Result String a) -> Result String (List a)
sequenceResults =
    List.foldr (Result.map2 (::)) (Ok [])



-- BASE36


intToBase36 : Int -> String
intToBase36 n =
    if n < 0 then
        "-" ++ intToBase36Pos (negate n)
    else
        intToBase36Pos n


intToBase36Pos : Int -> String
intToBase36Pos n =
    if n == 0 then
        "0"
    else
        let
            digits =
                "0123456789abcdefghijklmnopqrstuvwxyz"

            loop k acc =
                if k == 0 then
                    acc
                else
                    let
                        d = modBy 36 k
                        ch = String.slice d (d + 1) digits
                    in
                    loop (k // 36) (ch ++ acc)
        in
        loop n ""


base36ToInt : String -> Result String Int
base36ToInt s =
    let
        ( negFlag, body ) =
            case String.uncons s of
                Just ( '-', rest ) -> ( True, rest )
                _ -> ( False, s )

        digits =
            "0123456789abcdefghijklmnopqrstuvwxyz"

        digitVal c =
            String.indexes (String.fromChar c) digits |> List.head

        step c acc =
            case acc of
                Err e -> Err e
                Ok n ->
                    case digitVal (Char.toLower c) of
                        Just v -> Ok (n * 36 + v)
                        Nothing -> Err ("Bad base36 digit: " ++ String.fromChar c)
    in
    if String.isEmpty body then
        Err "Empty base36"
    else
        case String.foldl step (Ok 0) body of
            Ok n -> Ok (if negFlag then negate n else n)
            Err e -> Err e



-- FIELD ESCAPE
--
-- Reserved: ; | , : - %      (chosen so split() calls never split inside data)
-- Escape with %XX (two-hex-digit ASCII) for those plus any non-ASCII char that
-- might be touched by encodeURIComponent later — but we DO want ε etc. to pass
-- through; encodeURIComponent on the lz-compressed payload handles them anyway.
-- So here we only escape the structural chars + literal '%'.


escapeField : String -> String
escapeField =
    String.toList
        >> List.map escapeChar
        >> String.concat


escapeChar : Char -> String
escapeChar c =
    case c of
        '%' -> "%25"
        ';' -> "%3b"
        '|' -> "%7c"
        ',' -> "%2c"
        ':' -> "%3a"
        '-' -> "%2d"
        _ -> String.fromChar c


unescapeField : String -> String
unescapeField s =
    unescapeLoop (String.toList s) []


unescapeLoop : List Char -> List Char -> String
unescapeLoop chars acc =
    case chars of
        [] ->
            String.fromList (List.reverse acc)

        '%' :: h1 :: h2 :: rest ->
            case hexPair h1 h2 of
                Just code ->
                    unescapeLoop rest (Char.fromCode code :: acc)

                Nothing ->
                    unescapeLoop (h1 :: h2 :: rest) ('%' :: acc)

        c :: rest ->
            unescapeLoop rest (c :: acc)


hexPair : Char -> Char -> Maybe Int
hexPair a b =
    Maybe.map2 (\x y -> x * 16 + y) (hexDigit a) (hexDigit b)


hexDigit : Char -> Maybe Int
hexDigit c =
    let
        code = Char.toCode (Char.toLower c)
    in
    if code >= Char.toCode '0' && code <= Char.toCode '9' then
        Just (code - Char.toCode '0')
    else if code >= Char.toCode 'a' && code <= Char.toCode 'f' then
        Just (code - Char.toCode 'a' + 10)
    else
        Nothing
