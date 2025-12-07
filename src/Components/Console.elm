module Components.Console exposing (view, Message, MessageType(..))

import Html exposing (Html, div, text, p)
import Html.Attributes exposing (style)


type MessageType
    = Info
    | Error


type alias Message =
    { text : String
    , msgType : MessageType
    }


type alias Config =
    { messages : List Message
    }


view : Config -> Html msg
view config =
    div
        [ style "display" "flex"
        , style "flex-direction" "column"
        , style "border-top" "2px solid #34495e"
        ]
        [ div
            [ style "background-color" "#2c3e50"
            , style "color" "#ecf0f1"
            , style "padding" "2px 10px"
            , style "font-size" "12px"
            , style "font-family" "sans-serif"
            , style "font-weight" "bold"
            ]
            [ text "Konzola" ]
        , div
            [ style "background-color" "#000000"
            , style "color" "#d4d4d4"
            , style "padding" "10px"
            , style "height" "150px"
            , style "overflow-y" "auto"
            , style "font-family" "Consolas, monospace"
            , style "font-size" "13px"
            , style "display" "flex"
            , style "flex-direction" "column-reverse"
            ]
            (List.map viewMessage config.messages)
        ]


viewMessage : Message -> Html msg
viewMessage message =
    let
        borderColor =
            case message.msgType of
                Info ->
                    "#3498db" -- Blue

                Error ->
                    "#e74c3c" -- Red
    in
    p
        [ style "margin" "2px 0"
        , style "padding" "2px 5px"
        , style "border-left" ("3px solid " ++ borderColor)
        ]
        [ text message.text ]
