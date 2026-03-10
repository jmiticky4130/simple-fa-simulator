module Components.SimulationStatus exposing (view)

import Html exposing (Html, div, span, text, h3)
import Html.Attributes exposing (style)
import Shared exposing (State)
import Utils.Theme as Theme

type alias Config =
    { inputString : String
    , remainingInput : String
    , currentState : Maybe State
    , verdict : Maybe { text : String, isAccepted : Bool }
    , theme : Theme.Theme
    }

view : Config -> Html msg
view config =
    div
        [ style "padding" "10px"
        , style "border-bottom" ("1px solid " ++ config.theme.separatorColor)
        , style "display" "flex"
        , style "flex-direction" "column"
        , style "gap" "10px"
        , style "color" config.theme.textPrimary
        ]
        [ div []
            [ span [ style "font-weight" "bold" ] [ text "Aktuálny stav: " ]
            , text (Maybe.map .label config.currentState |> Maybe.withDefault "-")
            ]
        , case config.verdict of
            Just v ->
                div
                    [ style "font-weight" "bold"
                    , style "color" (if v.isAccepted then config.theme.resultAcceptText else config.theme.resultRejectText)
                    , style "font-size" "18px"
                    , style "margin-top" "10px"
                    ]
                    [ text v.text ]
            Nothing ->
                text ""
        ]
