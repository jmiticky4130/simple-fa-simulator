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
    , windowWidth : Int
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

        compactTools =
            config.windowWidth < 1250

        compactFiles =
            config.windowWidth < 1540
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
        [ highlightWrap config.theme (config.tutorialHighlightGroup == Just "undoRedo") (btnGroup config.theme
            [ iconTextBtn config.theme resetIcon t.reset config.onResetTool False t.reset False
            , iconBtn config.theme undoIcon config.onUndo (not config.canUndo) "Ctrl+Z"
            , iconBtn config.theme redoIcon config.onRedo (not config.canRedo) "Ctrl+Y"
            ])
        , highlightWrap config.theme (config.tutorialHighlightGroup == Just "tools") (btnGroup config.theme
            [ toolBtn config.theme t.build config.onBuildTool (config.currentTool == "BuildTool") "Shift+B" config.theme.btnBuildActive (Just buildToolIcon) compactTools
            , toolBtn config.theme t.delete config.onDeleteTool (config.currentTool == "DeleteTool") "Shift+D" config.theme.btnDelete (Just deleteToolIcon) compactTools
            ])
        , highlightWrap config.theme (config.tutorialHighlightGroup == Just "files") (btnGroup config.theme
            [ iconTextBtn config.theme exportIcon t.export config.onExport False t.exportTooltip compactFiles
            , iconTextBtn config.theme saveIcon t.save config.onSave False t.saveTooltip compactFiles
            , iconTextBtn config.theme loadIcon t.load config.onLoad False t.loadTooltip compactFiles
            , iconTextBtn config.theme shareIcon t.shareViaUrl config.onShare False t.shareViaUrlTooltip compactFiles
            ])
        , div
            [ style "width" "1px"
            , style "height" "24px"
            , style "background-color" config.theme.overlayLight20
            , style "margin" "0 4px"
            ]
            []
        , highlightWrap config.theme (config.tutorialHighlightGroup == Just "convert") (div [ style "display" "flex", style "gap" "8px", style "align-items" "center" ]
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
         , style "color" (if config.isAddDeadStateEnabled then config.theme.textOnDark else config.theme.btnDisabledText)
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
            , style "background-color" config.theme.overlayLight25
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
            , style "color" config.theme.textOnDark
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
                , style "box-shadow" ("0 4px 16px " ++ config.theme.overlayDark50)
                ]
                [ div
                    [ style "color" config.theme.textOnDark
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
                    [ div [ style "color" config.theme.mutedContrastText, style "font-size" "13px" ]
                        [ text t.darkMode ]
                    , pillToggle config.theme config.onToggleDarkMode config.darkMode
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
                    [ div [ style "color" config.theme.mutedContrastText, style "font-size" "13px" ]
                        [ text t.language ]
                    , languageToggleBtn config.theme t config.onToggleLanguage
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
                    [ div [ style "color" config.theme.mutedContrastText, style "font-size" "13px" ]
                        [ text t.gridMode ]
                    , pillToggle config.theme config.onToggleGridMode config.gridMode
                    ]
                ]
          else
            text ""
        ]


pillToggle : Theme.Theme -> msg -> Bool -> Html msg
pillToggle theme onToggle isOn =
    div
        [ onClick onToggle
        , style "width" "40px"
        , style "height" "20px"
        , style "border-radius" "10px"
        , style "background-color" (if isOn then theme.toggleOnBg else theme.toggleOffBg)
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
            , style "background-color" theme.colorWhite
            , style "transition" "left 0.2s"
            ]
            []
        ]


languageToggleBtn : Theme.Theme -> Translations.Translations -> msg -> Html msg
languageToggleBtn theme t onToggle =
    button
        [ onClick onToggle
        , style "background" theme.btnSecondaryBg
        , style "color" theme.textOnDark
        , style "border" "none"
        , style "border-radius" "4px"
        , style "padding" "2px 8px"
        , style "font-size" "12px"
        , style "cursor" "pointer"
        ]
        [ text t.languageName ]


highlightWrap : Theme.Theme -> Bool -> Html msg -> Html msg
highlightWrap theme isHighlighted inner =
    if isHighlighted then
        div
            [ style "position" "relative"
            , style "z-index" "501"
            , style "box-shadow" theme.yellowGlowShadow
            , style "border-radius" "6px"
            ]
            [ inner ]
    else
        inner


btnGroup : Theme.Theme -> List (Html msg) -> Html msg
btnGroup theme children =
    div
        [ style "display" "flex"
        , style "flex-direction" "row"
        , style "gap" "3px"
        , style "background-color" theme.overlayDark25
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
        , style "color" (if isDisabled then theme.btnDisabledText else theme.textOnDark)
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
        , style "color" (if isDisabled then theme.btnDisabledText else theme.textOnDark)
        , style "border" "none"
        , style "border-radius" "4px"
        , style "cursor" (if isDisabled then "not-allowed" else "pointer")
        , style "display" "flex"
        , style "align-items" "center"
        , HA.disabled isDisabled
        , HA.title tipText
        ]
        [ icon ]


toolBtn : Theme.Theme -> String -> msg -> Bool -> String -> String -> Maybe (Html msg) -> Bool -> Html msg
toolBtn theme label onClickMsg isActive shortcut activeColor maybeIcon compact =
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
        , style "color" theme.textOnDark
        , style "border" "none"
        , style "border-radius" "4px"
        , style "cursor" "pointer"
        , style "font-size" "14px"
        , style "font-weight" (if isActive then "bold" else "normal")
        , style "display" "flex"
        , style "align-items" "center"
        , style "gap" "6px"
        , HA.title (label ++ " (" ++ shortcut ++ ")")
        ]
        (case ( compact, maybeIcon ) of
            ( True, Just icon ) ->
                [ icon ]

            _ ->
                [ text displayLabel ]
        )


iconTextBtn : Theme.Theme -> Html msg -> String -> msg -> Bool -> String -> Bool -> Html msg
iconTextBtn theme icon label onClickMsg isDisabled tipText compact =
    button
        [ onClick onClickMsg
        , HA.class "elm-btn"
        , style "padding" "10px 14px"
        , style "background-color" (if isDisabled then theme.btnDisabledBg else theme.btnSecondaryBg)
        , style "color" (if isDisabled then theme.btnDisabledText else theme.textOnDark)
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
        (if compact then
            [ icon ]
         else
            [ icon, Html.span [ HA.class "toolbar-btn-label" ] [ text label ] ]
        )


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


buildToolIcon : Html msg
buildToolIcon =
    Html.img [ HA.src "icons/build.svg", HA.width 18, HA.height 18 ] []


deleteToolIcon : Html msg
deleteToolIcon =
    Html.img [ HA.src "icons/delete.svg", HA.width 18, HA.height 18 ] []


guideButton : Theme.Theme -> String -> msg -> Html msg
guideButton theme label onClickMsg =
    button
        [ onClick onClickMsg
        , HA.class "elm-btn"
        , style "padding" "11px 18px"
        , style "background-color" theme.btnGuide
        , style "color" theme.textOnDark
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
        , style "color" (if isEnabled then theme.textOnDark else theme.btnDisabledText)
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
                , style "box-shadow" theme.yellowGlowShadow
                ]
            else
                []
           )
        )
        [ text label ]
