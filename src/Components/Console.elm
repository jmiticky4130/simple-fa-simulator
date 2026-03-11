module Components.Console exposing (view, Message, MessageType(..))

import Html exposing (Html, div, text, p, span)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Svg exposing (svg, path, g)
import Svg.Attributes as SA
import Utils.Theme as Theme
import Utils.Translations as Translations exposing (Language)


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
    , language : Language
    }


view : Config msg -> Html msg
view config =
    let
        t =
            Translations.getTranslations config.language
    in
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
            [ div [ style "flex" "0" ] [ text t.consoleTitle ]
            , div
                [ style "flex" "1"
                , style "display" "flex"
                , style "justify-content" "center"
                , style "cursor" "pointer"
                , onClick config.onToggle
                ]
                [ svg
                    [ SA.width "14"
                    , SA.height "14"
                    , SA.viewBox "0 0 24 24"
                    , SA.fill "#ffffff"
                    , SA.stroke "#ffffff"
                    , SA.strokeWidth "0.096"
                    , style "opacity" "0.8"
                    , style "transform" (if config.isOpen then "rotate(0deg)" else "rotate(180deg)")
                    , style "transition" "transform 0.2s"
                    ]
                    [ g [ SA.transform "rotate(90, 12, 12)" ]
                        [ path [ SA.d "M11,11.81a.91.91,0,0,1,0,.38,1.39,1.39,0,0,1-.06.19s0,.07,0,.11l-5,9A1,1,0,0,1,5,22a1,1,0,0,1-.49-.13,1,1,0,0,1-.38-1.36L8.86,12,4.13,3.49a1,1,0,1,1,1.74-1l5,9s0,.07,0,.11A1.39,1.39,0,0,1,11,11.81Zm9,0a1.39,1.39,0,0,0-.06-.19s0-.07,0-.11l-5-9a1,1,0,1,0-1.74,1L17.86,12l-4.73,8.51a1,1,0,0,0,.38,1.36A1,1,0,0,0,14,22a1,1,0,0,0,.87-.51l5-9s0-.07,0-.11a1.06,1.06,0,0,0,.06-.19.91.91,0,0,0,0-.38Z" ] [] ]
                    ]
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
