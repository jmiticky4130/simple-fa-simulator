module Components.Toolbar exposing (view)

import Html exposing (Html, div, button, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)


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
    , onExport : msg
    , onSave : msg
    , onLoad : msg
    , onShare : msg
    , onSwitchToConversion : msg
    , isConvertEnabled : Bool
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
        [ btn "Reset" config.onResetTool False "#546e7a"
        , btn "<-" config.onUndo (not config.canUndo) "#546e7a"
        , btn "->" config.onRedo (not config.canRedo) "#546e7a"
        , toolBtn "Stavať" config.onBuildTool (config.currentTool == "BuildTool")
        , toolBtn "Odstrániť" config.onDeleteTool (config.currentTool == "DeleteTool")
        , btn "Export" config.onExport False "#546e7a"
        , btn "Uložiť" config.onSave False "#546e7a"
        , btn "Načítať" config.onLoad False "#546e7a"
        , btn "Zdieľať cez URL" config.onShare False "#546e7a"
        , div [ style "margin-left" "auto" ] []
        , actionButton "NFA→DFA" config.onSwitchToConversion config.isConvertEnabled "#6a1b9a"
        , actionButton "Simulovať" config.onSwitchToSimulator config.isSimulateEnabled "#0277bd"
        ]


btn : String -> msg -> Bool -> String -> Html msg
btn label onClickMsg isDisabled bgColor =
    button
        [ onClick onClickMsg
        , Html.Attributes.class "elm-btn"
        , style "padding" "8px 14px"
        , style "background-color" (if isDisabled then "#b0bec5" else bgColor)
        , style "color" (if isDisabled then "#eceff1" else "white")
        , style "border" "none"
        , style "border-radius" "5px"
        , style "cursor" (if isDisabled then "not-allowed" else "pointer")
        , style "font-size" "14px"
        , Html.Attributes.disabled isDisabled
        ]
        [ text label ]


toolBtn : String -> msg -> Bool -> Html msg
toolBtn label onClickMsg isActive =
    button
        [ onClick onClickMsg
        , Html.Attributes.class "elm-btn"
        , style "padding" "8px 14px"
        , style "background-color" (if isActive then "#00897b" else "#546e7a")
        , style "color" "white"
        , style "border" "none"
        , style "border-radius" "5px"
        , style "cursor" "pointer"
        , style "font-size" "14px"
        , style "font-weight" (if isActive then "bold" else "normal")
        ]
        [ text label ]


actionButton : String -> msg -> Bool -> String -> Html msg
actionButton label onClickMsg isEnabled bgColor =
    button
        [ onClick onClickMsg
        , Html.Attributes.class "elm-btn"
        , style "padding" "8px 14px"
        , style "background-color" (if isEnabled then bgColor else "#b0bec5")
        , style "color" "white"
        , style "border" "none"
        , style "border-radius" "5px"
        , style "cursor" (if isEnabled then "pointer" else "not-allowed")
        , style "font-size" "14px"
        , style "font-weight" "bold"
        , Html.Attributes.disabled (not isEnabled)
        ]
        [ text label ]
