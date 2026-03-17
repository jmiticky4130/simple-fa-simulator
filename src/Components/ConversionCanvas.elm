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
import Utils.Theme as Theme


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
    , theme : Theme.Theme
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
        , style "background-color" config.theme.canvasBg
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
                (List.map (viewDfaEdge config.theme config.dfaTransitions config.dfaStates config.highlightTransition) grouped
                    ++ List.map (viewDfaState config.theme config.onStateMouseDown config.highlightDfaStateId config.newlyCreatedId config.processedIds) config.dfaStates
                )
            ]
        , zoomControls config.theme config.onZoomIn config.onZoomOut
        ]


zoomControls : Theme.Theme -> msg -> msg -> Html msg
zoomControls theme onZoomIn onZoomOut =
    div
        [ style "position" "absolute"
        , style "bottom" "16px"
        , style "right" "16px"
        , style "display" "flex"
        , style "flex-direction" "column"
        , style "gap" "4px"
        ]
        [ zoomBtn theme "+" onZoomIn
        , zoomBtn theme "-" onZoomOut
        ]


zoomBtn : Theme.Theme -> String -> msg -> Html msg
zoomBtn theme label msg =
    button
        [ onClick msg
        , style "width" "32px"
        , style "height" "32px"
        , style "font-size" "18px"
        , style "font-weight" "bold"
        , style "background-color" theme.btnSecondaryBg
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


viewDfaEdge : Theme.Theme -> List DfaSubsetTransition -> List DfaSubsetState -> Maybe { fromId : Int, toId : Int, symbol : String } -> { from : Int, to : Int, symbols : List String } -> Svg msg
viewDfaEdge theme allTransitions allStates highlightTransition grouped =
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
                viewSelfLoop theme a grouped.symbols isActive
            else if hasReverse then
                viewCurvedEdge theme a b grouped.symbols isActive
            else
                viewStraightEdge theme a b grouped.symbols isActive

        _ ->
            Svg.g [] []


viewStraightEdge : Theme.Theme -> DfaSubsetState -> DfaSubsetState -> List String -> Bool -> Svg msg
viewStraightEdge theme a b symbols isActive =
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
            if isActive then "#e74c3c" else theme.edgeColor

        strokeWidth =
            if isActive then "4" else "2"

        midX =
            (sx + ex) / 2

        midY =
            (sy + ey) / 2

        angleRad =
            atan2 uy ux

        angleDeg =
            angleRad * 180 / pi

        rotationAngle =
            if ux < 0 then angleDeg + 180 else angleDeg

        n =
            List.length symbols

        spacing =
            16

        labels =
            [ Svg.g
                [ SA.transform
                    ("translate(" ++ String.fromFloat midX ++ "," ++ String.fromFloat midY
                        ++ ") rotate(" ++ String.fromFloat rotationAngle ++ ")")
                ]
                (List.indexedMap
                    (\i sym ->
                        Svg.text_
                            [ SA.x (String.fromFloat ((toFloat i - toFloat (n - 1) / 2.0) * toFloat spacing))
                            , SA.y "-6"
                            , SA.textAnchor "middle"
                            , SA.fontSize "13"
                            , SA.fill strokeColor
                            , SA.fontWeight "bold"
                            , SA.style "user-select: none; pointer-events: none;"
                            ]
                            [ Svg.text sym ]
                    )
                    symbols
                )
            ]
    in
    Svg.g []
        ([ Svg.path
            [ SA.d ("M " ++ String.fromFloat sx ++ " " ++ String.fromFloat sy ++ " L " ++ String.fromFloat ex ++ " " ++ String.fromFloat ey)
            , SA.fill "none"
            , SA.stroke strokeColor
            , SA.strokeWidth strokeWidth
            ]
            []
        , Svg.polygon [ SA.points arrowPts, SA.fill strokeColor ] []
        ]
            ++ labels
        )


viewCurvedEdge : Theme.Theme -> DfaSubsetState -> DfaSubsetState -> List String -> Bool -> Svg msg
viewCurvedEdge theme a b symbols isActive =
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
            if isActive then "#e74c3c" else theme.edgeColor

        strokeWidth =
            if isActive then "4" else "2"

        curveMidX =
            0.25 * sx + 0.5 * cx + 0.25 * ex

        curveMidY =
            0.25 * sy + 0.5 * cy + 0.25 * ey

        angleRad =
            atan2 uy ux

        angleDeg =
            angleRad * 180 / pi

        rotationAngle =
            if ux < 0 then angleDeg + 180 else angleDeg

        n =
            List.length symbols

        spacing =
            16

        labels =
            [ Svg.g
                [ SA.transform
                    ("translate(" ++ String.fromFloat curveMidX ++ "," ++ String.fromFloat curveMidY
                        ++ ") rotate(" ++ String.fromFloat rotationAngle ++ ")")
                ]
                (List.indexedMap
                    (\i sym ->
                        Svg.text_
                            [ SA.x (String.fromFloat ((toFloat i - toFloat (n - 1) / 2.0) * toFloat spacing))
                            , SA.y "-6"
                            , SA.textAnchor "middle"
                            , SA.fontSize "13"
                            , SA.fill strokeColor
                            , SA.fontWeight "bold"
                            , SA.style "user-select: none; pointer-events: none;"
                            ]
                            [ Svg.text sym ]
                    )
                    symbols
                )
            ]
    in
    Svg.g []
        ([ Svg.path
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
        ]
            ++ labels
        )


viewSelfLoop : Theme.Theme -> DfaSubsetState -> List String -> Bool -> Svg msg
viewSelfLoop theme state symbols isActive =
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
            if isActive then "#e74c3c" else theme.edgeColor

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


viewDfaState : Theme.Theme -> (Int -> Float -> Float -> msg) -> Maybe Int -> Maybe Int -> List Int -> DfaSubsetState -> Svg msg
viewDfaState theme onStateMouseDown highlightId newlyCreatedId processedIds state =
    let
        isHighlighted =
            highlightId == Just state.id

        fillColor =
            if newlyCreatedId == Just state.id then
                "#b3e5fc"
            else if List.member state.id processedIds then
                "#cfd8dc"
            else
                theme.stateFill

        borderColor =
            if isHighlighted then "#f57f17" else theme.stateBorder

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
                    , SA.fill theme.stateText
                    , SA.fontWeight "bold"
                    , SA.style "user-select: none; pointer-events: none;"
                    ]
                    [ Svg.text state.label ]
               ]
            ++ startArrow theme state r
        )


startArrow : Theme.Theme -> DfaSubsetState -> Int -> List (Svg msg)
startArrow theme state r =
    if not state.isStart then
        []

    else
        let
            labelOverflows = String.length state.label * 7 > 60
            contactAngle = if labelOverflows then degrees 150 else degrees 180
            tipX = state.x + toFloat r * cos contactAngle
            tipY = state.y + toFloat r * sin contactAngle
            lineX1 = state.x + (toFloat r + 40) * cos contactAngle
            lineY1 = state.y + (toFloat r + 40) * sin contactAngle
            baseX = tipX + 10 * cos contactAngle
            baseY = tipY + 10 * sin contactAngle
            perpX = -(sin contactAngle)
            perpY = cos contactAngle
            leftX = baseX + 5 * perpX
            leftY = baseY + 5 * perpY
            rightX = baseX - 5 * perpX
            rightY = baseY - 5 * perpY
            pts =
                String.join " "
                    [ String.fromFloat tipX ++ "," ++ String.fromFloat tipY
                    , String.fromFloat leftX ++ "," ++ String.fromFloat leftY
                    , String.fromFloat rightX ++ "," ++ String.fromFloat rightY
                    ]
        in
        [ Svg.line
            [ SA.x1 (String.fromFloat lineX1)
            , SA.y1 (String.fromFloat lineY1)
            , SA.x2 (String.fromFloat tipX)
            , SA.y2 (String.fromFloat tipY)
            , SA.stroke theme.edgeColor
            , SA.strokeWidth "2"
            ]
            []
        , Svg.polygon [ SA.points pts, SA.fill theme.edgeColor ] []
        ]
