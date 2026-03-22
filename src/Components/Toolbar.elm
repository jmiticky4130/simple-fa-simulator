module Components.Toolbar exposing (view)

import Html exposing (Html, div, button, text, img)
import Html.Attributes as HA exposing (style)
import Html.Events exposing (onClick)
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
    , isAddDeadStateEnabled : Bool
    , onAddDeadState : msg
    , addDeadStateInfoTooltip : String
    , onShowGuide : msg
    , theme : Theme.Theme
    , settingsOpen : Bool
    , onToggleSettings : msg
    , onToggleDarkMode : msg
    , darkMode : Bool
    , language : Language
    , onToggleLanguage : msg
    , gridMode : Bool
    , onToggleGridMode : msg
    , tutorialHighlightGroup : Maybe String
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
        [ highlightWrap (config.tutorialHighlightGroup == Just "undoRedo") (btnGroup
            [ iconTextBtn config.theme resetIcon t.reset config.onResetTool False t.reset
            , iconBtn config.theme undoIcon config.onUndo (not config.canUndo) "Ctrl+Z"
            , iconBtn config.theme redoIcon config.onRedo (not config.canRedo) "Ctrl+Y"
            ])
        , highlightWrap (config.tutorialHighlightGroup == Just "tools") (btnGroup
            [ toolBtn config.theme t.build config.onBuildTool (config.currentTool == "BuildTool") "Shift+B" config.theme.btnBuildActive
            , toolBtn config.theme t.delete config.onDeleteTool (config.currentTool == "DeleteTool") "Shift+D" config.theme.btnDelete
            ])
        , highlightWrap (config.tutorialHighlightGroup == Just "files") (btnGroup
            [ iconTextBtn config.theme exportIcon t.export config.onExport False t.exportTooltip
            , iconTextBtn config.theme saveIcon t.save config.onSave False t.saveTooltip
            , iconTextBtn config.theme loadIcon t.load config.onLoad False t.loadTooltip
            , iconTextBtn config.theme shareIcon t.shareViaUrl config.onShare False t.shareViaUrlTooltip
            ])
        , div
            [ style "width" "1px"
            , style "height" "24px"
            , style "background-color" "rgba(255,255,255,0.2)"
            , style "margin" "0 4px"
            ]
            []
        , highlightWrap (config.tutorialHighlightGroup == Just "convert") (div [ style "display" "flex", style "gap" "8px", style "align-items" "center" ]
            [ actionButton config.theme "NFA->DFA" config.onSwitchToConversion config.isConvertEnabled config.convertDisabledReason (Just config.onConvertDisabledClick) config.theme.btnConvert False
            , deadStateButtonGroup config t
            ])
        , div [ style "flex" "1" ] []
        , div
            [ style "width" "300px"
            , style "display" "flex"
            , style "justify-content" "flex-end"
            , style "gap" "8px"
            ]
            [ guideButton config.theme t.guide config.onShowGuide
            , actionButton config.theme t.simulate config.onSwitchToSimulator config.isSimulateEnabled config.simulateDisabledReason (Just config.onSimulateDisabledClick) config.theme.btnPrimary (config.tutorialHighlightGroup == Just "simulate")
            , settingsGearBtn config
            ]
        ]


deadStateButtonGroup : Config msg -> Translations.Translations -> Html msg
deadStateButtonGroup config t =
    button
        ([ HA.class "elm-btn"
         , style "padding" "11px 18px"
         , style "background-color" (if config.isAddDeadStateEnabled then config.theme.btnConvert else config.theme.btnDisabledBg)
         , style "color" (if config.isAddDeadStateEnabled then "white" else config.theme.btnDisabledText)
         , style "border" "none"
         , style "border-radius" "5px"
         , style "cursor" (if config.isAddDeadStateEnabled then "pointer" else "not-allowed")
         , style "font-size" "14px"
         , style "font-weight" "bold"
         , style "display" "flex"
         , style "align-items" "center"
         , style "gap" "6px"
         , HA.disabled (not config.isAddDeadStateEnabled)
         , HA.title (if config.isAddDeadStateEnabled then config.addDeadStateInfoTooltip else "")
         ]
         ++ (if config.isAddDeadStateEnabled then [ Html.Events.onClick config.onAddDeadState ] else [])
        )
        [ text t.editorAddDeadState
        , div
            [ style "width" "16px"
            , style "height" "16px"
            , style "border-radius" "50%"
            , style "background-color" "rgba(255,255,255,0.25)"
            , style "font-size" "11px"
            , style "font-weight" "bold"
            , style "display" "flex"
            , style "align-items" "center"
            , style "justify-content" "center"
            , style "flex-shrink" "0"
            ]
            [ text "?" ]
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
            [ Html.img [ HA.src "icons/settings_svg.svg", HA.width 20, HA.height 20 ] [] ]
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
                    [ style "height" "1px"
                    , style "background-color" config.theme.settingsBorder
                    , style "margin" "8px 0"
                    ]
                    []
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
                , div
                    [ style "height" "1px"
                    , style "background-color" config.theme.settingsBorder
                    , style "margin" "8px 0"
                    ]
                    []
                , div
                    [ style "display" "flex"
                    , style "align-items" "center"
                    , style "justify-content" "space-between"
                    , style "gap" "12px"
                    ]
                    [ div [ style "color" "#cfd8dc", style "font-size" "13px" ]
                        [ text t.gridMode ]
                    , pillToggle config.onToggleGridMode config.gridMode
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


highlightWrap : Bool -> Html msg -> Html msg
highlightWrap isHighlighted inner =
    if isHighlighted then
        div
            [ style "position" "relative"
            , style "z-index" "501"
            , style "box-shadow" "0 0 0 3px #ffeb3b, 0 0 18px rgba(255,235,59,0.7)"
            , style "border-radius" "6px"
            ]
            [ inner ]
    else
        inner


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
        [ icon, Html.span [ HA.class "toolbar-btn-label" ] [ text label ] ]


exportIcon : Html msg
exportIcon =
    Html.img [ HA.src "icons/export_svg.svg", HA.width 16, HA.height 16 ] []


saveIcon : Html msg
saveIcon =
    Html.img [ HA.src "icons/save_svg.svg", HA.width 16, HA.height 16 ] []


loadIcon : Html msg
loadIcon =
    Html.img [ HA.src "icons/load_svg.svg", HA.width 16, HA.height 16 ] []


shareIcon : Html msg
shareIcon =
    Html.img [ HA.src "icons/share_svg.svg", HA.width 16, HA.height 16 ] []


resetIcon : Html msg
resetIcon =
    Html.img [ HA.src "icons/reset_svg.svg", HA.width 16, HA.height 16 ] []


undoIcon : Html msg
undoIcon =
    Html.img [ HA.src "icons/undo_svg.svg", HA.width 16, HA.height 16 ] []


redoIcon : Html msg
redoIcon =
    Html.img [ HA.src "icons/redo_svg.svg", HA.width 16, HA.height 16 ] []


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
            [ HA.src "icons/guide_icon.svg"
            , style "width" "20px"
            , style "height" "20px"
            , style "filter" "brightness(0) invert(1)"
            ]
            []
        , text label
        ]


actionButton : Theme.Theme -> String -> msg -> Bool -> Maybe String -> Maybe msg -> String -> Bool -> Html msg
actionButton theme label onClickMsg isEnabled disabledReason onDisabledClick bgColor isHighlighted =
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
        ([ onClick effectiveClick
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
        ++ (if isHighlighted then
                [ style "position" "relative"
                , style "z-index" "501"
                , style "box-shadow" "0 0 0 3px #ffeb3b, 0 0 18px rgba(255,235,59,0.7)"
                ]
            else
                []
           )
        )
        [ text label ]
