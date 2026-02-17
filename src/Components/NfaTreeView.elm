module Components.NfaTreeView exposing (Config, view)

import Html exposing (Html, div)
import Html.Attributes exposing (style)
import Svg exposing (Svg)
import Svg.Attributes as SA
import Svg.Events as SE
import Shared exposing (NfaInstance, NfaTreeNode, State)


type alias Config msg =
    { treeNodes : List NfaTreeNode
    , instances : List NfaInstance
    , states : List State
    , selectedId : Maybe Int
    , onSelect : Int -> msg
    , mergedEdges : List { from : Int, to : Int }
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
                    { fill = "#90a4ae", stroke = "#607d8b", textFill = "white" }

                Just inst ->
                    case inst.verdict of
                        Nothing ->
                            { fill = "#1e88e5", stroke = "#1565c0", textFill = "white" }

                        Just v ->
                            if v.isAccepted then
                                { fill = "#43a047", stroke = "#2e7d32", textFill = "white" }

                            else
                                { fill = "#e53935", stroke = "#b71c1c", textFill = "white" }

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
                , SA.stroke "#b0bec5"
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
                , SA.stroke "#90a4ae"
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
                        "white"

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
                    , SA.stroke "#cfd8dc"
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
                    , SA.fill "#eceff1"
                    , SA.stroke "#90a4ae"
                    , SA.strokeWidth "1"
                    ]
                    []
                , Svg.text_
                    [ SA.x (String.fromFloat (xLabel + 16))
                    , SA.y (String.fromFloat (y - levelH / 2))
                    , SA.textAnchor "middle"
                    , SA.dominantBaseline "central"
                    , SA.fill "#37474f"
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

        -- Collect level symbol labels (one per depth d > 0)
        levelSymbols : List (Svg msg)
        levelSymbols =
            List.range 1 maxDepth
                |> List.filterMap
                    (\d ->
                        -- Get symbol from first node at this depth
                        nodes
                            |> List.filter (\n -> getDepth n.id nodes == d)
                            |> List.head
                            |> Maybe.andThen .symbol
                            |> Maybe.map (\sym -> renderLevelSymbol d sym)
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
    in
    div
        [ style "flex" "1"
        , style "overflow" "auto"
        , style "background-color" "#ecf0f1"
        ]
        [ Svg.svg
            [ SA.width (String.fromFloat svgW)
            , SA.height (String.fromFloat svgH)
            ]
            [ Svg.g [] allEdges
            , Svg.g [] mergeEdgesSvg
            , Svg.g [] levelSymbols
            , Svg.g [] allNodes
            ]
        ]
