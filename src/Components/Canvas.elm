module Components.Canvas exposing (view)

import Html exposing (Html, div, span)
import Html.Attributes exposing (style)
import Html.Attributes
import Html.Events exposing (custom)
import Json.Decode as Decode
import Svg exposing (Svg)
import Svg.Attributes as SA
import Svg.Events as SE
import Shared exposing (State, Transition)


type alias Config msg =
    { states : List State
    , transitions : List Transition
    , selectedState : Maybe Int
    , transitionFrom : Maybe Int
    , activeStateId : Maybe Int
    , activeTransition : Maybe { from : Int, to : Int, symbol : String }
    , onCanvasClick : Float -> Float -> msg
    , onStateClick : Int -> msg
    , onTransitionClick : Int -> Int -> String -> msg
    , onStartDrag : Int -> Float -> Float -> msg
    , onDragMove : Float -> Float -> msg
    , onEndDrag : msg
    , width : Float
    , height : Float
    }


view : Config msg -> Html msg
view config =
    Svg.svg
        [ SA.width "100%"
        , SA.height "100%"
        , SE.on "click" (Decode.map2 config.onCanvasClick offsetX offsetY)
        , SE.on "mousemove" (Decode.map2 config.onDragMove offsetX offsetY)
        , SE.on "mouseup" (Decode.succeed config.onEndDrag)
        ]
        (
            -- Draw edges first, then states so states appear on top
            List.map (viewGroupedTransition config) (groupTransitions config.transitions)
                ++ List.map (svgState config) config.states
        )


offsetX : Decode.Decoder Float
offsetX =
    Decode.field "offsetX" Decode.float


offsetY : Decode.Decoder Float
offsetY =
    Decode.field "offsetY" Decode.float


svgState : Config msg -> State -> Svg msg
svgState config state =
    let
        isSelected =
            config.selectedState == Just state.id

        isTransitionStart =
            config.transitionFrom == Just state.id

        isActive =
            config.activeStateId == Just state.id

        fillColor =
            if isSelected then
                "#6495ED"
            else if isTransitionStart then
                "#FFD700"
            else if isActive then
                "#90EE90" -- Light green for active state
            else
                "#E8E8E8"

        borderColor =
            if isSelected then
                "#00008B"
            else if isActive then
                "#006400" -- Dark green for active state
            else
                "#323232"

        borderWidth = 3

        r = 30
    in
    Svg.g
        [ SE.custom "click"
            (Decode.succeed
                { message = config.onStateClick state.id
                , stopPropagation = True
                , preventDefault = False
                }
            )
        , SE.on "mousedown"
            (Decode.map2 (\x y -> config.onStartDrag state.id x y) offsetX offsetY)
        ]
        ([ Svg.circle
            [ SA.cx (String.fromFloat state.x)
            , SA.cy (String.fromFloat state.y)
            , SA.r (String.fromInt r)
            , SA.fill fillColor
            , SA.stroke borderColor
            , SA.strokeWidth (String.fromInt borderWidth)
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
                        , SA.strokeWidth (String.fromInt borderWidth)
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
            , SA.fontSize "14"
            , SA.fill "#000"
            , SA.fontWeight "bold"
            , SA.style "user-select: none; pointer-events: none;"
            ]
            [ Svg.text state.label ]
        ]
            ++ (if state.isStart then
                    let
                        lineX1 = state.x - toFloat r - 40
                        lineY = state.y
                        lineX2 = state.x - toFloat r

                        -- arrow at end of start marker
                        tipX = lineX2
                        tipY = lineY
                        baseX = tipX - 10
                        baseY = tipY
                        leftX = baseX
                        leftY = baseY - 5
                        rightX = baseX
                        rightY = baseY + 5
                        pts =
                            String.join " "
                                [ String.fromFloat tipX ++ "," ++ String.fromFloat tipY
                                , String.fromFloat leftX ++ "," ++ String.fromFloat leftY
                                , String.fromFloat rightX ++ "," ++ String.fromFloat rightY
                                ]
                    in
                    [ Svg.line [ SA.x1 (String.fromFloat lineX1), SA.y1 (String.fromFloat lineY), SA.x2 (String.fromFloat lineX2), SA.y2 (String.fromFloat lineY), SA.stroke "black", SA.strokeWidth "2" ] []
                    , Svg.polygon [ SA.points pts, SA.fill "black" ] []
                    ]
               else
                    []
               )
        )


groupTransitions : List Transition -> List { from : Int, to : Int, symbols : List String }
groupTransitions transitions =
    transitions
        |> List.foldl
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


viewGroupedTransition : Config msg -> { from : Int, to : Int, symbols : List String } -> Svg msg
viewGroupedTransition config grouped =
    let
        maybeFromState =
            List.filter (\s -> s.id == grouped.from) config.states
                |> List.head

        maybeToState =
            List.filter (\s -> s.id == grouped.to) config.states
                |> List.head
        
        combinedSymbol = String.join ", " grouped.symbols

        hasReverseTransition =
            List.any (\t -> t.from == grouped.to && t.to == grouped.from) config.transitions

        isActive =
            case config.activeTransition of
                Just active ->
                    active.from == grouped.from && active.to == grouped.to && List.member active.symbol grouped.symbols
                Nothing ->
                    False
    in
    case ( maybeFromState, maybeToState ) of
        ( Just fromState, Just toState ) ->
            if fromState.id == toState.id then
                -- Self-loop with ellipse
                svgSelfLoop config fromState grouped.symbols isActive
            else
                if hasReverseTransition then
                    -- Curved edge for bidirectional transitions
                    svgCurvedEdge config fromState toState grouped.symbols isActive
                else
                    -- Normal transition
                    svgEdge config fromState toState grouped.symbols isActive

        _ ->
            Svg.g [] []


svgSelfLoop : Config msg -> State -> List String -> Bool -> Svg msg
svgSelfLoop config state symbols isActive =
    let
        r = 30
        -- Start at 10 o'clock (-150 degrees)
        startAngle = degrees -150
        -- End at 2 o'clock (-30 degrees)
        endAngle = degrees -30
        
        sx = state.x + r * cos startAngle
        sy = state.y + r * sin startAngle
        
        ex = state.x + r * cos endAngle
        ey = state.y + r * sin endAngle
        
        -- Control points: Vertical lift to create a round arch
        loopHeight = 55
        
        c1x = sx
        c1y = sy - loopHeight
        
        c2x = ex
        c2y = ey - loopHeight

        d =
            "M "
                ++ String.fromFloat sx ++ " " ++ String.fromFloat sy
                ++ " C "
                ++ String.fromFloat c1x ++ " " ++ String.fromFloat c1y ++ ", "
                ++ String.fromFloat c2x ++ " " ++ String.fromFloat c2y ++ ", "
                ++ String.fromFloat ex ++ " " ++ String.fromFloat ey

        -- arrow at end
        vx = ex - c2x
        vy = ey - c2y
        len = sqrt (vx * vx + vy * vy)
        ux = if len == 0 then 1 else vx / len
        uy = if len == 0 then 0 else vy / len
        px = -uy
        py = ux
        al = 10
        aw = 6
        tipX = ex
        tipY = ey
        baseX = tipX - al * ux
        baseY = tipY - al * uy
        leftX = baseX + (aw / 2) * px
        leftY = baseY + (aw / 2) * py
        rightX = baseX - (aw / 2) * px
        rightY = baseY - (aw / 2) * py

        arrowPts =
            String.join " "
                [ String.fromFloat tipX ++ "," ++ String.fromFloat tipY
                , String.fromFloat leftX ++ "," ++ String.fromFloat leftY
                , String.fromFloat rightX ++ "," ++ String.fromFloat rightY
                ]

        labels =
            let
                n = List.length symbols
                spacing = 16
                -- Label at the top of the loop
                labelY = state.y - r - loopHeight + 5
                startX = state.x - (toFloat (n - 1) * toFloat spacing) / 2
            in
            List.indexedMap
                (\i sym ->
                    Svg.text_
                        [ SA.x (String.fromFloat (startX + toFloat i * toFloat spacing))
                        , SA.y (String.fromFloat labelY)
                        , SA.textAnchor "middle"
                        , SA.fontSize "12"
                        , SA.fill "blue"
                        , SE.on "click" (Decode.succeed (config.onTransitionClick state.id state.id sym))
                        ]
                        [ Svg.text sym ]
                )
                symbols
        
        strokeWidth = if isActive then "4" else "2"
        strokeColor = if isActive then "#e74c3c" else "#222" -- Red if active
    in
    Svg.g []
        ([ Svg.path [ SA.d d, SA.fill "none", SA.stroke strokeColor, SA.strokeWidth strokeWidth, SA.strokeLinecap "round" ] []
         , Svg.polygon [ SA.points arrowPts, SA.fill strokeColor ] []
         ]
            ++ labels
        )


svgEdge : Config msg -> State -> State -> List String -> Bool -> Svg msg
svgEdge config a b symbols isActive =
    let
        r = 30
        vx = b.x - a.x
        vy = b.y - a.y
        len = sqrt (vx * vx + vy * vy)
        ux = if len == 0 then 1 else vx / len
        uy = if len == 0 then 0 else vy / len

        sx = a.x + ux * toFloat r
        sy = a.y + uy * toFloat r
        ex = b.x - ux * toFloat r
        ey = b.y - uy * toFloat r

        d =
            "M " ++ String.fromFloat sx ++ " " ++ String.fromFloat sy
                ++ " L " ++ String.fromFloat ex ++ " " ++ String.fromFloat ey

        -- arrow at end
        px = -uy
        py = ux
        al = 10
        aw = 6
        tipX = ex
        tipY = ey
        baseX = tipX - al * ux
        baseY = tipY - al * uy
        leftX = baseX + (aw / 2) * px
        leftY = baseY + (aw / 2) * py
        rightX = baseX - (aw / 2) * px
        rightY = baseY - (aw / 2) * py

        arrowPts =
            String.join " "
                [ String.fromFloat tipX ++ "," ++ String.fromFloat tipY
                , String.fromFloat leftX ++ "," ++ String.fromFloat leftY
                , String.fromFloat rightX ++ "," ++ String.fromFloat rightY
                ]

        n = List.length symbols
        spacing = 16
        midX = (sx + ex) / 2
        midY = (sy + ey) / 2 - 6
        startX = midX - (toFloat (n - 1) * toFloat spacing) / 2
        labels =
            List.indexedMap
                (\i sym ->
                    Svg.text_
                        [ SA.x (String.fromFloat (startX + toFloat i * toFloat spacing))
                        , SA.y (String.fromFloat midY)
                        , SA.textAnchor "middle"
                        , SA.fontSize "12"
                        , SA.fill "blue"
                        , SE.on "click" (Decode.succeed (config.onTransitionClick a.id b.id sym))
                        ]
                        [ Svg.text sym ]
                )
                symbols

        strokeWidth = if isActive then "4" else "2"
        strokeColor = if isActive then "#e74c3c" else "#222"
    in
    Svg.g []
        ([ Svg.path [ SA.d d, SA.fill "none", SA.stroke strokeColor, SA.strokeWidth strokeWidth ] []
         , Svg.polygon [ SA.points arrowPts, SA.fill strokeColor ] []
         ]
            ++ labels
        )


svgCurvedEdge : Config msg -> State -> State -> List String -> Bool -> Svg msg
svgCurvedEdge config a b symbols isActive =
    let
        r = 30
        
        -- Vector from a to b
        vx = b.x - a.x
        vy = b.y - a.y
        len = sqrt (vx * vx + vy * vy)
        
        -- Normalized vector
        ux = if len == 0 then 1 else vx / len
        uy = if len == 0 then 0 else vy / len
        
        -- Perpendicular vector (rotated 90 degrees counter-clockwise)
        px = -uy
        py = ux
        
        -- Offset for curvature
        offset = 40
        
        -- Control point
        midX = (a.x + b.x) / 2
        midY = (a.y + b.y) / 2
        cx = midX + offset * px
        cy = midY + offset * py
        
        -- Start and end points on the circle border
        -- Vector a -> c
        acX = cx - a.x
        acY = cy - a.y
        acLen = sqrt (acX * acX + acY * acY)
        acUx = acX / acLen
        acUy = acY / acLen
        
        sx = a.x + acUx * toFloat r
        sy = a.y + acUy * toFloat r
        
        -- Vector b -> c (for end point, coming from c)
        bcX = cx - b.x
        bcY = cy - b.y
        bcLen = sqrt (bcX * bcX + bcY * bcY)
        bcUx = bcX / bcLen
        bcUy = bcY / bcLen
        
        ex = b.x + bcUx * toFloat r
        ey = b.y + bcUy * toFloat r
        
        -- Path: Quadratic Bezier
        d = "M " ++ String.fromFloat sx ++ " " ++ String.fromFloat sy
            ++ " Q " ++ String.fromFloat cx ++ " " ++ String.fromFloat cy
            ++ " " ++ String.fromFloat ex ++ " " ++ String.fromFloat ey
            
        -- Arrow at end
        -- Tangent direction is vector from Control point to End point.
        tVx = ex - cx
        tVy = ey - cy
        tLen = sqrt (tVx * tVx + tVy * tVy)
        tUx = tVx / tLen
        tUy = tVy / tLen
        
        -- Arrow geometry
        al = 10
        aw = 6
        
        -- Perpendicular to tangent
        tPx = -tUy
        tPy = tUx
        
        tipX = ex
        tipY = ey
        baseX = tipX - al * tUx
        baseY = tipY - al * tUy
        leftX = baseX + (aw / 2) * tPx
        leftY = baseY + (aw / 2) * tPy
        rightX = baseX - (aw / 2) * tPx
        rightY = baseY - (aw / 2) * tPy
        
        arrowPts =
            String.join " "
                [ String.fromFloat tipX ++ "," ++ String.fromFloat tipY
                , String.fromFloat leftX ++ "," ++ String.fromFloat leftY
                , String.fromFloat rightX ++ "," ++ String.fromFloat rightY
                ]
                
        n = List.length symbols
        spacing = 16
        startX = cx - (toFloat (n - 1) * toFloat spacing) / 2
        labels =
            List.indexedMap
                (\i sym ->
                    Svg.text_
                        [ SA.x (String.fromFloat (startX + toFloat i * toFloat spacing))
                        , SA.y (String.fromFloat cy)
                        , SA.textAnchor "middle"
                        , SA.fontSize "12"
                        , SA.fill "blue"
                        , SE.on "click" (Decode.succeed (config.onTransitionClick a.id b.id sym))
                        ]
                        [ Svg.text sym ]
                )
                symbols

        strokeWidth = if isActive then "4" else "2"
        strokeColor = if isActive then "#e74c3c" else "#222"
    in
    Svg.g []
        ([ Svg.path [ SA.d d, SA.fill "none", SA.stroke strokeColor, SA.strokeWidth strokeWidth, SA.fill "none" ] []
         , Svg.polygon [ SA.points arrowPts, SA.fill strokeColor ] []
         ]
            ++ labels
        )