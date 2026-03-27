module Components.NfaInstancePanel exposing (Config, view)

import Html exposing (Html, button, div, span, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Shared exposing (NfaInstance, State)
import Utils.Theme as Theme
import Utils.Translations as Translations exposing (Language)


type alias Config msg =
    { instances : List NfaInstance
    , selectedId : Maybe Int
    , onSelect : Int -> msg
    , states : List State
    , visibleCount : Int
    , onLoadMore : msg
    , theme : Theme.Theme
    , language : Language
    }


view : Config msg -> Html msg
view config =
    let
        t =
            Translations.getTranslations config.language

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
                            , style "border" ("1px solid " ++ config.theme.inputBorder)
                            , style "border-radius" "4px"
                            , style "background" config.theme.inputBg
                            , style "color" config.theme.textPrimary
                            , style "font-size" "12px"
                            ]
                            [ text (t.loadMorePrefix ++ String.fromInt config.visibleCount ++ t.loadMoreMiddle ++ String.fromInt total ++ t.loadMoreSuffix) ]
                        ]
                    ]

                else
                    []
               )
        )


viewInstance : Config msg -> Int -> NfaInstance -> Html msg
viewInstance config displayIdx instance =
    let
        t =
            Translations.getTranslations config.language

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
                    t.deadBranch

        ( statusText, statusBg, borderColor ) =
            case instance.verdict of
                Nothing ->
                    ( t.running, config.theme.infoColor, if isSelected then config.theme.infoColorDark else config.theme.infoColor )

                Just v ->
                    if v.isAccepted then
                        ( t.accepted, config.theme.successColor, if isSelected then config.theme.successColorDark else config.theme.successColor )

                    else
                        ( t.rejected, config.theme.errorColor, if isSelected then config.theme.errorColorDark else config.theme.errorColor )

        borderWidth =
            if isSelected then
                "3px"

            else
                "2px"

        itemBg =
            if isSelected then
                config.theme.inputBg
            else
                config.theme.rightPanelBg
    in
    div
        [ style "border" (borderWidth ++ " solid " ++ borderColor)
        , style "border-radius" "6px"
        , style "padding" "8px"
        , style "margin-bottom" "8px"
        , style "cursor" "pointer"
        , style "background-color" itemBg
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
                , style "color" config.theme.textPrimary
                ]
                [ text (t.instancePrefix ++ String.fromInt displayIdx) ]
            , span
                [ style "background-color" statusBg
                , style "color" config.theme.textOnDark
                , style "padding" "2px 6px"
                , style "border-radius" "4px"
                , style "font-size" "11px"
                ]
                [ text statusText ]
            ]
        , div [ style "font-size" "12px", style "margin-bottom" "2px", style "color" config.theme.textPrimary ]
            [ span [ style "font-weight" "bold" ] [ text (t.stateLabel ++ ": ") ]
            , text stateLabel
            ]
        , div [ style "font-size" "12px", style "color" config.theme.textPrimary ]
            [ span [ style "font-weight" "bold" ] [ text (t.remainingLabel ++ ": ") ]
            , text
                (if String.isEmpty instance.remainingInput then
                    t.emptyInput

                 else
                    instance.remainingInput
                )
            ]
        ]
