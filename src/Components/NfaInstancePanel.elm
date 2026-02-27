module Components.NfaInstancePanel exposing (Config, view)

import Html exposing (Html, button, div, span, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Shared exposing (NfaInstance, State)


type alias Config msg =
    { instances : List NfaInstance
    , selectedId : Maybe Int
    , onSelect : Int -> msg
    , states : List State
    , visibleCount : Int
    , onLoadMore : msg
    }


view : Config msg -> Html msg
view config =
    let
        total =
            List.length config.instances

        visible =
            List.take config.visibleCount config.instances

        hasMore =
            total > config.visibleCount
    in
    div
        [ style "overflow-y" "auto"
        , style "flex" "1"
        , style "padding" "0 2px"
        ]
        (List.indexedMap (\idx inst -> viewInstance config (idx + 1) inst) visible
            ++ (if hasMore then
                    [ div
                        [ style "text-align" "center"
                        , style "padding" "8px 0"
                        ]
                        [ button
                            [ onClick config.onLoadMore
                            , style "padding" "6px 16px"
                            , style "cursor" "pointer"
                            , style "border" "1px solid #aaa"
                            , style "border-radius" "4px"
                            , style "background" "#f5f5f5"
                            , style "font-size" "12px"
                            ]
                            [ text ("Načítať ďalšie (zobrazených " ++ String.fromInt config.visibleCount ++ " z " ++ String.fromInt total ++ ")") ]
                        ]
                    ]

                else
                    []
               )
        )


viewInstance : Config msg -> Int -> NfaInstance -> Html msg
viewInstance config displayIdx instance =
    let
        isSelected =
            config.selectedId == Just instance.id

        stateLabel =
            case instance.currentStateId of
                Just sid ->
                    config.states
                        |> List.filter (\s -> s.id == sid)
                        |> List.head
                        |> Maybe.map .label
                        |> Maybe.withDefault "?"

                Nothing ->
                    "Mŕtva vetva"

        ( statusText, statusBg, borderColor ) =
            case instance.verdict of
                Nothing ->
                    ( "Beží", "#2196F3", if isSelected then "#1565C0" else "#2196F3" )

                Just v ->
                    if v.isAccepted then
                        ( "Akceptované", "#4CAF50", if isSelected then "#2E7D32" else "#4CAF50" )

                    else
                        ( "Zamietnuté", "#F44336", if isSelected then "#B71C1C" else "#F44336" )

        borderWidth =
            if isSelected then
                "3px"

            else
                "2px"
    in
    div
        [ style "border" (borderWidth ++ " solid " ++ borderColor)
        , style "border-radius" "6px"
        , style "padding" "8px"
        , style "margin-bottom" "8px"
        , style "cursor" "pointer"
        , style "background-color" (if isSelected then "#f0f8ff" else "white")
        , onClick (config.onSelect instance.id)
        ]
        [ div
            [ style "display" "flex"
            , style "justify-content" "space-between"
            , style "align-items" "center"
            , style "margin-bottom" "4px"
            ]
            [ span
                [ style "font-weight" "bold"
                , style "font-size" "13px"
                ]
                [ text ("Inštancia #" ++ String.fromInt displayIdx) ]
            , span
                [ style "background-color" statusBg
                , style "color" "white"
                , style "padding" "2px 6px"
                , style "border-radius" "4px"
                , style "font-size" "11px"
                ]
                [ text statusText ]
            ]
        , div [ style "font-size" "12px", style "margin-bottom" "2px" ]
            [ span [ style "font-weight" "bold" ] [ text "Stav: " ]
            , text stateLabel
            ]
        , div [ style "font-size" "12px" ]
            [ span [ style "font-weight" "bold" ] [ text "Zostatok: " ]
            , text
                (if String.isEmpty instance.remainingInput then
                    "(prázdny)"

                 else
                    instance.remainingInput
                )
            ]
        ]
