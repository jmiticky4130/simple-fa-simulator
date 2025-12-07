module Components.Toolbar exposing (view)

import Html exposing (Html, div, button, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)


type alias Config msg =
    { onResetTool : msg
    , onAddStateTool : msg
    , onAddTransitionTool : msg
    , onDeleteTool : msg
    , onMoveTool : msg
    , onRenameTool : msg
    , onSetStartStateTool : msg
    , onSetEndStateTool : msg
    , onUndo : msg
    , onRedo : msg
    , onSwitchToSimulator : msg
    , canUndo : Bool
    , canRedo : Bool
    , currentTool : String
    , isSimulateEnabled : Bool
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
        [ toolButton "Reset" "ResetTool" config.onResetTool False
        , undoRedoButton "<-" config.onUndo config.canUndo
        , undoRedoButton "->" config.onRedo config.canRedo
        , toolButton "Pridať stav" "AddStateTool" config.onAddStateTool (config.currentTool == "AddStateTool")
        , toolButton "Pridať prechod" "AddTransitionTool" config.onAddTransitionTool (config.currentTool == "AddTransitionTool")
        , toolButton "Odstrániť" "DeleteTool" config.onDeleteTool (config.currentTool == "DeleteTool")
        , toolButton "Posunúť" "MoveTool" config.onMoveTool (config.currentTool == "MoveTool")
        , toolButton "Premenovať" "RenameTool" config.onRenameTool (config.currentTool == "RenameTool")
        , toolButton "Počiatočný stav" "SetStartStateTool" config.onSetStartStateTool (config.currentTool == "SetStartStateTool")
        , toolButton "Koncový stav" "SetEndStateTool" config.onSetEndStateTool (config.currentTool == "SetEndStateTool")
        , actionButton "Simulovať" config.onSwitchToSimulator config.isSimulateEnabled "#27ae60"
        ]


actionButton : String -> msg -> Bool -> String -> Html msg
actionButton label onClickMsg isEnabled bgColor =
    button
        [ onClick onClickMsg
        , style "padding" "10px 20px"
        , style "background-color" (if isEnabled then bgColor else "#95a5a6")
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


undoRedoButton : String -> msg -> Bool -> Html msg
undoRedoButton label onClickMsg isEnabled =
    button
        [ onClick onClickMsg
        , style "padding" "10px 20px"
        , style "background-color" (if isEnabled then "#34495e" else "#7f8c8d")
        , style "color" (if isEnabled then "white" else "#bdc3c7")
        , style "border" "none"
        , style "border-radius" "5px"
        , style "cursor" (if isEnabled then "pointer" else "not-allowed")
        , Html.Attributes.disabled (not isEnabled)
        ]
        [ text label ]


toolButton : String -> String -> msg -> Bool -> Html msg
toolButton label _ onClickMsg isActive =
    button
        [ onClick onClickMsg
        , style "padding" "10px 20px"
        , style "background-color" (if isActive then "#3498db" else "#34495e")
        , style "color" "white"
        , style "border" "none"
        , style "border-radius" "5px"
        , style "cursor" "pointer"
        , style "font-size" "14px"
        , style "font-weight" (if isActive then "bold" else "normal")
        , style "transition" "all 0.3s"
        ]
        [ text label ]
