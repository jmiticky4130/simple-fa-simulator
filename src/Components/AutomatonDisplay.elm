module Components.AutomatonDisplay exposing (view, TransitionDisplayMode(..))

import Html exposing (Html, div, h3, h4, p, text, table, thead, tbody, tr, th, td, button, span)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Set
import Shared exposing (State, Transition)
import Utils.AutomatonHelpers exposing (getStateLabel)


type TransitionDisplayMode
    = Table
    | Formal


type alias Config msg =
    { states : List State
    , transitions : List Transition
    , displayMode : TransitionDisplayMode
    , onModeChange : TransitionDisplayMode -> msg
    }


view : Config msg -> Html msg
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
                "#e67e22"
            else
                "#3498db"
    in
    div
        [ style "background-color" "#f8f9fa"
        , style "padding" "15px"
        , style "border-left" "2px solid #34495e"
        , style "height" "100%"
        , style "overflow-y" "auto"
        , style "width" "300px"
        ]
        [ h3
            [ style "margin-top" "0"
            , style "color" "#2c3e50"
            , style "border-bottom" "2px solid #3498db"
            , style "padding-bottom" "10px"
            ]
            [ text "Definícia automatu: "
            , span [ style "color" typeColor ] [ text typeLabel ]
            ]
        , viewDefinition config
        , viewTransitionControls config
        , case config.displayMode of
            Table ->
                viewTransitions config.states config.transitions
            
            Formal ->
                viewFormalTransitions config.states config.transitions
        ]


viewTransitionControls : Config msg -> Html msg
viewTransitionControls config =
    div
        [ style "display" "flex"
        , style "gap" "10px"
        , style "margin-bottom" "10px"
        ]
        [ viewModeButton "Prechody" Table config
        , viewModeButton "Formálny zápis" Formal config
        ]


viewModeButton : String -> TransitionDisplayMode -> Config msg -> Html msg
viewModeButton label mode config =
    let
        isActive = config.displayMode == mode
        bgColor = if isActive then "#3498db" else "#ecf0f1"
        textColor = if isActive then "white" else "#2c3e50"
    in
    button
        [ onClick (config.onModeChange mode)
        , style "padding" "5px 10px"
        , style "border" "none"
        , style "border-radius" "4px"
        , style "background-color" bgColor
        , style "color" textColor
        , style "cursor" "pointer"
        , style "font-size" "12px"
        , style "font-weight" "bold"
        ]
        [ text label ]


viewFormalTransitions : List State -> List Transition -> Html msg
viewFormalTransitions states transitions =
    div []
        [ if List.isEmpty transitions then
            p
                [ style "color" "#95a5a6"
                , style "font-style" "italic"
                ]
                [ text "Žiadne prechody" ]

          else
            div
                [ style "font-family" "monospace"
                , style "background-color" "white"
                , style "padding" "10px"
                , style "border" "1px solid #ddd"
                , style "border-radius" "4px"
                ]
                (List.map (viewFormalTransitionRow states) transitions)
        ]


viewFormalTransitionRow : List State -> Transition -> Html msg
viewFormalTransitionRow states transition =
    let
        fromLabel = getStateLabel transition.from states
        toLabel = getStateLabel transition.to states
    in
    p
        [ style "margin" "5px 0" ]
        [ text ("δ(" ++ fromLabel ++ ", " ++ transition.symbol ++ ") = " ++ toLabel) ]


viewDefinition : Config msg -> Html msg
viewDefinition config =
    div
        [ style "margin-bottom" "20px"
        , style "font-family" "monospace"
        , style "font-size" "14px"
        ]
        [ viewSetQ config.states
        , viewSetSigma config.transitions
        , viewStartQ0 config.states
        , viewSetF config.states
        ]


viewSetQ : List State -> Html msg
viewSetQ states =
    let
        content =
            if List.isEmpty states then
                "{∅}"
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
                "{∅}"
            else
                "{ " ++ String.join ", " alphabet ++ " }"
    in
    p [ style "margin" "10px 0" ] [ text ("Σ = " ++ content) ]


viewStartQ0 : List State -> Html msg
viewStartQ0 states =
    let
        startState =
            List.filter .isStart states
                |> List.head
                |> Maybe.map .label
        
        content =
            case startState of
                Just label ->
                    label
                Nothing ->
                    "nebol vybraty pociatocny stav"
    in
    p [ style "margin" "10px 0" ] [ text ("q₀ = " ++ content) ]


viewSetF : List State -> Html msg
viewSetF states =
    let
        endStates =
            List.filter .isEnd states
                |> List.map .label
        
        content =
            if List.isEmpty endStates then
                "{∅}"
            else
                "{ " ++ String.join ", " endStates ++ " }"
    in
    p [ style "margin" "10px 0" ] [ text ("F = " ++ content) ]


viewTransitions : List State -> List Transition -> Html msg
viewTransitions states transitions =
    div []
        [ if List.isEmpty transitions then
            p
                [ style "color" "#95a5a6"
                , style "font-style" "italic"
                ]
                [ text "Žiadne prechody" ]

          else
            table
                [ style "width" "100%"
                , style "border-collapse" "collapse"
                , style "background-color" "white"
                ]
                [ thead []
                    [ tr []
                        [ th
                            [ style "border" "1px solid #ddd"
                            , style "padding" "8px"
                            , style "background-color" "#3498db"
                            , style "color" "white"
                            , style "text-align" "left"
                            ]
                            [ text "Z" ]
                        , th
                            [ style "border" "1px solid #ddd"
                            , style "padding" "8px"
                            , style "background-color" "#3498db"
                            , style "color" "white"
                            , style "text-align" "left"
                            ]
                            [ text "Symbol" ]
                        , th
                            [ style "border" "1px solid #ddd"
                            , style "padding" "8px"
                            , style "background-color" "#3498db"
                            , style "color" "white"
                            , style "text-align" "left"
                            ]
                            [ text "Do" ]
                        ]
                    ]
                , tbody []
                    (List.map (viewTransitionRow states) transitions)
                ]
        ]


viewTransitionRow : List State -> Transition -> Html msg
viewTransitionRow states transition =
    let
        fromLabel =
            getStateLabel transition.from states

        toLabel =
            getStateLabel transition.to states
    in
    tr []
        [ td
            [ style "border" "1px solid #ddd"
            , style "padding" "8px"
            ]
            [ text fromLabel ]
        , td
            [ style "border" "1px solid #ddd"
            , style "padding" "8px"
            , style "font-weight" "bold"
            , style "color" "#e74c3c"
            ]
            [ text transition.symbol ]
        , td
            [ style "border" "1px solid #ddd"
            , style "padding" "8px"
            ]
            [ text toLabel ]
        ]



