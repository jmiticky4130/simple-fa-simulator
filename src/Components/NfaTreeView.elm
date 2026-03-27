module Components.NfaTreeView exposing (Config, view)

import Html exposing (Html, div, button, text)
import Html.Attributes exposing (style, id)
import Html.Events exposing (onClick)
import Svg exposing (Svg)
import Svg.Attributes as SA
import Svg.Events as SE
import Shared exposing (NfaInstance, NfaTreeNode, State)
import Utils.Theme as Theme


type alias Config msg =
    { treeNodes : List NfaTreeNode
    , instances : List NfaInstance
    , states : List State
    , selectedId : Maybe Int
    , onSelect : Int -> msg
    , mergedEdges : List { from : Int, to : Int }
    , zoom : Float
    , onZoomIn : msg
    , onZoomOut : msg
    , theme : Theme.Theme
    }


nodeR : Float
nodeR =
    22


levelH : Float
levelH =
    90


nodeSpacingH : Float
nodeSpacingH =
    62


topPad : Float
topPad =
    50


leftPad : Float
leftPad =
    20


rightAreaW : Float
rightAreaW =
    70


type alias PosEntry =
    { id : Int, x : Float, y : Float }


getDepth : Int -> List NfaTreeNode -> Int
getDepth id nodes =
    case List.filter (\n -> n.id == id) nodes |> List.head of
        Nothing ->
            0

        Just node ->
            case node.parentId of
                Nothing ->
                    0

                Just pid ->
                    1 + getDepth pid nodes


computePositions : List NfaTreeNode -> Int -> Float -> List PosEntry
computePositions nodes maxDepth contentW =
    let
        go : Int -> List PosEntry -> List PosEntry -> List PosEntry
        go depth prevPos acc =
            if depth > maxDepth then
                acc

            else
                let
                    levelNodes =
                        List.filter (\n -> getDepth n.id nodes == depth) nodes

                    -- Sort by parent x so children of leftmost parent come first
                    sortedNodes =
                        List.sortBy
                            (\n ->
                                case n.parentId of
                                    Nothing ->
                                        0.0

                                    Just pid ->
                                        prevPos
                                            |> List.filter (\p -> p.id == pid)
                                            |> List.head
                                            |> Maybe.map .x
                                            |> Maybe.withDefault 0.0
                            )
                            levelNodes

                    count =
                        List.length sortedNodes

                    totalW =
                        toFloat count * nodeSpacingH

                    startX =
                        leftPad + (contentW - totalW) / 2.0 + nodeSpacingH / 2.0

                    y =
                        toFloat depth * levelH + topPad

                    thisLevel =
                        List.indexedMap
                            (\i n -> { id = n.id, x = startX + toFloat i * nodeSpacingH, y = y })
                            sortedNodes
                in
                go (depth + 1) thisLevel (acc ++ thisLevel)
    in
    go 0 [] []


view : Config msg -> Html msg
view config =
    let
        nodes =
            config.treeNodes

        depths =
            List.map (\n -> getDepth n.id nodes) nodes

        maxDepth =
            List.maximum depths |> Maybe.withDefault 0

        maxNodesPerLevel =
            List.range 0 maxDepth
                |> List.map
                    (\d ->
                        List.length (List.filter (\n -> getDepth n.id nodes == d) nodes)
                    )
                |> List.maximum
                |> Maybe.withDefault 1

        contentW =
            toFloat (max 1 maxNodesPerLevel) * nodeSpacingH

        svgW =
            leftPad + contentW + rightAreaW

        svgH =
            toFloat (maxDepth + 1) * levelH + topPad + 40.0

        posMap =
            computePositions nodes maxDepth contentW

        findPos nid =
            List.filter (\p -> p.id == nid) posMap |> List.head

        findInstance nid =
            List.filter (\i -> i.id == nid) config.instances |> List.head

        stateLabel maybeStateId =
            case maybeStateId of
                Nothing ->
                    "∅"

                Just sid ->
                    config.states
                        |> List.filter (\s -> s.id == sid)
                        |> List.head
                        |> Maybe.map .label
                        |> Maybe.withDefault "?"

        -- Color based on whether the node is a current instance and its verdict
        nodeColors nid =
            case findInstance nid of
                Nothing ->
                    -- Intermediate node (was replaced by children)
                    { fill = config.theme.neutralGrayBg, stroke = config.theme.neutralGrayStroke, textFill = config.theme.textOnDark }

                Just inst ->
                    case inst.verdict of
                        Nothing ->
                            { fill = config.theme.runningFillColor, stroke = config.theme.runningBorderColor, textFill = config.theme.textOnDark }

                        Just v ->
                            if v.isAccepted then
                                { fill = config.theme.acceptFillColor, stroke = config.theme.acceptBorderColor, textFill = config.theme.textOnDark }

                            else
                                { fill = config.theme.rejectFillColor, stroke = config.theme.rejectBorderColor, textFill = config.theme.textOnDark }

        isSelected nid =
            config.selectedId == Just nid

        -- Render an edge from parent center-bottom to child center-top
        renderEdge : PosEntry -> PosEntry -> Svg msg
        renderEdge parentPos childPos =
            Svg.line
                [ SA.x1 (String.fromFloat parentPos.x)
                , SA.y1 (String.fromFloat (parentPos.y + nodeR))
                , SA.x2 (String.fromFloat childPos.x)
                , SA.y2 (String.fromFloat (childPos.y - nodeR))
                , SA.stroke config.theme.dividerColor
                , SA.strokeWidth "1.5"
                ]
                []

        -- Render a dashed edge for merged paths
        renderMergeEdge : PosEntry -> PosEntry -> Svg msg
        renderMergeEdge parentPos childPos =
            Svg.line
                [ SA.x1 (String.fromFloat parentPos.x)
                , SA.y1 (String.fromFloat (parentPos.y + nodeR))
                , SA.x2 (String.fromFloat childPos.x)
                , SA.y2 (String.fromFloat (childPos.y - nodeR))
                , SA.stroke config.theme.neutralGrayBg
                , SA.strokeWidth "1.5"
                , SA.strokeDasharray "5,4"
                ]
                []

        -- Render a node (circle + label) with click handler
        renderNode : PosEntry -> String -> msg -> Svg msg
        renderNode pos label selectMsg =
            let
                colors =
                    nodeColors pos.id

                strokeW =
                    if isSelected pos.id then
                        "3"

                    else
                        "1.5"

                strokeColor =
                    if isSelected pos.id then
                        config.theme.textOnDark

                    else
                        colors.stroke

                -- Truncate label to 5 chars to fit in circle
                truncLabel =
                    if String.length label > 5 then
                        String.left 4 label ++ "…"

                    else
                        label
            in
            Svg.g
                [ SA.transform
                    ("translate("
                        ++ String.fromFloat pos.x
                        ++ ","
                        ++ String.fromFloat pos.y
                        ++ ")"
                    )
                , SA.style "cursor: pointer"
                , SE.onClick selectMsg
                ]
                [ Svg.circle
                    [ SA.r (String.fromFloat nodeR)
                    , SA.fill colors.fill
                    , SA.stroke strokeColor
                    , SA.strokeWidth strokeW
                    ]
                    []
                , Svg.text_
                    [ SA.textAnchor "middle"
                    , SA.dominantBaseline "central"
                    , SA.fill colors.textFill
                    , SA.fontSize "10"
                    , SA.fontWeight "bold"
                    , SA.pointerEvents "none"
                    ]
                    [ Svg.text truncLabel ]
                ]

        -- Render the symbol label for a given depth (shown on the right)
        renderLevelSymbol : Int -> String -> Svg msg
        renderLevelSymbol depth sym =
            let
                y =
                    toFloat depth * levelH + topPad

                xLabel =
                    leftPad + contentW + 12
            in
            Svg.g []
                [ -- Horizontal separator line at midpoint above this level
                  Svg.line
                    [ SA.x1 (String.fromFloat (leftPad + 4))
                    , SA.y1 (String.fromFloat (y - levelH / 2))
                    , SA.x2 (String.fromFloat (leftPad + contentW - 4))
                    , SA.y2 (String.fromFloat (y - levelH / 2))
                    , SA.stroke config.theme.mutedContrastText
                    , SA.strokeWidth "1"
                    , SA.strokeDasharray "4,3"
                    ]
                    []
                , -- Symbol box on the right, at midpoint between levels (same y as edges)
                  Svg.rect
                    [ SA.x (String.fromFloat (xLabel - 2))
                    , SA.y (String.fromFloat (y - levelH / 2 - 11))
                    , SA.width "36"
                    , SA.height "22"
                    , SA.rx "4"
                    , SA.fill config.theme.nfaNodeBoxBg
                    , SA.stroke config.theme.nfaNodeBoxStroke
                    , SA.strokeWidth "1"
                    ]
                    []
                , Svg.text_
                    [ SA.x (String.fromFloat (xLabel + 16))
                    , SA.y (String.fromFloat (y - levelH / 2))
                    , SA.textAnchor "middle"
                    , SA.dominantBaseline "central"
                    , SA.fill config.theme.nfaNodeBoxText
                    , SA.fontSize "13"
                    , SA.fontWeight "bold"
                    ]
                    [ Svg.text sym ]
                ]

        -- Collect all edges
        allEdges : List (Svg msg)
        allEdges =
            List.filterMap
                (\n ->
                    case n.parentId of
                        Nothing ->
                            Nothing

                        Just pid ->
                            case ( findPos n.id, findPos pid ) of
                                ( Just cp, Just pp ) ->
                                    Just (renderEdge pp cp)

                                _ ->
                                    Nothing
                )
                nodes

        -- Collect merge edges (dashed, shown when mergeEnabled drops duplicate paths)
        mergeEdgesSvg : List (Svg msg)
        mergeEdgesSvg =
            List.filterMap
                (\e ->
                    case ( findPos e.from, findPos e.to ) of
                        ( Just fp, Just tp ) ->
                            Just (renderMergeEdge fp tp)

                        _ ->
                            Nothing
                )
                config.mergedEdges

        -- For a depth, return Just sym if all nodes share the same symbol, else Nothing
        uniformSymbolAt : Int -> Maybe String
        uniformSymbolAt d =
            let
                syms =
                    nodes
                        |> List.filter (\n -> getDepth n.id nodes == d)
                        |> List.filterMap .symbol
            in
            case syms of
                [] ->
                    Nothing

                first :: rest ->
                    if List.all (\s -> s == first) rest then
                        Just first

                    else
                        Nothing

        -- Collect level symbol labels (one per depth d > 0, only when uniform)
        levelSymbols : List (Svg msg)
        levelSymbols =
            List.range 1 maxDepth
                |> List.filterMap
                    (\d -> Maybe.map (renderLevelSymbol d) (uniformSymbolAt d))

        -- For mixed-symbol levels: render separator line only (no right-side box)
        mixedSeparators : List (Svg msg)
        mixedSeparators =
            List.range 1 maxDepth
                |> List.filterMap
                    (\d ->
                        case uniformSymbolAt d of
                            Just _ ->
                                Nothing

                            Nothing ->
                                let
                                    y =
                                        toFloat d * levelH + topPad
                                in
                                Just
                                    (Svg.line
                                        [ SA.x1 (String.fromFloat (leftPad + 4))
                                        , SA.y1 (String.fromFloat (y - levelH / 2))
                                        , SA.x2 (String.fromFloat (leftPad + contentW - 4))
                                        , SA.y2 (String.fromFloat (y - levelH / 2))
                                        , SA.stroke config.theme.mutedContrastText
                                        , SA.strokeWidth "1"
                                        , SA.strokeDasharray "4,3"
                                        ]
                                        []
                                    )
                    )

        -- Small symbol badge rendered at edge midpoint
        renderEdgeSymbol : Float -> Float -> String -> Svg msg
        renderEdgeSymbol mx my sym =
            Svg.g []
                [ Svg.rect
                    [ SA.x (String.fromFloat (mx - 12))
                    , SA.y (String.fromFloat (my - 9))
                    , SA.width "24"
                    , SA.height "18"
                    , SA.rx "3"
                    , SA.fill config.theme.nfaNodeBoxBg
                    , SA.stroke config.theme.nfaNodeBoxStroke
                    , SA.strokeWidth "1"
                    ]
                    []
                , Svg.text_
                    [ SA.x (String.fromFloat mx)
                    , SA.y (String.fromFloat my)
                    , SA.textAnchor "middle"
                    , SA.dominantBaseline "central"
                    , SA.fill config.theme.nfaNodeBoxText
                    , SA.fontSize "11"
                    , SA.fontWeight "bold"
                    , SA.pointerEvents "none"
                    ]
                    [ Svg.text sym ]
                ]

        -- Per-edge symbol labels for mixed levels
        mixedEdgeLabels : List (Svg msg)
        mixedEdgeLabels =
            List.range 1 maxDepth
                |> List.concatMap
                    (\d ->
                        case uniformSymbolAt d of
                            Just _ ->
                                []

                            Nothing ->
                                nodes
                                    |> List.filter (\n -> getDepth n.id nodes == d)
                                    |> List.filterMap
                                        (\n ->
                                            case ( n.parentId, n.symbol ) of
                                                ( Just pid, Just sym ) ->
                                                    case ( findPos n.id, findPos pid ) of
                                                        ( Just cp, Just pp ) ->
                                                            Just
                                                                (renderEdgeSymbol
                                                                    ((pp.x + cp.x) / 2)
                                                                    ((pp.y + cp.y) / 2)
                                                                    sym
                                                                )

                                                        _ ->
                                                            Nothing

                                                _ ->
                                                    Nothing
                                        )
                    )

        -- Collect all node renderings
        allNodes : List (Svg msg)
        allNodes =
            List.filterMap
                (\pos ->
                    let
                        node =
                            List.filter (\n -> n.id == pos.id) nodes |> List.head
                    in
                    case node of
                        Nothing ->
                            Nothing

                        Just n ->
                            Just
                                (renderNode pos
                                    (stateLabel n.stateId)
                                    (config.onSelect pos.id)
                                )
                )
                posMap
        scaledW =
            svgW * config.zoom

        scaledH =
            svgH * config.zoom
    in
    div
        [ style "flex" "1"
        , style "min-width" "150px"
        , style "position" "relative"
        , style "overflow" "hidden"
        ]
        [ div
            [ id "nfa-tree-scroll"
            , style "width" "100%"
            , style "height" "100%"
            , style "overflow" "auto"
            , style "background-color" config.theme.canvasBg
            ]
            [ Svg.svg
                [ SA.width (String.fromFloat scaledW)
                , SA.height (String.fromFloat scaledH)
                , SA.viewBox ("0 0 " ++ String.fromFloat svgW ++ " " ++ String.fromFloat svgH)
                , SA.style "display: block;"
                ]
                [ Svg.g [] allEdges
                , Svg.g [] mergeEdgesSvg
                , Svg.g [] levelSymbols
                , Svg.g [] mixedSeparators
                , Svg.g [] mixedEdgeLabels
                , Svg.g [] allNodes
                ]
            ]
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
                , style "color" config.theme.textOnDark
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
                , style "color" config.theme.textOnDark
                , style "border" "none"
                , style "border-radius" "4px"
                , style "cursor" "pointer"
                , style "line-height" "1"
                ]
                [ text "-" ]
            ]
        ]
