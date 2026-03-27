module Components.Console exposing (view, Message, MessageType(..))

import Html exposing (Html, div, text, p, span)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
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
        , style "border-top" ("2px solid " ++ config.theme.strongBorderColor)
        ]
        [ div
            [ style "background-color" config.theme.consoleHeaderBg
            , style "color" config.theme.consoleText
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
                [ Html.img
                    [ Html.Attributes.src "icons/double_arrow_svg.svg"
                    , style "width" "14px"
                    , style "height" "14px"
                    , style "opacity" "0.8"
                    , style "transform" (if config.isOpen then "rotate(0deg)" else "rotate(180deg)")
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
                (List.map (viewMessage config.theme config.onLinkClick) config.messages)

          else
            div [] []
        ]


viewMessage : Theme.Theme -> Maybe msg -> Message -> Html msg
viewMessage theme maybeOnLinkClick message =
    let
        borderColor =
            case message.msgType of
                Info ->
                    theme.infoColor

                Error ->
                    theme.activeEdgeColor

                InfoLink _ ->
                    theme.infoColor
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
                            , style "color" theme.modalSectionTitle
                            , style "cursor" "pointer"
                            , style "text-decoration" "underline"
                            ]
                            [ text linkLabel ]

                    Nothing ->
                        span [ style "color" theme.modalSectionTitle ] [ text linkLabel ]
                ]

        _ ->
            p
                [ style "margin" "2px 0"
                , style "padding" "2px 5px"
                , style "border-left" ("3px solid " ++ borderColor)
                ]
                [ text message.text ]
