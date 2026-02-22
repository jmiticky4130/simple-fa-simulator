module Components.ConversionCanvas exposing (Config, view)

import Html exposing (Html, div, button, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Json.Decode as Decode
import Svg exposing (Svg)
import Svg.Attributes as SA
import Svg.Events as SE
import Utils.AutomatonHelpers exposing (calculateArrowHead)
import Utils.ConversionHelpers exposing (DfaSubsetState, DfaSubsetTransition)


type alias Config msg =
    { dfaStates : List DfaSubsetState
    , dfaTransitions : List DfaSubsetTransition
    , processedIds : List Int
    , newlyCreatedId : Maybe Int
    , highlightDfaStateId : Maybe Int
    , highlightTransition : Maybe { fromId : Int, toId : Int, symbol : String }
    , panX : Float
    , panY : Float
    , zoom : Float
    , onMouseDown : Float -> Float -> msg
    , onDragMove : Float -> Float -> msg
    , onEndDrag : msg
    , onZoomIn : msg
    , onZoomOut : msg
    , onWheel : Float -> Float -> Float -> msg
    , onStateMouseDown : Int -> Float -> Float -> msg
    }


view : Config msg -> Html msg
view config =
    let
        grouped =
            groupDfaTransitions config.dfaTransitions
    in
    div
        [ style "flex" "1"
        , style "overflow" "hidden"
        , style "background-color" "#ecf0f1"
        , style "position" "relative"
        , style "user-select" "none"
        ]
        [ Svg.svg
            [ SA.width "100%"
            , SA.height "100%"
            , SE.on "mousedown" (Decode.map2 config.onMouseDown offsetX offsetY)
            , SE.on "mousemove" (Decode.map2 config.onDragMove offsetX offsetY)
            , SE.on "mouseup" (Decode.succeed config.onEndDrag)
            , SE.on "mouseleave" (Decode.succeed config.onEndDrag)
            , SE.on "wheel" (Decode.map3 config.onWheel wheelDeltaY offsetX offsetY)
            ]
            [ Svg.g
                [ SA.transform
                    ("translate("
                        ++ String.fromFloat config.panX
                        ++ ","
                        ++ String.fromFloat config.panY
                        ++ ") scale("
                        ++ String.fromFloat config.zoom
                        ++ ")"
                    )
                ]
                (List.map (viewDfaEdge config.dfaTransitions config.dfaStates config.highlightTransition) grouped
                    ++ List.map (viewDfaState config.onStateMouseDown config.highlightDfaStateId config.newlyCreatedId config.processedIds) config.dfaStates
                )
            ]
        , zoomControls config.onZoomIn config.onZoomOut
        ]


zoomControls : msg -> msg -> Html msg
zoomControls onZoomIn onZoomOut =
    div
        [ style "position" "absolute"
        , style "bottom" "16px"
        , style "right" "16px"
        , style "display" "flex"
        , style "flex-direction" "column"
        , style "gap" "4px"
        ]
        [ zoomBtn "+" onZoomIn
        , zoomBtn "−" onZoomOut
        ]


zoomBtn : String -> msg -> Html msg
zoomBtn label msg =
    button
        [ onClick msg
        , style "width" "32px"
        , style "height" "32px"
        , style "font-size" "18px"
        , style "font-weight" "bold"
        , style "background-color" "#546e7a"
        , style "color" "white"
        , style "border" "none"
        , style "border-radius" "4px"
        , style "cursor" "pointer"
        , style "line-height" "1"
        ]
        [ text label ]


-- DECODERS


offsetX : Decode.Decoder Float
offsetX =
    Decode.field "offsetX" Decode.float


offsetY : Decode.Decoder Float
offsetY =
    Decode.field "offsetY" Decode.float


wheelDeltaY : Decode.Decoder Float
wheelDeltaY =
    Decode.field "deltaY" Decode.float


-- TRANSITION GROUPING


groupDfaTransitions : List DfaSubsetTransition -> List { from : Int, to : Int, symbols : List String }
groupDfaTransitions transitions =
    List.foldl
        (\t acc ->
            case List.filter (\g -> g.from == t.from && g.to == t.to) acc |> List.head of
                Just _ ->
                    List.map
                        (\g ->
                            if g.from == t.from && g.to == t.to then
                                { g | symbols = g.symbols ++ [ t.symbol ] }
                            else
                                g
                        )
                        acc

                Nothing ->
                    acc ++ [ { from = t.from, to = t.to, symbols = [ t.symbol ] } ]
        )
        []
        transitions


-- EDGE RENDERING


viewDfaEdge : List DfaSubsetTransition -> List DfaSubsetState -> Maybe { fromId : Int, toId : Int, symbol : String } -> { from : Int, to : Int, symbols : List String } -> Svg msg
viewDfaEdge allTransitions allStates highlightTransition grouped =
    let
        maybeA =
            List.filter (\s -> s.id == grouped.from) allStates |> List.head

        maybeB =
            List.filter (\s -> s.id == grouped.to) allStates |> List.head

        isActive =
            case highlightTransition of
                Just ht ->
                    ht.fromId == grouped.from && ht.toId == grouped.to

                Nothing ->
                    False

        hasReverse =
            List.any (\t -> t.from == grouped.to && t.to == grouped.from) allTransitions
    in
    case ( maybeA, maybeB ) of
        ( Just a, Just b ) ->
            if a.id == b.id then
                viewSelfLoop a grouped.symbols isActive
            else if hasReverse then
                viewCurvedEdge a b grouped.symbols isActive
            else
                viewStraightEdge a b grouped.symbols isActive

        _ ->
            Svg.g [] []


viewStraightEdge : DfaSubsetState -> DfaSubsetState -> List String -> Bool -> Svg msg
viewStraightEdge a b symbols isActive =
    let
        r =
            35.0

        vx =
            b.x - a.x

        vy =
            b.y - a.y

        len =
            sqrt (vx * vx + vy * vy)

        ux =
            if len == 0 then 1 else vx / len

        uy =
            if len == 0 then 0 else vy / len

        sx =
            a.x + ux * r

        sy =
            a.y + uy * r

        ex =
            b.x - ux * r

        ey =
            b.y - uy * r

        arrowPts =
            calculateArrowHead ex ey ux uy

        strokeColor =
            if isActive then "#e74c3c" else "#222"

        strokeWidth =
            if isActive then "4" else "2"
    in
    Svg.g []
        [ Svg.path
            [ SA.d ("M " ++ String.fromFloat sx ++ " " ++ String.fromFloat sy ++ " L " ++ String.fromFloat ex ++ " " ++ String.fromFloat ey)
            , SA.fill "none"
            , SA.stroke strokeColor
            , SA.strokeWidth strokeWidth
            ]
            []
        , Svg.polygon [ SA.points arrowPts, SA.fill strokeColor ] []
        , edgeLabel ((sx + ex) / 2) ((sy + ey) / 2 - 8) (String.join "," symbols) strokeColor
        ]


viewCurvedEdge : DfaSubsetState -> DfaSubsetState -> List String -> Bool -> Svg msg
viewCurvedEdge a b symbols isActive =
    let
        r =
            35.0

        vx =
            b.x - a.x

        vy =
            b.y - a.y

        len =
            sqrt (vx * vx + vy * vy)

        ux =
            if len == 0 then 1 else vx / len

        uy =
            if len == 0 then 0 else vy / len

        px =
            -uy

        py =
            ux

        midX =
            (a.x + b.x) / 2

        midY =
            (a.y + b.y) / 2

        cx =
            midX + 40.0 * px

        cy =
            midY + 40.0 * py

        acLen =
            sqrt ((cx - a.x) ^ 2 + (cy - a.y) ^ 2)

        acUx =
            if acLen == 0 then 1 else (cx - a.x) / acLen

        acUy =
            if acLen == 0 then 0 else (cy - a.y) / acLen

        sx =
            a.x + acUx * r

        sy =
            a.y + acUy * r

        bcLen =
            sqrt ((cx - b.x) ^ 2 + (cy - b.y) ^ 2)

        bcUx =
            if bcLen == 0 then 1 else (cx - b.x) / bcLen

        bcUy =
            if bcLen == 0 then 0 else (cy - b.y) / bcLen

        ex =
            b.x + bcUx * r

        ey =
            b.y + bcUy * r

        tLen =
            sqrt ((ex - cx) ^ 2 + (ey - cy) ^ 2)

        tUx =
            if tLen == 0 then 1 else (ex - cx) / tLen

        tUy =
            if tLen == 0 then 0 else (ey - cy) / tLen

        arrowPts =
            calculateArrowHead ex ey tUx tUy

        strokeColor =
            if isActive then "#e74c3c" else "#222"

        strokeWidth =
            if isActive then "4" else "2"

        labelX =
            0.25 * sx + 0.5 * cx + 0.25 * ex

        labelY =
            0.25 * sy + 0.5 * cy + 0.25 * ey - 8
    in
    Svg.g []
        [ Svg.path
            [ SA.d
                ("M " ++ String.fromFloat sx ++ " " ++ String.fromFloat sy
                    ++ " Q " ++ String.fromFloat cx ++ " " ++ String.fromFloat cy
                    ++ " " ++ String.fromFloat ex ++ " " ++ String.fromFloat ey
                )
            , SA.fill "none"
            , SA.stroke strokeColor
            , SA.strokeWidth strokeWidth
            ]
            []
        , Svg.polygon [ SA.points arrowPts, SA.fill strokeColor ] []
        , edgeLabel labelX labelY (String.join "," symbols) strokeColor
        ]


viewSelfLoop : DfaSubsetState -> List String -> Bool -> Svg msg
viewSelfLoop state symbols isActive =
    let
        r =
            35

        loopHeight =
            55.0

        sx =
            state.x + toFloat r * cos (degrees -150)

        sy =
            state.y + toFloat r * sin (degrees -150)

        ex =
            state.x + toFloat r * cos (degrees -30)

        ey =
            state.y + toFloat r * sin (degrees -30)

        c1x =
            sx

        c1y =
            sy - loopHeight

        c2x =
            ex

        c2y =
            ey - loopHeight

        vLen =
            sqrt ((ex - c2x) ^ 2 + (ey - c2y) ^ 2)

        ux =
            if vLen == 0 then 1 else (ex - c2x) / vLen

        uy =
            if vLen == 0 then 0 else (ey - c2y) / vLen

        arrowPts =
            calculateArrowHead ex ey ux uy

        strokeColor =
            if isActive then "#e74c3c" else "#222"

        strokeWidth =
            if isActive then "4" else "2"
    in
    Svg.g []
        [ Svg.path
            [ SA.d
                ("M " ++ String.fromFloat sx ++ " " ++ String.fromFloat sy
                    ++ " C " ++ String.fromFloat c1x ++ " " ++ String.fromFloat c1y ++ ", "
                    ++ String.fromFloat c2x ++ " " ++ String.fromFloat c2y ++ ", "
                    ++ String.fromFloat ex ++ " " ++ String.fromFloat ey
                )
            , SA.fill "none"
            , SA.stroke strokeColor
            , SA.strokeWidth strokeWidth
            , SA.strokeLinecap "round"
            ]
            []
        , Svg.polygon [ SA.points arrowPts, SA.fill strokeColor ] []
        , edgeLabel state.x (state.y - toFloat r - loopHeight + 5) (String.join "," symbols) strokeColor
        ]


edgeLabel : Float -> Float -> String -> String -> Svg msg
edgeLabel x y label color =
    Svg.text_
        [ SA.x (String.fromFloat x)
        , SA.y (String.fromFloat y)
        , SA.textAnchor "middle"
        , SA.fontSize "13"
        , SA.fill color
        , SA.fontWeight "bold"
        , SA.style "user-select: none; pointer-events: none;"
        ]
        [ Svg.text label ]


-- STATE RENDERING


viewDfaState : (Int -> Float -> Float -> msg) -> Maybe Int -> Maybe Int -> List Int -> DfaSubsetState -> Svg msg
viewDfaState onStateMouseDown highlightId newlyCreatedId processedIds state =
    let
        isHighlighted =
            highlightId == Just state.id

        fillColor =
            if newlyCreatedId == Just state.id then
                "#b3e5fc"
            else if List.member state.id processedIds then
                "#cfd8dc"
            else
                "#ffffff"

        borderColor =
            if isHighlighted then "#f57f17" else "#455a64"

        borderWidth =
            if isHighlighted then "3" else "2"

        r =
            35
    in
    Svg.g
        [ SE.custom "mousedown"
            (Decode.map2
                (\x y ->
                    { message = onStateMouseDown state.id x y
                    , stopPropagation = True
                    , preventDefault = False
                    }
                )
                offsetX
                offsetY
            )
        , SA.style "cursor: move;"
        ]
        ([ Svg.circle
            [ SA.cx (String.fromFloat state.x)
            , SA.cy (String.fromFloat state.y)
            , SA.r (String.fromInt r)
            , SA.fill fillColor
            , SA.stroke borderColor
            , SA.strokeWidth borderWidth
            ]
            []
         ]
            ++ (if state.isEnd then
                    [ Svg.circle
                        [ SA.cx (String.fromFloat state.x)
                        , SA.cy (String.fromFloat state.y)
                        , SA.r (String.fromInt (r - 5))
                        , SA.fill "none"
                        , SA.stroke borderColor
                        , SA.strokeWidth borderWidth
                        ]
                        []
                    ]

                else
                    []
               )
            ++ [ Svg.text_
                    [ SA.x (String.fromFloat state.x)
                    , SA.y (String.fromFloat (state.y + 4))
                    , SA.textAnchor "middle"
                    , SA.fontSize "11"
                    , SA.fill "#000"
                    , SA.fontWeight "bold"
                    , SA.style "user-select: none; pointer-events: none;"
                    ]
                    [ Svg.text state.label ]
               ]
            ++ startArrow state r
        )


startArrow : DfaSubsetState -> Int -> List (Svg msg)
startArrow state r =
    if not state.isStart then
        []

    else
        let
            lineX1 =
                state.x - toFloat r - 40

            lineY =
                state.y

            lineX2 =
                state.x - toFloat r

            pts =
                String.join " "
                    [ String.fromFloat lineX2 ++ "," ++ String.fromFloat lineY
                    , String.fromFloat (lineX2 - 10) ++ "," ++ String.fromFloat (lineY - 5)
                    , String.fromFloat (lineX2 - 10) ++ "," ++ String.fromFloat (lineY + 5)
                    ]
        in
        [ Svg.line
            [ SA.x1 (String.fromFloat lineX1)
            , SA.y1 (String.fromFloat lineY)
            , SA.x2 (String.fromFloat lineX2)
            , SA.y2 (String.fromFloat lineY)
            , SA.stroke "black"
            , SA.strokeWidth "2"
            ]
            []
        , Svg.polygon [ SA.points pts, SA.fill "black" ] []
        ]
