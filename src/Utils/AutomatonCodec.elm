module Utils.AutomatonCodec exposing (encode, decoder)

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
        ]


encodeTransition : Transition -> E.Value
encodeTransition t =
    E.object
        [ ( "from", E.int t.from )
        , ( "to", E.int t.to )
        , ( "symbol", E.string t.symbol )
        ]


decoder : Decoder AutomatonState
decoder =
    D.map3 AutomatonState
        (D.field "states" (D.list stateDecoder))
        (D.field "transitions" (D.list transitionDecoder))
        (D.field "nextStateId" D.int)


stateDecoder : Decoder State
stateDecoder =
    D.map6 State
        (D.field "id" D.int)
        (D.field "x" D.float)
        (D.field "y" D.float)
        (D.field "label" D.string)
        (D.field "isStart" D.bool)
        (D.field "isEnd" D.bool)


transitionDecoder : Decoder Transition
transitionDecoder =
    D.map3 Transition
        (D.field "from" D.int)
        (D.field "to" D.int)
        (D.field "symbol" D.string)
