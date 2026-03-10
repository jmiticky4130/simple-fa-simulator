module Components.SimulateToolbar exposing (view)

import Html exposing (Html, div, button, text, input, img)
import Html.Attributes exposing (style, type_, value, step, disabled, src)
import Html.Attributes as HA
import Html.Events exposing (onClick, onInput)
import Utils.Theme as Theme


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
    , theme : Theme.Theme
    , settingsOpen : Bool
    , onToggleSettings : msg
    , onToggleDarkMode : msg
    , darkMode : Bool
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
        , style "background-color" config.theme.toolbarBg
        , style "gap" "10px"
        , style "border-bottom" ("2px solid " ++ config.theme.toolbarBorderColor)
        , style "align-items" "center"
        ]
        [ toolButton config.theme "Reset" config.onReset True False
        , toolButton config.theme "Krok späť" config.onStepBackward config.canStepBackward False
        , toolButton config.theme
            (case config.nextSymbol of
                Nothing ->
                    "Krok vpred"

                Just s ->
                    "Krok vpred  '" ++ s ++ "'"
            )
            config.onStepForward
            config.canStepForward
            False
        , autoRunButton config.theme config.onToggleAutoRun config.autoRunning
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
            [ guideButton config.theme config.onShowGuide
            , actionButton config.theme "<- Editor" config.onSwitchToEditor True
            , settingsGearBtn config
            ]
        ]


settingsGearBtn : Config msg -> Html msg
settingsGearBtn config =
    div
        [ style "position" "relative"
        , style "display" "flex"
        ]
        [ button
            [ onClick config.onToggleSettings
            , HA.class "elm-btn"
            , style "padding" "11px 18px"
            , style "background-color" config.theme.btnSecondaryBg
            , style "color" "white"
            , style "border" "none"
            , style "border-radius" "5px"
            , style "cursor" "pointer"
            , style "font-size" "14px"
            , style "font-weight" "bold"
            ]
            [ text "\u{2699}" ]
        , if config.settingsOpen then
            div
                [ style "position" "absolute"
                , style "top" "100%"
                , style "right" "0"
                , style "margin-top" "4px"
                , style "background-color" config.theme.settingsBg
                , style "border" ("1px solid " ++ config.theme.settingsBorder)
                , style "border-radius" "6px"
                , style "padding" "12px 16px"
                , style "z-index" "2000"
                , style "min-width" "180px"
                , style "box-shadow" "0 4px 16px rgba(0,0,0,0.4)"
                ]
                [ div
                    [ style "color" "white"
                    , style "font-size" "13px"
                    , style "font-weight" "bold"
                    , style "margin-bottom" "10px"
                    ]
                    [ text "Nastavenia" ]
                , div
                    [ style "display" "flex"
                    , style "align-items" "center"
                    , style "justify-content" "space-between"
                    , style "gap" "12px"
                    ]
                    [ div [ style "color" "#cfd8dc", style "font-size" "13px" ]
                        [ text "Tmavý režim" ]
                    , pillToggle config.onToggleDarkMode config.darkMode
                    ]
                ]
          else
            text ""
        ]


pillToggle : msg -> Bool -> Html msg
pillToggle onToggle isOn =
    div
        [ onClick onToggle
        , style "width" "40px"
        , style "height" "20px"
        , style "border-radius" "10px"
        , style "background-color" (if isOn then "#0288d1" else "#546e7a")
        , style "cursor" "pointer"
        , style "position" "relative"
        , style "transition" "background-color 0.2s"
        , style "flex-shrink" "0"
        ]
        [ div
            [ style "position" "absolute"
            , style "top" "2px"
            , style "left" (if isOn then "22px" else "2px")
            , style "width" "16px"
            , style "height" "16px"
            , style "border-radius" "50%"
            , style "background-color" "white"
            , style "transition" "left 0.2s"
            ]
            []
        ]


autoRunButton : Theme.Theme -> msg -> Bool -> Html msg
autoRunButton theme onToggle running =
    button
        [ onClick onToggle
        , style "padding" "10px 14px"
        , style "background-color" (if running then theme.btnAutoRunActive else theme.btnSecondaryBg)
        , style "color" "white"
        , style "border" "none"
        , style "border-radius" "4px"
        , style "cursor" "pointer"
        , style "font-size" "14px"
        , style "font-weight" (if running then "bold" else "normal")
        , style "transition" "all 0.2s"
        ]
        [ text (if running then "Pauza" else "Auto") ]


toolButton : Theme.Theme -> String -> msg -> Bool -> Bool -> Html msg
toolButton theme label onClickMsg isEnabled isActive =
    button
        [ onClick onClickMsg
        , disabled (not isEnabled)
        , style "padding" "10px 14px"
        , style "background-color" (if isActive then theme.btnAutoRunActive else if isEnabled then theme.btnSecondaryBg else theme.btnDisabledBg)
        , style "color" (if isEnabled then "white" else theme.btnDisabledText)
        , style "border" "none"
        , style "border-radius" "4px"
        , style "cursor" (if isEnabled then "pointer" else "not-allowed")
        , style "font-size" "14px"
        , style "font-weight" (if isActive then "bold" else "normal")
        , style "transition" "all 0.3s"
        ]
        [ text label ]


actionButton : Theme.Theme -> String -> msg -> Bool -> Html msg
actionButton theme label onClickMsg isEnabled =
    button
        [ onClick onClickMsg
        , style "padding" "11px 18px"
        , style "background-color" (if isEnabled then theme.btnPrimary else theme.btnDisabledBg)
        , style "color" "white"
        , style "border" "none"
        , style "border-radius" "5px"
        , style "cursor" (if isEnabled then "pointer" else "not-allowed")
        , style "font-size" "14px"
        , style "font-weight" "bold"
        , disabled (not isEnabled)
        ]
        [ text label ]


guideButton : Theme.Theme -> msg -> Html msg
guideButton theme onClickMsg =
    button
        [ onClick onClickMsg
        , style "padding" "11px 18px"
        , style "background-color" theme.btnGuide
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
