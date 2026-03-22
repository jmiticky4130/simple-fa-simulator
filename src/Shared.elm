module Shared exposing (..)


type AutomatonType
    = CompleteDFA
    | IncompleteDFA
    | NFA

type alias State =
    { id : Int
    , x : Float
    , y : Float
    , label : String
    , isStart : Bool
    , isEnd : Bool
    , isCompact : Bool
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


type alias NfaInstance =
    { id : Int
    , currentStateId : Maybe Int
    , remainingInput : String
    , verdict : Maybe { text : String, isAccepted : Bool }
    , parentId : Maybe Int
    , symbolTaken : Maybe String
    }


type alias NfaTreeNode =
    { id : Int
    , stateId : Maybe Int
    , parentId : Maybe Int
    , symbol : Maybe String
    }
