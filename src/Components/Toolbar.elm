module Components.Toolbar exposing (view)

import Html exposing (Html, div, button, text, img)
import Html.Attributes as HA exposing (style)
import Html.Events exposing (onClick)
import Svg
import Svg.Attributes as SA
import Utils.Theme as Theme


type alias Config msg =
    { onResetTool : msg
    , onBuildTool : msg
    , onDeleteTool : msg
    , onUndo : msg
    , onRedo : msg
    , onSwitchToSimulator : msg
    , canUndo : Bool
    , canRedo : Bool
    , currentTool : String
    , isSimulateEnabled : Bool
    , simulateDisabledReason : Maybe String
    , onSimulateDisabledClick : msg
    , onExport : msg
    , onSave : msg
    , onLoad : msg
    , onShare : msg
    , onSwitchToConversion : msg
    , isConvertEnabled : Bool
    , convertDisabledReason : Maybe String
    , onConvertDisabledClick : msg
    , onShowGuide : msg
    , theme : Theme.Theme
    , settingsOpen : Bool
    , onToggleSettings : msg
    , onToggleDarkMode : msg
    , darkMode : Bool
    }


toolbarBg : Theme.Theme -> String -> String
toolbarBg theme tool =
    case tool of
        "BuildTool" ->
            theme.toolbarBg

        "DeleteTool" ->
            theme.toolbarDeleteBg

        _ ->
            theme.toolbarBg


view : Config msg -> Html msg
view config =
    div
        [ style "display" "flex"
        , style "flex-direction" "row"
        , style "padding" "14px 12px"
        , style "background-color" (toolbarBg config.theme config.currentTool)
        , style "gap" "10px"
        , style "border-bottom" ("2px solid " ++ config.theme.toolbarBorderColor)
        , style "align-items" "center"
        , style "transition" "background-color 0.25s"
        ]
        [ btnGroup
            [ tooltipBtn config.theme "Reset" config.onResetTool False "Reset"
            , iconBtn config.theme undoIcon config.onUndo (not config.canUndo) "Späť (Ctrl+Z)"
            , iconBtn config.theme redoIcon config.onRedo (not config.canRedo) "Dopredu (Ctrl+Y)"
            ]
        , btnGroup
            [ toolBtn config.theme "Stavať" config.onBuildTool (config.currentTool == "BuildTool") "Shift+B" config.theme.btnBuildActive
            , toolBtn config.theme "Odstrániť" config.onDeleteTool (config.currentTool == "DeleteTool") "Shift+D" config.theme.btnDelete
            ]
        , btnGroup
            [ tooltipBtn config.theme "Export" config.onExport False "Exportovať"
            , tooltipBtn config.theme "Uložiť" config.onSave False "Uložiť lokálne"
            , tooltipBtn config.theme "Načítať" config.onLoad False "Načítať lokálne"
            , tooltipBtn config.theme "Zdieľať cez URL" config.onShare False "Zdieľať cez URL"
            ]
        , div
            [ style "width" "1px"
            , style "height" "24px"
            , style "background-color" "rgba(255,255,255,0.2)"
            , style "margin" "0 4px"
            ]
            []
        , actionButton config.theme "NFA->DFA" config.onSwitchToConversion config.isConvertEnabled config.convertDisabledReason (Just config.onConvertDisabledClick) config.theme.btnConvert
        , div [ style "flex" "1" ] []
        , div
            [ style "width" "300px"
            , style "display" "flex"
            , style "justify-content" "flex-end"
            , style "gap" "8px"
            ]
            [ guideButton config.theme config.onShowGuide
            , actionButton config.theme "Simulovat" config.onSwitchToSimulator config.isSimulateEnabled config.simulateDisabledReason (Just config.onSimulateDisabledClick) config.theme.btnPrimary
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


btnGroup : List (Html msg) -> Html msg
btnGroup children =
    div
        [ style "display" "flex"
        , style "flex-direction" "row"
        , style "gap" "3px"
        , style "background-color" "rgba(0,0,0,0.25)"
        , style "border-radius" "6px"
        , style "padding" "3px"
        ]
        children


tooltipBtn : Theme.Theme -> String -> msg -> Bool -> String -> Html msg
tooltipBtn theme label onClickMsg isDisabled tipText =
    button
        [ onClick onClickMsg
        , HA.class "elm-btn"
        , style "padding" "10px 14px"
        , style "background-color" (if isDisabled then theme.btnDisabledBg else theme.btnSecondaryBg)
        , style "color" (if isDisabled then theme.btnDisabledText else "white")
        , style "border" "none"
        , style "border-radius" "4px"
        , style "cursor" (if isDisabled then "not-allowed" else "pointer")
        , style "font-size" "14px"
        , HA.disabled isDisabled
        , HA.title tipText
        ]
        [ text label ]


iconBtn : Theme.Theme -> Html msg -> msg -> Bool -> String -> Html msg
iconBtn theme icon onClickMsg isDisabled tipText =
    button
        [ onClick onClickMsg
        , HA.class "elm-btn"
        , style "padding" "10px 12px"
        , style "background-color" (if isDisabled then theme.btnDisabledBg else theme.btnSecondaryBg)
        , style "color" (if isDisabled then theme.btnDisabledText else "white")
        , style "border" "none"
        , style "border-radius" "4px"
        , style "cursor" (if isDisabled then "not-allowed" else "pointer")
        , style "display" "flex"
        , style "align-items" "center"
        , HA.disabled isDisabled
        , HA.title tipText
        ]
        [ icon ]


toolBtn : Theme.Theme -> String -> msg -> Bool -> String -> String -> Html msg
toolBtn theme label onClickMsg isActive shortcut activeColor =
    let
        displayLabel =
            if isActive then
                label ++ "  [" ++ shortcut ++ "]"
            else
                label
    in
    button
        [ onClick onClickMsg
        , HA.class "elm-btn"
        , style "padding" "10px 14px"
        , style "background-color" (if isActive then activeColor else theme.btnSecondaryBg)
        , style "color" "white"
        , style "border" "none"
        , style "border-radius" "4px"
        , style "cursor" "pointer"
        , style "font-size" "14px"
        , style "font-weight" (if isActive then "bold" else "normal")
        , HA.title (label ++ " (" ++ shortcut ++ ")")
        ]
        [ text displayLabel ]


undoIcon : Html msg
undoIcon =
    Svg.svg
        [ SA.width "16"
        , SA.height "16"
        , SA.viewBox "0 0 24 24"
        , SA.fill "currentColor"
        ]
        [ Svg.path
            [ SA.d "M12.5 8c-2.65 0-5.05.99-6.9 2.6L2 7v9h9l-3.62-3.62c1.39-1.16 3.16-1.88 5.12-1.88 3.54 0 6.55 2.31 7.6 5.5l2.37-.78C21.08 11.03 17.15 8 12.5 8z" ]
            []
        ]


redoIcon : Html msg
redoIcon =
    Svg.svg
        [ SA.width "16"
        , SA.height "16"
        , SA.viewBox "0 0 24 24"
        , SA.fill "currentColor"
        ]
        [ Svg.path
            [ SA.d "M18.4 10.6C16.55 8.99 14.15 8 11.5 8c-4.65 0-8.58 3.03-9.96 7.22L3.9 16c1.05-3.19 4.05-5.5 7.6-5.5 1.95 0 3.73.72 5.12 1.88L13 16h9V7l-3.6 3.6z" ]
            []
        ]


guideButton : Theme.Theme -> msg -> Html msg
guideButton theme onClickMsg =
    button
        [ onClick onClickMsg
        , HA.class "elm-btn"
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
            [ HA.src "guide_icon.png"
            , style "width" "20px"
            , style "height" "20px"
            , style "filter" "brightness(0) invert(1)"
            ]
            []
        , text "Sprievodca"
        ]


actionButton : Theme.Theme -> String -> msg -> Bool -> Maybe String -> Maybe msg -> String -> Html msg
actionButton theme label onClickMsg isEnabled disabledReason onDisabledClick bgColor =
    let
        ( effectiveClick, isDisabled ) =
            if isEnabled then
                ( onClickMsg, False )
            else
                case onDisabledClick of
                    Just m -> ( m, False )
                    Nothing -> ( onClickMsg, True )
    in
    button
        [ onClick effectiveClick
        , HA.class "elm-btn"
        , style "padding" "11px 18px"
        , style "background-color" (if isEnabled then bgColor else theme.btnDisabledBg)
        , style "color" (if isEnabled then "white" else theme.btnDisabledText)
        , style "border" "none"
        , style "border-radius" "5px"
        , style "cursor" (if isEnabled then "pointer" else "not-allowed")
        , style "font-size" "14px"
        , style "font-weight" "bold"
        , HA.disabled isDisabled
        , HA.title (disabledReason |> Maybe.withDefault "")
        ]
        [ text label ]
