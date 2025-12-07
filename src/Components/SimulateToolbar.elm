module Components.SimulateToolbar exposing (view)

import Html exposing (Html, div, button, text, input)
import Html.Attributes exposing (style, type_, min, max, value, step, disabled)
import Html.Events exposing (onClick, onInput)


type alias Config msg =
    { onStepBackward : msg
    , onStepForward : msg
    , onAutoRun : msg
    , onReset : msg
    , onSwitchToEditor : msg
    , canStepBackward : Bool
    , canStepForward : Bool
    , isAutoRunning : Bool
    }


view : Config msg -> Html msg
view config =
    div
        [ style "display" "flex"
        , style "flex-direction" "row"
        , style "padding" "10px"
        , style "background-color" "#2c3e50"
        , style "gap" "10px"
        , style "border-bottom" "2px solid #34495e"
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
        , style "background-color" (if isActive then "#3498db" else if isEnabled then "#34495e" else "#7f8c8d")
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
        , style "background-color" (if isEnabled then "#3498db" else "#95a5a6")
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
