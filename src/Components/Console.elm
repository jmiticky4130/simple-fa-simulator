module Components.Console exposing (view, Message, MessageType(..))

import Html exposing (Html, div, text, p, span)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Utils.Theme as Theme


type MessageType
    = Info
    | Error
    | InfoLink String


type alias Message =
    { text : String
    , msgType : MessageType
    }


type alias Config msg =
    { messages : List Message
    , isOpen : Bool
    , onToggle : msg
    , onLinkClick : Maybe msg
    , theme : Theme.Theme
    }


view : Config msg -> Html msg
view config =
    div
        [ style "display" "flex"
        , style "flex-direction" "column"
        , style "border-top" "2px solid #0d1e30"
        ]
        [ div
            [ style "background-color" config.theme.consoleHeaderBg
            , style "color" "#ecf0f1"
            , style "padding" "2px 10px"
            , style "font-size" "12px"
            , style "font-family" "sans-serif"
            , style "font-weight" "bold"
            , style "display" "flex"
            , style "align-items" "center"
            ]
            [ div [ style "flex" "0" ] [ text "Konzola" ]
            , div
                [ style "flex" "1"
                , style "display" "flex"
                , style "justify-content" "center"
                , style "cursor" "pointer"
                , onClick config.onToggle
                ]
                [ Html.img
                    [ Html.Attributes.src "transparent_double_arrow.png"
                    , style "width" "14px"
                    , style "height" "14px"
                    , style "opacity" "0.8"
                    , style "transform" (if config.isOpen then "rotate(180deg)" else "rotate(0deg)")
                    , style "transition" "transform 0.2s"
                    ]
                    []
                ]
            ]
        , if config.isOpen then
            div
                [ style "background-color" config.theme.consoleBg
                , style "color" config.theme.consoleText
                , style "padding" "10px"
                , style "height" "150px"
                , style "overflow-y" "auto"
                , style "font-family" "Consolas, monospace"
                , style "font-size" "13px"
                , style "display" "flex"
                , style "flex-direction" "column-reverse"
                ]
                (List.map (viewMessage config.onLinkClick) config.messages)

          else
            div [] []
        ]


viewMessage : Maybe msg -> Message -> Html msg
viewMessage maybeOnLinkClick message =
    let
        borderColor =
            case message.msgType of
                Info ->
                    "#3498db"

                Error ->
                    "#e74c3c"

                InfoLink _ ->
                    "#3498db"
    in
    case message.msgType of
        InfoLink linkLabel ->
            p
                [ style "margin" "2px 0"
                , style "padding" "2px 5px"
                , style "border-left" ("3px solid " ++ borderColor)
                ]
                [ text (message.text ++ " ")
                , case maybeOnLinkClick of
                    Just action ->
                        span
                            [ onClick action
                            , style "color" "#4fc3f7"
                            , style "cursor" "pointer"
                            , style "text-decoration" "underline"
                            ]
                            [ text linkLabel ]

                    Nothing ->
                        span [ style "color" "#4fc3f7" ] [ text linkLabel ]
                ]

        _ ->
            p
                [ style "margin" "2px 0"
                , style "padding" "2px 5px"
                , style "border-left" ("3px solid " ++ borderColor)
                ]
                [ text message.text ]
