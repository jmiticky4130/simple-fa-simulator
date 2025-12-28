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



isDFA : List State -> List Transition -> Bool
isDFA states transitions =
    let
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
