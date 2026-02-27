module Components.SimulateToolbar exposing (view)

import Html exposing (Html, div, button, text, input, img)
import Html.Attributes exposing (style, type_, value, step, disabled, src)
import Html.Attributes as HA
import Html.Events exposing (onClick, onInput)


type alias Config msg =
    { onStepBackward : msg
    , onStepForward : msg
    , onReset : msg
    , onSwitchToEditor : msg
    , canStepBackward : Bool
    , canStepForward : Bool
    , nextSymbol : Maybe String
    , onToggleAutoRun : msg
    , autoRunning : Bool
    , autoSpeed : Float
    , onSetAutoSpeed : String -> msg
    , onShowGuide : msg
    }


speedLabel : Float -> String
speedLabel ms =
    if ms >= 1000 then
        String.fromFloat (toFloat (round (ms / 100)) / 10) ++ "s"

    else
        String.fromInt (round ms) ++ "ms"


view : Config msg -> Html msg
view config =
    div
        [ style "display" "flex"
        , style "flex-direction" "row"
        , style "padding" "14px 12px"
        , style "background-color" "#1a2f4a"
        , style "gap" "10px"
        , style "border-bottom" "2px solid white"
        , style "align-items" "center"
        ]
        [ toolButton "Reset" config.onReset True False
        , toolButton "Krok späť" config.onStepBackward config.canStepBackward False
        , toolButton
            (case config.nextSymbol of
                Nothing ->
                    "Krok vpred"

                Just s ->
                    "Krok vpred  '" ++ s ++ "'"
            )
            config.onStepForward
            config.canStepForward
            False
        , autoRunButton config.onToggleAutoRun config.autoRunning
        , div
            [ style "display" "flex"
            , style "align-items" "center"
            , style "gap" "6px"
            ]
            [ input
                [ type_ "range"
                , HA.min "100"
                , HA.max "2000"
                , step "100"
                , value (String.fromInt (round config.autoSpeed))
                , onInput config.onSetAutoSpeed
                , style "width" "90px"
                , style "cursor" "pointer"
                , style "accent-color" "#00bcd4"
                ]
                []
            , div
                [ style "color" "#cfd8dc"
                , style "font-size" "12px"
                , style "min-width" "36px"
                ]
                [ text (speedLabel config.autoSpeed) ]
            ]
        , div [ style "flex" "1" ] []
        , div
            [ style "width" "300px"
            , style "display" "flex"
            , style "justify-content" "flex-end"
            , style "gap" "8px"
            ]
            [ guideButton config.onShowGuide
            , actionButton "<- Editor" config.onSwitchToEditor True
            ]
        ]


autoRunButton : msg -> Bool -> Html msg
autoRunButton onToggle running =
    button
        [ onClick onToggle
        , style "padding" "10px 14px"
        , style "background-color" (if running then "#00897b" else "#546e7a")
        , style "color" "white"
        , style "border" "none"
        , style "border-radius" "4px"
        , style "cursor" "pointer"
        , style "font-size" "14px"
        , style "font-weight" (if running then "bold" else "normal")
        , style "transition" "all 0.2s"
        ]
        [ text (if running then "⏸ Pauza" else "▶ Auto") ]


toolButton : String -> msg -> Bool -> Bool -> Html msg
toolButton label onClickMsg isEnabled isActive =
    button
        [ onClick onClickMsg
        , Html.Attributes.disabled (not isEnabled)
        , style "padding" "10px 14px"
        , style "background-color" (if isActive then "#00897b" else if isEnabled then "#546e7a" else "#b0bec5")
        , style "color" "white"
        , style "border" "none"
        , style "border-radius" "4px"
        , style "cursor" (if isEnabled then "pointer" else "not-allowed")
        , style "font-size" "14px"
        , style "font-weight" (if isActive then "bold" else "normal")
        , style "transition" "all 0.3s"
        ]
        [ text label ]


actionButton : String -> msg -> Bool -> Html msg
actionButton label onClickMsg isEnabled =
    button
        [ onClick onClickMsg
        , style "padding" "11px 18px"
        , style "background-color" (if isEnabled then "#0277bd" else "#b3e5fc")
        , style "color" "white"
        , style "border" "none"
        , style "border-radius" "5px"
        , style "cursor" (if isEnabled then "pointer" else "not-allowed")
        , style "font-size" "14px"
        , style "font-weight" "bold"
        , Html.Attributes.disabled (not isEnabled)
        ]
        [ text label ]


guideButton : msg -> Html msg
guideButton onClickMsg =
    button
        [ onClick onClickMsg
        , style "padding" "11px 18px"
        , style "background-color" "#00796b"
        , style "color" "white"
        , style "border" "none"
        , style "border-radius" "5px"
        , style "cursor" "pointer"
        , style "font-size" "14px"
        , style "font-weight" "bold"
        , style "display" "flex"
        , style "align-items" "center"
        , style "gap" "6px"
        ]
        [ img
            [ src "guide_icon.png"
            , style "width" "20px"
            , style "height" "20px"
            , style "filter" "brightness(0) invert(1)"
            ]
            []
        , text "Sprievodca"
        ]
