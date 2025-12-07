module Shared exposing (..)

type alias State =
    { id : Int
    , x : Float
    , y : Float
    , label : String
    , isStart : Bool
    , isEnd : Bool
    }


type alias Transition =
    { from : Int
    , to : Int
    , symbol : String
    }


type alias AutomatonState =
    { states : List State
    , transitions : List Transition
    , nextStateId : Int
    }
