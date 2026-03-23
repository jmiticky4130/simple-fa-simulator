module Components.Canvas exposing (view)

import Html exposing (Html, div, span, button, text)
import Utils.AutomatonHelpers exposing (calculateArrowHead)
import Html.Attributes exposing (style)
import Html.Events exposing (custom, onClick)
import Json.Decode as Decode
import Svg exposing (Svg)
import Svg.Attributes as SA
import Html.Attributes exposing (attribute)
import Svg.Events as SE
import Shared exposing (State, Transition)
import Utils.Theme as Theme


type alias Config msg =
    { states : List State
    , transitions : List Transition
    , selectedState : Maybe Int
    , transitionFrom : Maybe Int
    , transitionTo : Maybe Int
    , activeStateId : Maybe Int
    , activeStateVerdict : Maybe Bool
    , activeTransition : Maybe { from : Int, to : Int, symbol : String }
    , onCanvasClick : Float -> Float -> msg
    , onCanvasDoubleClick : Float -> Float -> msg
    , onStateClick : Int -> msg
    , onStateDoubleClick : Int -> msg
    , onStateRightClick : Int -> msg
    , onTransitionClick : Int -> Int -> String -> msg
    , onArrowClick : Int -> Int -> msg
    , onStartDrag : Int -> Float -> Float -> msg
    , onDragMove : Float -> Float -> msg
    , onEndDrag : msg
    , onCanvasMouseDown : Float -> Float -> msg
    , onZoomIn : msg
    , onZoomOut : msg
    , onWheel : Float -> Float -> Float -> msg
    , panX : Float
    , panY : Float
    , zoom : Float
    , width : Float
    , height : Float
    , isSimulateMode : Bool
    , highlightedStateIds : List { stateId : Int, isAccepted : Bool }
    , highlightedTransitions : List { from : Int, to : Int }
    , highlightedSymbols : List { from : Int, to : Int, symbol : String }
    , editingStateId : Maybe Int
    , theme : Theme.Theme
    , gridMode : Bool
    }


view : Config msg -> Html msg
view config =
    div
        [ style "position" "relative"
        , style "width" "100%"
        , style "height" "100%"
        , style "overflow" "hidden"
        ]
        [ Svg.svg
            [ SA.width "100%"
            , SA.height "100%"
            , SE.on "click" (Decode.map2 config.onCanvasClick offsetX offsetY)
            , SE.on "dblclick" (Decode.map2 config.onCanvasDoubleClick offsetX offsetY)
            , SE.on "mousemove" (Decode.map2 config.onDragMove offsetX offsetY)
            , SE.on "mouseup" (Decode.succeed config.onEndDrag)
            , SE.on "mouseleave" (Decode.succeed config.onEndDrag)
            , SE.on "mousedown" (Decode.map2 config.onCanvasMouseDown offsetX offsetY)
            , SE.on "wheel" (Decode.map3 config.onWheel wheelDeltaY offsetX offsetY)
            ]
            ( ( if config.gridMode then [ svgGrid config ] else [] )
              ++ [ Svg.g
                    [ SA.transform
                        ( "translate("
                        ++ String.fromFloat config.panX
                        ++ ","
                        ++ String.fromFloat config.panY
                        ++ ") scale("
                        ++ String.fromFloat config.zoom
                        ++ ")"
                        )
                    ]
                    ( List.map (viewGroupedTransition config) (groupTransitions config.transitions)
                        ++ List.map (svgState config) config.states
                    )
                 ]
            )
        , div
            [ style "position" "absolute"
            , style "bottom" "16px"
            , style "right" "16px"
            , style "display" "flex"
            , style "flex-direction" "column"
            , style "gap" "4px"
            ]
            [ button
                [ onClick config.onZoomIn
                , style "width" "32px"
                , style "height" "32px"
                , style "font-size" "18px"
                , style "font-weight" "bold"
                , style "background-color" config.theme.btnSecondaryBg
                , style "color" "white"
                , style "border" "none"
                , style "border-radius" "4px"
                , style "cursor" "pointer"
                , style "line-height" "1"
                ]
                [ text "+" ]
            , button
                [ onClick config.onZoomOut
                , style "width" "32px"
                , style "height" "32px"
                , style "font-size" "18px"
                , style "font-weight" "bold"
                , style "background-color" config.theme.btnSecondaryBg
                , style "color" "white"
                , style "border" "none"
                , style "border-radius" "4px"
                , style "cursor" "pointer"
                , style "line-height" "1"
                ]
                [ text "-" ]
            ]
        ]


svgGrid : Config msg -> Svg msg
svgGrid config =
    let
        gridSize =
            60.0

        cellPx =
            gridSize * config.zoom

        modFloat a b =
            a - (toFloat (floor (a / b))) * b

        patX =
            modFloat config.panX cellPx

        patY =
            modFloat config.panY cellPx

        cellStr =
            String.fromFloat cellPx

        strokeColor =
            "rgba(120,120,120,0.22)"
    in
    Svg.g []
        [ Svg.defs []
            [ Svg.node "pattern"
                [ SA.id "grid-bg"
                , SA.x (String.fromFloat patX)
                , SA.y (String.fromFloat patY)
                , SA.width cellStr
                , SA.height cellStr
                , attribute "patternUnits" "userSpaceOnUse"
                ]
                [ Svg.line
                    [ SA.x1 "0", SA.y1 "0"
                    , SA.x2 cellStr, SA.y2 "0"
                    , SA.stroke strokeColor
                    , SA.strokeWidth "1"
                    ] []
                , Svg.line
                    [ SA.x1 "0", SA.y1 "0"
                    , SA.x2 "0", SA.y2 cellStr
                    , SA.stroke strokeColor
                    , SA.strokeWidth "1"
                    ] []
                ]
            ]
        , Svg.rect
            [ SA.width "100%"
            , SA.height "100%"
            , SA.fill "url(#grid-bg)"
            ] []
        ]


offsetX : Decode.Decoder Float
offsetX =
    Decode.field "offsetX" Decode.float


offsetY : Decode.Decoder Float
offsetY =
    Decode.field "offsetY" Decode.float


wheelDeltaY : Decode.Decoder Float
wheelDeltaY =
    Decode.field "ctrlKey" Decode.bool
        |> Decode.andThen
            (\ctrlKey ->
                if ctrlKey then
                    Decode.fail "pinch zoom"
                else
                    Decode.field "deltaY" Decode.float
            )


svgState : Config msg -> State -> Svg msg
svgState config state =
    let
        isSelected =
            config.selectedState == Just state.id

        isTransitionStart =
            config.transitionFrom == Just state.id

        isTransitionEnd =
            config.transitionTo == Just state.id

        isActive =
            config.activeStateId == Just state.id

        isEditing =
            config.editingStateId == Just state.id

        highlightMatch =
            List.filter (\h -> h.stateId == state.id) config.highlightedStateIds
                |> List.head

        fillColor =
            if isSelected then
                "#80cbc4"
            else if isTransitionStart || isTransitionEnd then
                config.theme.stateTransitionHighlight
            else if isActive then
                case config.activeStateVerdict of
                    Nothing ->
                        "#1e88e5"
                    Just True ->
                        "#43a047"
                    Just False ->
                        "#e53935"
            else if isEditing then
                "#ffe082"
            else
                case highlightMatch of
                    Just h ->
                        if h.isAccepted then "#a5d6a7" else "#ef9a9a"

                    Nothing ->
                        config.theme.stateFill

        borderColor =
            if isSelected then
                "#004d40"
            else if isActive then
                case config.activeStateVerdict of
                    Nothing ->
                        "#1565c0"
                    Just True ->
                        "#2e7d32"
                    Just False ->
                        "#b71c1c"
            else if isEditing then
                "#f9a825"
            else
                case highlightMatch of
                    Just h ->
                        if h.isAccepted then "#2e7d32" else "#b71c1c"

                    Nothing ->
                        config.theme.stateBorder

        borderWidth = 2

        r = 35
    in
    Svg.g
        [ SE.custom "click"
            (Decode.succeed
                { message = config.onStateClick state.id
                , stopPropagation = True
                , preventDefault = False
                }
            )
        , SE.custom "dblclick"
            (Decode.succeed
                { message = config.onStateDoubleClick state.id
                , stopPropagation = True
                , preventDefault = False
                }
            )
        , SE.custom "contextmenu"
            (Decode.succeed
                { message = config.onStateRightClick state.id
                , stopPropagation = True
                , preventDefault = True
                }
            )
        , SE.custom "mousedown"
            (Decode.map2
                (\x y ->
                    { message = config.onStartDrag state.id x y
                    , stopPropagation = True
                    , preventDefault = False
                    }
                )
                offsetX
                offsetY
            )
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
            , SA.fill (if isEditing then "#1a1a1a" else config.theme.stateText)
            , SA.fontWeight "bold"
            , SA.style "user-select: none; pointer-events: none;"
            ]
            [ Svg.text (if state.isCompact then String.left 4 state.label ++ "..." else state.label) ]
        ]
            ++ (if state.isStart then
                    let
                        labelOverflows = String.length state.label * 8 > 60
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
                    [ Svg.line [ SA.x1 (String.fromFloat lineX1), SA.y1 (String.fromFloat lineY1), SA.x2 (String.fromFloat tipX), SA.y2 (String.fromFloat tipY), SA.stroke config.theme.edgeColor, SA.strokeWidth "2" ] []
                    , Svg.polygon [ SA.points pts, SA.fill config.theme.edgeColor ] []
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

        isHighlighted =
            List.any (\ht -> ht.from == grouped.from && ht.to == grouped.to) config.highlightedTransitions

        highlightedSymbolsForGroup =
            config.highlightedSymbols
                |> List.filter (\hs -> hs.from == grouped.from && hs.to == grouped.to)
                |> List.map .symbol
    in
    case ( maybeFromState, maybeToState ) of
        ( Just fromState, Just toState ) ->
            if fromState.id == toState.id then
                svgSelfLoop config fromState grouped.symbols isActive isHighlighted highlightedSymbolsForGroup
            else
                if hasReverseTransition then
                    svgCurvedEdge config fromState toState grouped.symbols isActive isHighlighted highlightedSymbolsForGroup
                else
                    svgEdge config fromState toState grouped.symbols isActive isHighlighted highlightedSymbolsForGroup

        _ ->
            Svg.g [] []


svgSelfLoop : Config msg -> State -> List String -> Bool -> Bool -> List String -> Svg msg
svgSelfLoop config state symbols isActive isHighlighted highlightedSymbolsList =
    let
        r = 35
        startAngle = degrees -150
        endAngle = degrees -30

        sx = state.x + r * cos startAngle
        sy = state.y + r * sin startAngle

        ex = state.x + r * cos endAngle
        ey = state.y + r * sin endAngle

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

        vx = ex - c2x
        vy = ey - c2y
        len = sqrt (vx * vx + vy * vy)
        ux = if len == 0 then 1 else vx / len
        uy = if len == 0 then 0 else vy / len

        arrowPts = calculateArrowHead ex ey ux uy

        labels =
            let
                n = List.length symbols
                spacing = 16
                labelY = state.y - r - loopHeight + 5
                symbolStyle = if config.isSimulateMode then "user-select: none; pointer-events: none;" else "user-select: none;"
                symClickAttrs sym =
                    if config.isSimulateMode then
                        []
                    else
                        [ SE.custom "click"
                            (Decode.succeed
                                { message = config.onTransitionClick state.id state.id sym
                                , stopPropagation = True
                                , preventDefault = False
                                }
                            )
                        ]
                startX = state.x - (toFloat (n - 1) * toFloat spacing) / 2
            in
            List.indexedMap
                (\i sym ->
                    let
                        cx = startX + toFloat i * toFloat spacing
                        labelColor = if List.member sym highlightedSymbolsList then "#f9a825" else config.theme.edgeLabelColor
                    in
                    Svg.g (symClickAttrs sym)
                        [ Svg.rect
                            [ SA.x (String.fromFloat (cx - 12))
                            , SA.y (String.fromFloat (labelY - 14))
                            , SA.width "24"
                            , SA.height "20"
                            , SA.fill "transparent"
                            , SA.style "cursor: pointer;"
                            ]
                            []
                        , Svg.text_
                            [ SA.x (String.fromFloat cx)
                            , SA.y (String.fromFloat labelY)
                            , SA.textAnchor "middle"
                            , SA.fontSize "16"
                            , SA.fill labelColor
                            , SA.fontWeight "bold"
                            , SA.style symbolStyle
                            ]
                            [ Svg.text sym ]
                        ]
                )
                symbols

        strokeWidth = if isActive then "4" else "2"
        strokeColor = if isActive then "#e74c3c" else if isHighlighted then "#f9a825" else config.theme.edgeColor

        arrowClickAttrs =
            if config.isSimulateMode then
                []
            else
                [ SE.custom "click"
                    (Decode.succeed
                        { message = config.onArrowClick state.id state.id
                        , stopPropagation = True
                        , preventDefault = False
                        }
                    )
                ]
    in
    Svg.g []
        ([ Svg.path [ SA.d d, SA.fill "none", SA.stroke strokeColor, SA.strokeWidth strokeWidth, SA.strokeLinecap "round" ] []
         , Svg.path ([ SA.d d, SA.fill "none", SA.stroke "transparent", SA.strokeWidth "12", SA.strokeLinecap "round", SA.style "cursor: pointer;" ] ++ arrowClickAttrs) []
         , Svg.polygon [ SA.points arrowPts, SA.fill strokeColor ] []
         , Svg.polygon ([ SA.points arrowPts, SA.fill "transparent", SA.strokeWidth "10", SA.stroke "transparent", SA.style "cursor: pointer;" ] ++ arrowClickAttrs) []
         ]
            ++ labels
        )


svgEdge : Config msg -> State -> State -> List String -> Bool -> Bool -> List String -> Svg msg
svgEdge config a b symbols isActive isHighlighted highlightedSymbolsList =
    let
        r = 35
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

        arrowPts = calculateArrowHead ex ey ux uy

        n = List.length symbols
        spacing = 16
        midX = (sx + ex) / 2
        midY = (sy + ey) / 2

        angleRad = atan2 uy ux
        angleDeg = angleRad * 180 / pi
        rotationAngle = if ux < 0 then angleDeg + 180 else angleDeg

        symClickAttrs sym =
            if config.isSimulateMode then
                []
            else
                [ SE.custom "click"
                    (Decode.succeed
                        { message = config.onTransitionClick a.id b.id sym
                        , stopPropagation = True
                        , preventDefault = False
                        }
                    )
                ]

        labels =
            [ Svg.g
                [ SA.transform
                    ("translate(" ++ String.fromFloat midX ++ "," ++ String.fromFloat midY
                        ++ ") rotate(" ++ String.fromFloat rotationAngle ++ ")")
                ]
                (List.indexedMap
                    (\i sym ->
                        let
                            sx2 = (toFloat i - toFloat (n - 1) / 2.0) * toFloat spacing
                            labelColor = if List.member sym highlightedSymbolsList then "#f9a825" else config.theme.edgeLabelColor
                        in
                        Svg.g (symClickAttrs sym)
                            [ Svg.rect
                                [ SA.x (String.fromFloat (sx2 - 12))
                                , SA.y "-20"
                                , SA.width "24"
                                , SA.height "20"
                                , SA.fill "transparent"
                                , SA.style "cursor: pointer;"
                                ]
                                []
                            , Svg.text_
                                [ SA.x (String.fromFloat sx2)
                                , SA.y "-6"
                                , SA.textAnchor "middle"
                                , SA.fontSize "16"
                                , SA.fill labelColor
                                , SA.fontWeight "bold"
                                , SA.style "user-select: none;"
                                ]
                                [ Svg.text sym ]
                            ]
                    )
                    symbols
                )
            ]

        strokeWidth = if isActive then "4" else "2"
        strokeColor = if isActive then "#e74c3c" else if isHighlighted then "#f9a825" else config.theme.edgeColor

        arrowClickAttrs =
            if config.isSimulateMode then
                []
            else
                [ SE.custom "click"
                    (Decode.succeed
                        { message = config.onArrowClick a.id b.id
                        , stopPropagation = True
                        , preventDefault = False
                        }
                    )
                ]
    in
    Svg.g []
        ([ Svg.path [ SA.d d, SA.fill "none", SA.stroke strokeColor, SA.strokeWidth strokeWidth ] []
         , Svg.path ([ SA.d d, SA.fill "none", SA.stroke "transparent", SA.strokeWidth "12", SA.style "cursor: pointer;" ] ++ arrowClickAttrs) []
         , Svg.polygon [ SA.points arrowPts, SA.fill strokeColor ] []
         , Svg.polygon ([ SA.points arrowPts, SA.fill "transparent", SA.strokeWidth "10", SA.stroke "transparent", SA.style "cursor: pointer;" ] ++ arrowClickAttrs) []
         ]
            ++ labels
        )

svgCurvedEdge config a b symbols isActive isHighlighted highlightedSymbolsList =
    let
        r = 35

        vx = b.x - a.x
        vy = b.y - a.y
        len = sqrt (vx * vx + vy * vy)

        ux = if len == 0 then 1 else vx / len
        uy = if len == 0 then 0 else vy / len

        px = -uy
        py = ux

        offset = 40

        midX = (a.x + b.x) / 2
        midY = (a.y + b.y) / 2
        cx = midX + offset * px
        cy = midY + offset * py

        acX = cx - a.x
        acY = cy - a.y
        acLen = sqrt (acX * acX + acY * acY)
        acUx = acX / acLen
        acUy = acY / acLen

        sx = a.x + acUx * toFloat r
        sy = a.y + acUy * toFloat r

        bcX = cx - b.x
        bcY = cy - b.y
        bcLen = sqrt (bcX * bcX + bcY * bcY)
        bcUx = bcX / bcLen
        bcUy = bcY / bcLen

        ex = b.x + bcUx * toFloat r
        ey = b.y + bcUy * toFloat r

        d = "M " ++ String.fromFloat sx ++ " " ++ String.fromFloat sy
            ++ " Q " ++ String.fromFloat cx ++ " " ++ String.fromFloat cy
            ++ " " ++ String.fromFloat ex ++ " " ++ String.fromFloat ey

        tVx = ex - cx
        tVy = ey - cy
        tLen = sqrt (tVx * tVx + tVy * tVy)
        tUx = tVx / tLen
        tUy = tVy / tLen

        arrowPts = calculateArrowHead ex ey tUx tUy

        n = List.length symbols
        spacing = 16

        curveMidX = 0.25 * sx + 0.5 * cx + 0.25 * ex
        curveMidY = 0.25 * sy + 0.5 * cy + 0.25 * ey

        angleRad = atan2 uy ux
        angleDeg = angleRad * 180 / pi
        rotationAngle = if ux < 0 then angleDeg + 180 else angleDeg

        symClickAttrs sym =
            if config.isSimulateMode then
                []
            else
                [ SE.custom "click"
                    (Decode.succeed
                        { message = config.onTransitionClick a.id b.id sym
                        , stopPropagation = True
                        , preventDefault = False
                        }
                    )
                ]

        labels =
            [ Svg.g
                [ SA.transform
                    ("translate(" ++ String.fromFloat curveMidX ++ "," ++ String.fromFloat curveMidY
                        ++ ") rotate(" ++ String.fromFloat rotationAngle ++ ")")
                ]
                (List.indexedMap
                    (\i sym ->
                        let
                            sx2 = (toFloat i - toFloat (n - 1) / 2.0) * toFloat spacing
                            labelColor = if List.member sym highlightedSymbolsList then "#f9a825" else config.theme.edgeLabelColor
                        in
                        Svg.g (symClickAttrs sym)
                            [ Svg.rect
                                [ SA.x (String.fromFloat (sx2 - 12))
                                , SA.y "-20"
                                , SA.width "24"
                                , SA.height "20"
                                , SA.fill "transparent"
                                , SA.style "cursor: pointer;"
                                ]
                                []
                            , Svg.text_
                                [ SA.x (String.fromFloat sx2)
                                , SA.y "-6"
                                , SA.textAnchor "middle"
                                , SA.fontSize "16"
                                , SA.fill labelColor
                                , SA.fontWeight "bold"
                                , SA.style "user-select: none;"
                                ]
                                [ Svg.text sym ]
                            ]
                    )
                    symbols
                )
            ]

        strokeWidth = if isActive then "4" else "2"
        strokeColor = if isActive then "#e74c3c" else if isHighlighted then "#f9a825" else config.theme.edgeColor

        arrowClickAttrs =
            if config.isSimulateMode then
                []
            else
                [ SE.custom "click"
                    (Decode.succeed
                        { message = config.onArrowClick a.id b.id
                        , stopPropagation = True
                        , preventDefault = False
                        }
                    )
                ]
    in
    Svg.g []
        ([ Svg.path [ SA.d d, SA.fill "none", SA.stroke strokeColor, SA.strokeWidth strokeWidth ] []
         , Svg.path ([ SA.d d, SA.fill "none", SA.stroke "transparent", SA.strokeWidth "12", SA.style "cursor: pointer;" ] ++ arrowClickAttrs) []
         , Svg.polygon [ SA.points arrowPts, SA.fill strokeColor ] []
         , Svg.polygon ([ SA.points arrowPts, SA.fill "transparent", SA.strokeWidth "10", SA.stroke "transparent", SA.style "cursor: pointer;" ] ++ arrowClickAttrs) []
         ]
            ++ labels
        )
