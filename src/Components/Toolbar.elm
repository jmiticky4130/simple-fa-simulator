module Components.Toolbar exposing (view)

import Html exposing (Html, div, button, text, img)
import Html.Attributes as HA exposing (style)
import Html.Events exposing (onClick)
import Svg
import Svg.Attributes as SA
import Utils.Theme as Theme
import Utils.Translations as Translations exposing (Language)


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
    , language : Language
    , onToggleLanguage : msg
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
    let
        t =
            Translations.getTranslations config.language
    in
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
            [ iconTextBtn config.theme resetIcon t.reset config.onResetTool False t.reset
            , iconBtn config.theme undoIcon config.onUndo (not config.canUndo) "Ctrl+Z"
            , iconBtn config.theme redoIcon config.onRedo (not config.canRedo) "Ctrl+Y"
            ]
        , btnGroup
            [ toolBtn config.theme t.build config.onBuildTool (config.currentTool == "BuildTool") "Shift+B" config.theme.btnBuildActive
            , toolBtn config.theme t.delete config.onDeleteTool (config.currentTool == "DeleteTool") "Shift+D" config.theme.btnDelete
            ]
        , btnGroup
            [ iconTextBtn config.theme exportIcon t.export config.onExport False t.exportTooltip
            , iconTextBtn config.theme saveIcon t.save config.onSave False t.saveTooltip
            , iconTextBtn config.theme loadIcon t.load config.onLoad False t.loadTooltip
            , iconTextBtn config.theme shareIcon t.shareViaUrl config.onShare False t.shareViaUrlTooltip
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
            [ guideButton config.theme t.guide config.onShowGuide
            , actionButton config.theme t.simulate config.onSwitchToSimulator config.isSimulateEnabled config.simulateDisabledReason (Just config.onSimulateDisabledClick) config.theme.btnPrimary
            , settingsGearBtn config
            ]
        ]


settingsGearBtn : Config msg -> Html msg
settingsGearBtn config =
    let
        t = Translations.getTranslations config.language
    in
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
                    [ text t.settings ]
                , div
                    [ style "display" "flex"
                    , style "align-items" "center"
                    , style "justify-content" "space-between"
                    , style "gap" "12px"
                    ]
                    [ div [ style "color" "#cfd8dc", style "font-size" "13px" ]
                        [ text t.darkMode ]
                    , pillToggle config.onToggleDarkMode config.darkMode
                    ]
                , div
                    [ style "display" "flex"
                    , style "align-items" "center"
                    , style "justify-content" "space-between"
                    , style "gap" "12px"
                    ]
                    [ div [ style "color" "#cfd8dc", style "font-size" "13px" ]
                        [ text t.language ]
                    , languageToggleBtn t config.onToggleLanguage
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


languageToggleBtn : Translations.Translations -> msg -> Html msg
languageToggleBtn t onToggle =
    button
        [ onClick onToggle
        , style "background" "#37474f"
        , style "color" "white"
        , style "border" "none"
        , style "border-radius" "4px"
        , style "padding" "2px 8px"
        , style "font-size" "12px"
        , style "cursor" "pointer"
        ]
        [ text t.languageName ]


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


iconTextBtn : Theme.Theme -> Html msg -> String -> msg -> Bool -> String -> Html msg
iconTextBtn theme icon label onClickMsg isDisabled tipText =
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
        , style "display" "flex"
        , style "align-items" "center"
        , style "gap" "6px"
        , HA.disabled isDisabled
        , HA.title tipText
        ]
        [ icon, text label ]


exportIcon : Html msg
exportIcon =
    Svg.svg
        [ SA.width "16", SA.height "16", SA.viewBox "0 0 24 24", SA.fill "none" ]
        [ Svg.path [ SA.d "M12 20C7.58172 20 4 16.4183 4 12M20 12C20 14.5264 18.8289 16.7792 17 18.2454", SA.stroke "currentColor", SA.strokeWidth "1.5", SA.strokeLinecap "round" ] []
        , Svg.path [ SA.d "M12 14L12 4M12 4L15 7M12 4L9 7", SA.stroke "currentColor", SA.strokeWidth "1.5", SA.strokeLinecap "round", SA.strokeLinejoin "round" ] []
        ]


saveIcon : Html msg
saveIcon =
    Svg.svg
        [ SA.width "16", SA.height "16", SA.viewBox "0 0 24 24", SA.fill "currentColor" ]
        [ Svg.path [ SA.fillRule "evenodd", SA.clipRule "evenodd", SA.d "M18.1716 1C18.702 1 19.2107 1.21071 19.5858 1.58579L22.4142 4.41421C22.7893 4.78929 23 5.29799 23 5.82843V20C23 21.6569 21.6569 23 20 23H4C2.34315 23 1 21.6569 1 20V4C1 2.34315 2.34315 1 4 1H18.1716ZM4 3C3.44772 3 3 3.44772 3 4V20C3 20.5523 3.44772 21 4 21L5 21L5 15C5 13.3431 6.34315 12 8 12L16 12C17.6569 12 19 13.3431 19 15V21H20C20.5523 21 21 20.5523 21 20V6.82843C21 6.29799 20.7893 5.78929 20.4142 5.41421L18.5858 3.58579C18.2107 3.21071 17.702 3 17.1716 3H17V5C17 6.65685 15.6569 8 14 8H10C8.34315 8 7 6.65685 7 5V3H4ZM17 21V15C17 14.4477 16.5523 14 16 14L8 14C7.44772 14 7 14.4477 7 15L7 21L17 21ZM9 3H15V5C15 5.55228 14.5523 6 14 6H10C9.44772 6 9 5.55228 9 5V3Z" ] []
        ]


loadIcon : Html msg
loadIcon =
    Svg.svg
        [ SA.width "16", SA.height "16", SA.viewBox "0 0 24 24", SA.fill "none" ]
        [ Svg.path [ SA.d "M12 3V16M12 16L16 11.625M12 16L8 11.625", SA.stroke "currentColor", SA.strokeWidth "1.5", SA.strokeLinecap "round", SA.strokeLinejoin "round" ] []
        , Svg.path [ SA.d "M15 21H9C6.17157 21 4.75736 21 3.87868 20.1213C3 19.2426 3 17.8284 3 15M21 15C21 17.8284 21 19.2426 20.1213 20.1213C19.8215 20.4211 19.4594 20.6186 19 20.7487", SA.stroke "currentColor", SA.strokeWidth "1.5", SA.strokeLinecap "round", SA.strokeLinejoin "round" ] []
        ]


shareIcon : Html msg
shareIcon =
    Svg.svg
        [ SA.width "16", SA.height "16", SA.viewBox "0 0 24 24", SA.fill "none" ]
        [ Svg.path [ SA.d "M8.68445 10.6578L13 8.50003M15.3157 16.6578L11 14.5M21 6C21 7.65685 19.6569 9 18 9C16.3431 9 15 7.65685 15 6C15 4.34315 16.3431 3 18 3C19.6569 3 21 4.34315 21 6ZM9 12C9 13.6569 7.65685 15 6 15C4.34315 15 3 13.6569 3 12C3 10.3431 4.34315 9 6 9C7.65685 9 9 10.3431 9 12ZM21 18C21 19.6569 19.6569 21 18 21C16.3431 21 15 19.6569 15 18C15 16.3431 16.3431 15 18 15C19.6569 15 21 16.3431 21 18Z", SA.stroke "currentColor", SA.strokeWidth "1.5" ] []
        ]


resetIcon : Html msg
resetIcon =
    Svg.svg
        [ SA.width "16", SA.height "16", SA.viewBox "0 0 1920 1920", SA.fill "currentColor" ]
        [ Svg.path [ SA.fillRule "evenodd", SA.d "M960 0v112.941c467.125 0 847.059 379.934 847.059 847.059 0 467.125-379.934 847.059-847.059 847.059-467.125 0-847.059-379.934-847.059-847.059 0-267.106 126.607-515.915 338.824-675.727v393.374h112.94V112.941H0v112.941h342.89C127.058 407.38 0 674.711 0 960c0 529.355 430.645 960 960 960s960-430.645 960-960S1489.355 0 960 0" ] [] ]


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


guideButton : Theme.Theme -> String -> msg -> Html msg
guideButton theme label onClickMsg =
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
            [ HA.src "icons/guide_icon.png"
            , style "width" "20px"
            , style "height" "20px"
            , style "filter" "brightness(0) invert(1)"
            ]
            []
        , text label
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
