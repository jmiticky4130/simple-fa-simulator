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
    )

import Shared exposing (State, Transition)


{-| Check if the automaton is a DFA (Deterministic Finite Automaton)
    A DFA must have deterministic transitions (no two transitions from the same state with the same symbol).
-}
isDFA : List State -> List Transition -> Bool
isDFA states transitions =
    let
        -- Check for duplicate (from, symbol) pairs where 'to' is different
        hasNonDeterminism =
            List.any
                (\t1 ->
                    List.any
                        (\t2 ->
                            t1.from == t2.from && t1.symbol == t2.symbol && t1.to /= t2.to
                        )
                        transitions
                )
                transitions
    in
    not hasNonDeterminism


{-| Get a state by its ID
-}
getStateById : Int -> List State -> Maybe State
getStateById id states =
    List.filter (\s -> s.id == id) states
        |> List.head



{-| Get the label of a state by its ID
-}
getStateLabel : Int -> List State -> String
getStateLabel id states =
    getStateById id states
        |> Maybe.map .label
        |> Maybe.withDefault "?"


{-| Check if a transition already exists
-}
transitionExists : Int -> Int -> String -> List Transition -> Bool
transitionExists from to symbol transitions =
    List.any (\t -> t.from == from && t.to == to && t.symbol == symbol) transitions


{-| Update the position of a state
-}
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


{-| Update the label of a state
-}
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


{-| Set a state as the start state (and unset others)
-}
setStartState : Int -> List State -> List State
setStartState stateId states =
    List.map
        (\state ->
            { state | isStart = state.id == stateId }
        )
        states


{-| Toggle whether a state is an end state
-}
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


{-| Update the symbol of a transition
-}
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
