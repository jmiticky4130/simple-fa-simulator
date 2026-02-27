module Components.Toolbar exposing (view)

import Html exposing (Html, div, button, text, img)
import Html.Attributes as HA exposing (style)
import Html.Events exposing (onClick)
import Svg
import Svg.Attributes as SA


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
    }


toolbarBg : String -> String
toolbarBg tool =
    case tool of
        "BuildTool" ->
            "#1a2f4a"

        "DeleteTool" ->
            "#4a1a1a"

        _ ->
            "#1a2f4a"


view : Config msg -> Html msg
view config =
    div
        [ style "display" "flex"
        , style "flex-direction" "row"
        , style "padding" "14px 12px"
        , style "background-color" (toolbarBg config.currentTool)
        , style "gap" "10px"
        , style "border-bottom" "2px solid #263238"
        , style "align-items" "center"
        , style "transition" "background-color 0.25s"
        ]
        [ btnGroup
            [ tooltipBtn "Reset" config.onResetTool False "Reset"
            , iconBtn undoIcon config.onUndo (not config.canUndo) "Späť (Ctrl+Z)"
            , iconBtn redoIcon config.onRedo (not config.canRedo) "Dopredu (Ctrl+Y)"
            ]
        , btnGroup
            [ toolBtn "Stavať" config.onBuildTool (config.currentTool == "BuildTool") "Shift+B" "#1565c0"
            , toolBtn "Odstrániť" config.onDeleteTool (config.currentTool == "DeleteTool") "Shift+D" "#c62828"
            ]
        , btnGroup
            [ tooltipBtn "Export" config.onExport False "Exportovať"
            , tooltipBtn "Uložiť" config.onSave False "Uložiť lokálne"
            , tooltipBtn "Načítať" config.onLoad False "Načítať lokálne"
            , tooltipBtn "Zdieľať cez URL" config.onShare False "Zdieľať cez URL"
            ]
        , div
            [ style "width" "1px"
            , style "height" "24px"
            , style "background-color" "rgba(255,255,255,0.2)"
            , style "margin" "0 4px"
            ]
            []
        , actionButton "NFA→DFA" config.onSwitchToConversion config.isConvertEnabled config.convertDisabledReason (Just config.onConvertDisabledClick) "#6a1b9a"
        , div [ style "flex" "1" ] []
        , div
            [ style "width" "300px"
            , style "display" "flex"
            , style "justify-content" "flex-end"
            , style "gap" "8px"
            ]
            [ guideButton config.onShowGuide
            , actionButton "Simulovať" config.onSwitchToSimulator config.isSimulateEnabled config.simulateDisabledReason (Just config.onSimulateDisabledClick) "#0277bd"
            ]
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


tooltipBtn : String -> msg -> Bool -> String -> Html msg
tooltipBtn label onClickMsg isDisabled tipText =
    button
        [ onClick onClickMsg
        , HA.class "elm-btn"
        , style "padding" "10px 14px"
        , style "background-color" (if isDisabled then "#78909c" else "#546e7a")
        , style "color" (if isDisabled then "#b0bec5" else "white")
        , style "border" "none"
        , style "border-radius" "4px"
        , style "cursor" (if isDisabled then "not-allowed" else "pointer")
        , style "font-size" "14px"
        , HA.disabled isDisabled
        , HA.title tipText
        ]
        [ text label ]


iconBtn : Html msg -> msg -> Bool -> String -> Html msg
iconBtn icon onClickMsg isDisabled tipText =
    button
        [ onClick onClickMsg
        , HA.class "elm-btn"
        , style "padding" "10px 12px"
        , style "background-color" (if isDisabled then "#78909c" else "#546e7a")
        , style "color" (if isDisabled then "#b0bec5" else "white")
        , style "border" "none"
        , style "border-radius" "4px"
        , style "cursor" (if isDisabled then "not-allowed" else "pointer")
        , style "display" "flex"
        , style "align-items" "center"
        , HA.disabled isDisabled
        , HA.title tipText
        ]
        [ icon ]


toolBtn : String -> msg -> Bool -> String -> String -> Html msg
toolBtn label onClickMsg isActive shortcut activeColor =
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
        , style "background-color" (if isActive then activeColor else "#546e7a")
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


guideButton : msg -> Html msg
guideButton onClickMsg =
    button
        [ onClick onClickMsg
        , HA.class "elm-btn"
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
            [ HA.src "guide_icon.png"
            , style "width" "20px"
            , style "height" "20px"
            , style "filter" "brightness(0) invert(1)"
            ]
            []
        , text "Sprievodca"
        ]


actionButton : String -> msg -> Bool -> Maybe String -> Maybe msg -> String -> Html msg
actionButton label onClickMsg isEnabled disabledReason onDisabledClick bgColor =
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
        , style "background-color" (if isEnabled then bgColor else "#b0bec5")
        , style "color" "white"
        , style "border" "none"
        , style "border-radius" "5px"
        , style "cursor" (if isEnabled then "pointer" else "not-allowed")
        , style "font-size" "14px"
        , style "font-weight" "bold"
        , HA.disabled isDisabled
        , HA.title (disabledReason |> Maybe.withDefault "")
        ]
        [ text label ]
