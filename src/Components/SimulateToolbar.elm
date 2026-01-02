module Components.SimulateToolbar exposing (view)

import Html exposing (Html, div, button, text, input)
import Html.Attributes exposing (style, type_, min, max, value, step, disabled)
import Html.Events exposing (onClick, onInput)


type alias Config msg =
    { onStepBackward : msg
    , onStepForward : msg
    , onReset : msg
    , onSwitchToEditor : msg
    , canStepBackward : Bool
    , canStepForward : Bool
    }


view : Config msg -> Html msg
view config =
    div
        [ style "display" "flex"
        , style "flex-direction" "row"
        , style "padding" "10px"
        , style "background-color" "#37474f"
        , style "gap" "10px"
        , style "border-bottom" "2px solid #263238"
        , style "align-items" "center"
        ]
        [ toolButton "Reset" config.onReset True False
        , toolButton "Krok späť" config.onStepBackward config.canStepBackward False
        , toolButton "Krok vpred" config.onStepForward config.canStepForward False
        , actionButton "Späť do editora" config.onSwitchToEditor True
        ]


toolButton : String -> msg -> Bool -> Bool -> Html msg
toolButton label onClickMsg isEnabled isActive =
    button
        [ onClick onClickMsg
        , Html.Attributes.disabled (not isEnabled)
        , style "padding" "10px 20px"
        , style "background-color" (if isActive then "#00897b" else if isEnabled then "#546e7a" else "#b0bec5")
        , style "color" "white"
        , style "border" "none"
        , style "border-radius" "5px"
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
        , style "padding" "10px 20px"
        , style "background-color" (if isEnabled then "#0277bd" else "#b3e5fc")
        , style "color" "white"
        , style "border" "none"
        , style "border-radius" "5px"
        , style "cursor" (if isEnabled then "pointer" else "not-allowed")
        , style "font-size" "14px"
        , style "margin-left" "auto"
        , style "font-weight" "bold"
        , Html.Attributes.disabled (not isEnabled)
        ]
        [ text label ]
