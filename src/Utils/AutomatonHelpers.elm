module Utils.AutomatonHelpers exposing
    ( getStateById
    , getStateLabel
    , transitionExists
    , updateStatePosition
    , updateStateLabel
    , setStartState
    , toggleEndState
    , updateTransitionSymbol
    , isDFA
    , classifyAutomaton
    , calculateArrowHead
    , epsilonClosure
    )

import Set
import Shared exposing (State, Transition, AutomatonType(..))


calculateArrowHead : Float -> Float -> Float -> Float -> String
calculateArrowHead tipX tipY ux uy =
    let
        px = -uy
        py = ux
        al = 10
        aw = 6
        baseX = tipX - al * ux
        baseY = tipY - al * uy
        leftX = baseX + (aw / 2) * px
        leftY = baseY + (aw / 2) * py
        rightX = baseX - (aw / 2) * px
        rightY = baseY - (aw / 2) * py
    in
    String.join " "
        [ String.fromFloat tipX ++ "," ++ String.fromFloat tipY
        , String.fromFloat leftX ++ "," ++ String.fromFloat leftY
        , String.fromFloat rightX ++ "," ++ String.fromFloat rightY
        ]


isDFA : List State -> List Transition -> Bool
isDFA states transitions =
    let
        hasEpsilon =
            List.any (\t -> t.symbol == "ε") transitions

        key t = String.fromInt t.from ++ "|" ++ t.symbol

        checkDuplicates transList seenKeys =
            case transList of
                [] -> False
                t :: rest ->
                    let
                        k = key t
                    in
                    if List.member k seenKeys then
                        True
                    else
                        checkDuplicates rest (k :: seenKeys)
    in
    not hasEpsilon && not (checkDuplicates transitions [])


classifyAutomaton : List State -> List Transition -> AutomatonType
classifyAutomaton states transitions =
    let
        hasEpsilon =
            List.any (\t -> t.symbol == "\u{03B5}") transitions

        key t = String.fromInt t.from ++ "|" ++ t.symbol

        checkDuplicates transList seenKeys =
            case transList of
                [] -> False
                t :: rest ->
                    let
                        k = key t
                    in
                    if List.member k seenKeys then
                        True
                    else
                        checkDuplicates rest (k :: seenKeys)

        hasDuplicates =
            checkDuplicates transitions []

        alphabet =
            transitions
                |> List.filterMap (\t -> if t.symbol == "\u{03B5}" then Nothing else Just t.symbol)
                |> Set.fromList
                |> Set.toList

        isComplete =
            if List.isEmpty alphabet then
                True
            else
                List.all
                    (\state ->
                        List.all
                            (\sym ->
                                List.any (\t -> t.from == state.id && t.symbol == sym) transitions
                            )
                            alphabet
                    )
                    states
    in
    if hasEpsilon || hasDuplicates then
        NFA
    else if not isComplete then
        IncompleteDFA
    else
        CompleteDFA


epsilonClosure : List Transition -> Int -> List Int
epsilonClosure transitions stateId =
    let
        go toVisit visited =
            case toVisit of
                [] ->
                    visited

                current :: rest ->
                    if List.member current visited then
                        go rest visited

                    else
                        let
                            epsTargets =
                                List.filterMap
                                    (\t ->
                                        if t.from == current && t.symbol == "ε" then
                                            Just t.to

                                        else
                                            Nothing
                                    )
                                    transitions
                        in
                        go (rest ++ epsTargets) (current :: visited)
    in
    go [ stateId ] []


getStateById : Int -> List State -> Maybe State
getStateById id states =
    List.filter (\s -> s.id == id) states
        |> List.head



getStateLabel : Int -> List State -> String
getStateLabel id states =
    getStateById id states
        |> Maybe.map .label
        |> Maybe.withDefault "?"


transitionExists : Int -> Int -> String -> List Transition -> Bool
transitionExists from to symbol transitions =
    List.any (\t -> t.from == from && t.to == to && t.symbol == symbol) transitions


updateStatePosition : Int -> Float -> Float -> List State -> List State
updateStatePosition stateId x y states =
    List.map
        (\state ->
            if state.id == stateId then
                { state | x = x, y = y }
            else
                state
        )
        states


updateStateLabel : Int -> String -> List State -> List State
updateStateLabel stateId newLabel states =
    List.map
        (\state ->
            if state.id == stateId then
                { state | label = newLabel }
            else
                state
        )
        states


setStartState : Int -> List State -> List State
setStartState stateId states =
    List.map
        (\state ->
            { state | isStart = state.id == stateId }
        )
        states


toggleEndState : Int -> List State -> List State
toggleEndState stateId states =
    List.map
        (\state ->
            if state.id == stateId then
                { state | isEnd = not state.isEnd }
            else
                state
        )
        states


updateTransitionSymbol : Int -> Int -> String -> String -> List Transition -> List Transition
updateTransitionSymbol from to oldSymbol newSymbol transitions =
    List.map
        (\transition ->
            if transition.from == from && transition.to == to && transition.symbol == oldSymbol then
                { transition | symbol = newSymbol }
            else
                transition
        )
        transitions
