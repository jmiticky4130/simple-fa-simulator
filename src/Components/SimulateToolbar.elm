module Components.SimulateToolbar exposing (view)

import Html exposing (Html, div, button, text, input)
import Html.Attributes exposing (style, type_, value, step, disabled)
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
        , style "padding" "10px"
        , style "background-color" "#37474f"
        , style "gap" "10px"
        , style "border-bottom" "2px solid #263238"
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
        , actionButton "Späť do editora" config.onSwitchToEditor True
        ]


autoRunButton : msg -> Bool -> Html msg
autoRunButton onToggle running =
    button
        [ onClick onToggle
        , style "padding" "10px 16px"
        , style "background-color" (if running then "#00897b" else "#546e7a")
        , style "color" "white"
        , style "border" "none"
        , style "border-radius" "5px"
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
