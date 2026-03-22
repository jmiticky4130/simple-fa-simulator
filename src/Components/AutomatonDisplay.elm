module Components.AutomatonDisplay exposing (view)

import Html exposing (Html, div, h3, p, text, span, button, img)
import Html.Attributes exposing (style, src)
import Html.Events exposing (onClick)
import Set
import Shared exposing (State, Transition, AutomatonType(..))
import Utils.AutomatonHelpers exposing (getStateLabel, classifyAutomaton)
import Utils.Theme as Theme
import Utils.Translations as Translations exposing (Language)


type alias Config msg =
    { states : List State
    , transitions : List Transition
    , theme : Theme.Theme
    , language : Language
    , onCopyDefinition : msg
    , copySuccess : Bool
    }


view : Config msg -> Html msg
view config =
    let
        t =
            Translations.getTranslations config.language

        autoType =
            classifyAutomaton config.states config.transitions

        typeLabel =
            if autoType == CompleteDFA then
                "DFA"
            else
                "NFA"

        typeColor =
            if autoType == CompleteDFA then
                config.theme.automatonTypeDfa
            else
                config.theme.automatonTypeNfa
    in
    div
        [ style "display" "flex"
        , style "flex-direction" "column"
        , style "height" "100%"
        , style "overflow" "hidden"
        , style "color" config.theme.textPrimary
        ]
        [ -- Sticky header: title + Why NFA
          div
            [ style "flex-shrink" "0"
            , style "padding" "15px 15px 0 15px"
            , style "background-color" config.theme.rightPanelBg
            ]
            [ div
                [ style "display" "flex"
                , style "align-items" "center"
                , style "justify-content" "space-between"
                , style "border-bottom" ("2px solid " ++ config.theme.automatonDefBorder)
                , style "padding-bottom" "10px"
                ]
                [ h3
                    [ style "margin" "0"
                    , style "color" config.theme.automatonDefTitle
                    ]
                    [ text (t.automatonDefinition ++ ": ")
                    , span [ style "color" typeColor ] [ text typeLabel ]
                    ]
                , div [ style "position" "relative" ]
                    [ button
                        [ onClick config.onCopyDefinition
                        , style "background" config.theme.copyBtnBg
                        , style "border" "none"
                        , style "cursor" "pointer"
                        , style "padding" "4px 6px"
                        , style "border-radius" "5px"
                        , style "display" "flex"
                        , style "align-items" "center"
                        , style "justify-content" "center"
                        ]
                        [ img
                            [ src (if config.copySuccess then "icons/copy_success.svg" else "icons/copy_svg.svg")
                            , style "width" "18px"
                            , style "height" "18px"
                            , style "display" "block"
                            ]
                            []
                        ]
                    , if config.copySuccess then
                        div
                            [ style "position" "absolute"
                            , style "top" "calc(100% + 6px)"
                            , style "right" "0"
                            , style "background" "#333"
                            , style "color" "white"
                            , style "padding" "3px 8px"
                            , style "border-radius" "4px"
                            , style "font-size" "11px"
                            , style "white-space" "nowrap"
                            , style "pointer-events" "none"
                            , style "z-index" "10"
                            ]
                            [ text t.copied ]
                      else
                        text ""
                    ]
                ]
            , viewWhyNfaBlock config.theme t autoType config.transitions
            ]
        , -- Scrollable body: formal definition
          div
            [ style "flex" "1"
            , style "overflow-y" "auto"
            , style "padding" "0 15px 15px 15px"
            ]
            [ viewDefinition config ]
        ]


viewWhyNfaBlock : Theme.Theme -> Translations.Translations -> AutomatonType -> List Transition -> Html msg
viewWhyNfaBlock theme t autoType transitions =
    if autoType == CompleteDFA then
        text ""
    else
        let
            hasEpsilon =
                List.any (\tr -> tr.symbol == "\u{03B5}") transitions

            hasNonDet =
                let
                    checkDups tl seen =
                        case tl of
                            [] -> False
                            tr :: rest ->
                                let k = String.fromInt tr.from ++ "|" ++ tr.symbol
                                in
                                if List.member k seen then True
                                else checkDups rest (k :: seen)
                in
                checkDups (List.filter (\tr -> tr.symbol /= "\u{03B5}") transitions) []

            reasons =
                (if hasEpsilon then [ t.simWhyNfaEpsilon ] else [])
                    ++ (if hasNonDet then [ t.simWhyNfaNondet ] else [])
                    ++ (if autoType == IncompleteDFA then [ t.simWhyNfaIncomplete ] else [])
        in
        div
            [ style "padding" "10px 0 6px 0"
            ]
            [ div
                [ style "font-weight" "bold"
                , style "font-size" "14px"
                , style "color" theme.textPrimary
                , style "margin-bottom" "6px"
                ]
                [ text t.simWhyNfaTitle ]
            , div []
                (List.map
                    (\reason ->
                        div
                            [ style "font-size" "13px"
                            , style "color" theme.textMuted
                            , style "padding-left" "10px"
                            , style "margin-bottom" "3px"
                            , style "line-height" "1.4"
                            ]
                            [ text ("\u{2022} " ++ reason) ]
                    )
                    reasons
                )
            ]


viewDefinition : Config msg -> Html msg
viewDefinition config =
    div
        [ style "font-family" "monospace"
        , style "font-size" "14px"
        , style "color" config.theme.textPrimary
        ]
        [ viewSetQ config.states
        , viewSetSigma config.transitions
        , viewStartQ0 config.language config.states
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


viewStartQ0 : Language -> List State -> Html msg
viewStartQ0 language states =
    let
        t =
            Translations.getTranslations language

        startState =
            List.filter .isStart states
                |> List.head
                |> Maybe.map .label

        content =
            case startState of
                Just lbl ->
                    lbl
                Nothing ->
                    t.noStartStateSelected
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
