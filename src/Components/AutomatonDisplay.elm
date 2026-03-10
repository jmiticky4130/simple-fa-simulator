module Components.AutomatonDisplay exposing (view)

import Html exposing (Html, div, h3, p, text, span)
import Html.Attributes exposing (style)
import Set
import Shared exposing (State, Transition)
import Utils.AutomatonHelpers exposing (getStateLabel)
import Utils.Theme as Theme


type alias Config =
    { states : List State
    , transitions : List Transition
    , theme : Theme.Theme
    }


view : Config -> Html msg
view config =
    let
        isNFA =
            let
                check ts seen =
                    case ts of
                        [] -> False
                        t :: rest ->
                            if Set.member (t.from, t.symbol) seen then
                                True
                            else
                                check rest (Set.insert (t.from, t.symbol) seen)
            in
            check config.transitions Set.empty

        typeLabel =
            if isNFA then
                "NFA"
            else
                "DFA"

        typeColor =
            if isNFA then
                config.theme.automatonTypeNfa
            else
                config.theme.automatonTypeDfa
    in
    div
        [ style "padding" "15px"
        , style "height" "100%"
        , style "overflow-y" "auto"
        , style "box-sizing" "border-box"
        , style "color" config.theme.textPrimary
        ]
        [ h3
            [ style "margin-top" "0"
            , style "color" config.theme.automatonDefTitle
            , style "border-bottom" ("2px solid " ++ config.theme.automatonDefBorder)
            , style "padding-bottom" "10px"
            ]
            [ text "Definícia automatu: "
            , span [ style "color" typeColor ] [ text typeLabel ]
            ]
        , viewDefinition config
        ]


viewDefinition : Config -> Html msg
viewDefinition config =
    div
        [ style "font-family" "monospace"
        , style "font-size" "14px"
        , style "color" config.theme.textPrimary
        ]
        [ viewSetQ config.states
        , viewSetSigma config.transitions
        , viewStartQ0 config.states
        , viewSetF config.states
        , viewDelta config.states config.transitions
        ]


viewSetQ : List State -> Html msg
viewSetQ states =
    let
        content =
            if List.isEmpty states then
                "{empty}"
            else
                "{ " ++ String.join ", " (List.map .label states) ++ " }"
    in
    p [ style "margin" "10px 0" ] [ text ("Q = " ++ content) ]


viewSetSigma : List Transition -> Html msg
viewSetSigma transitions =
    let
        alphabet =
            List.map .symbol transitions
                |> Set.fromList
                |> Set.toList
                |> List.sort

        content =
            if List.isEmpty alphabet then
                "{empty}"
            else
                "{ " ++ String.join ", " alphabet ++ " }"
    in
    p [ style "margin" "10px 0" ] [ text ("\u{03A3} = " ++ content) ]


viewStartQ0 : List State -> Html msg
viewStartQ0 states =
    let
        startState =
            List.filter .isStart states
                |> List.head
                |> Maybe.map .label

        content =
            case startState of
                Just lbl ->
                    lbl
                Nothing ->
                    "nebol vybraty pociatocny stav"
    in
    p [ style "margin" "10px 0" ] [ text ("q0 = " ++ content) ]


viewSetF : List State -> Html msg
viewSetF states =
    let
        endStates =
            List.filter .isEnd states
                |> List.map .label

        content =
            if List.isEmpty endStates then
                "{empty}"
            else
                "{ " ++ String.join ", " endStates ++ " }"
    in
    p [ style "margin" "10px 0" ] [ text ("F = " ++ content) ]


viewDelta : List State -> List Transition -> Html msg
viewDelta states transitions =
    let
        sortedTransitions =
            List.sortBy (\t -> (t.from, t.to, t.symbol)) transitions
    in
    div []
        (List.map (viewDeltaRow states) sortedTransitions)


viewDeltaRow : List State -> Transition -> Html msg
viewDeltaRow states transition =
    let
        fromLabel = getStateLabel transition.from states
        toLabel = getStateLabel transition.to states
    in
    p [ style "margin" "10px 0" ]
        [ text ("\u{03B4}(" ++ fromLabel ++ ", " ++ transition.symbol ++ ") = " ++ toLabel) ]
