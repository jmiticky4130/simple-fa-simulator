module Utils.ConversionHelpers exposing
    ( DfaSubsetState
    , DfaSubsetTransition
    , ConversionStep(..)
    , StepSnapshot
    , buildSteps
    , lastSnapshotToAutomaton
    , stepExplanation
    , nfaAlphabet
    , getDfaLabel
    )

import Set
import Shared exposing (State, Transition, AutomatonState)
import Utils.Translations as Translations
import Utils.AutomatonHelpers exposing (epsilonClosure, getStateLabel)


-- TYPES


type alias DfaSubsetState =
    { id : Int
    , subset : List Int
    , label : String
    , isStart : Bool
    , isEnd : Bool
    , x : Float
    , y : Float
    }


type alias DfaSubsetTransition =
    { from : Int
    , to : Int
    , symbol : String
    }


type ConversionStep
    = StepInit { startSubset : List Int, startLabel : String }
    | StepProcessSymbol { dfaStateId : Int, symbol : String, moveResult : List Int, epsClosed : List Int, resultDfaId : Int, isNewState : Bool }
    | StepMarkProcessed { dfaStateId : Int }
    | StepDone


type alias StepSnapshot =
    { states : List DfaSubsetState
    , transitions : List DfaSubsetTransition
    , step : ConversionStep
    , processedIds : List Int
    , worklist : List Int
    }


-- ALGORITHM HELPERS


nfaAlphabet : List Transition -> List String
nfaAlphabet transitions =
    transitions
        |> List.filterMap (\t -> if t.symbol == "ε" then Nothing else Just t.symbol)
        |> Set.fromList
        |> Set.toList
        |> List.sort


moveSet : List Transition -> List Int -> String -> List Int
moveSet transitions stateIds sym =
    stateIds
        |> List.concatMap
            (\sid ->
                List.filterMap
                    (\t -> if t.from == sid && t.symbol == sym then Just t.to else Nothing)
                    transitions
            )
        |> Set.fromList
        |> Set.toList
        |> List.sort


epsilonClosureSet : List Transition -> List Int -> List Int
epsilonClosureSet transitions stateIds =
    stateIds
        |> List.concatMap (epsilonClosure transitions)
        |> Set.fromList
        |> Set.toList
        |> List.sort


subsetLabel : List State -> List Int -> String
subsetLabel states ids =
    if List.isEmpty ids then
        "∅"
    else
        "{" ++ String.join "," (List.map (\id -> getStateLabel id states) ids) ++ "}"


findBySubset : List Int -> List DfaSubsetState -> Maybe DfaSubsetState
findBySubset subset states =
    List.filter (\s -> s.subset == subset) states |> List.head


getDfaSubset : Int -> List DfaSubsetState -> List Int
getDfaSubset id states =
    List.filter (\s -> s.id == id) states
        |> List.head
        |> Maybe.map .subset
        |> Maybe.withDefault []


getDfaLabel : Int -> List DfaSubsetState -> String
getDfaLabel id states =
    List.filter (\s -> s.id == id) states
        |> List.head
        |> Maybe.map .label
        |> Maybe.withDefault "?"


-- BUILD STEPS


type alias BuildAcc =
    { snapshots : List StepSnapshot
    , currentStates : List DfaSubsetState
    , currentTransitions : List DfaSubsetTransition
    , worklist : List Int
    , processedIds : List Int
    , nextId : Int
    }


buildSteps : AutomatonState -> List StepSnapshot
buildSteps nfa =
    let
        maybeStartId =
            List.filter .isStart nfa.states |> List.head |> Maybe.map .id

        alph =
            nfaAlphabet nfa.transitions

        nfaEndIds =
            List.filter .isEnd nfa.states |> List.map .id
    in
    case maybeStartId of
        Nothing ->
            []

        Just sid ->
            let
                initialSubset =
                    epsilonClosureSet nfa.transitions [ sid ]

                initialLabel =
                    subsetLabel nfa.states initialSubset

                initialDfaState =
                    { id = 0
                    , subset = initialSubset
                    , label = initialLabel
                    , isStart = True
                    , isEnd = List.any (\id -> List.member id nfaEndIds) initialSubset
                    , x = 0
                    , y = 0
                    }

                initSnap =
                    { states = [ initialDfaState ]
                    , transitions = []
                    , step = StepInit { startSubset = initialSubset, startLabel = initialLabel }
                    , processedIds = []
                    , worklist = [ 0 ]
                    }

                acc0 =
                    { snapshots = [ initSnap ]
                    , currentStates = [ initialDfaState ]
                    , currentTransitions = []
                    , worklist = [ 0 ]
                    , processedIds = []
                    , nextId = 1
                    }

                finalAcc =
                    bfsLoop nfa alph nfaEndIds acc0

                doneSnap =
                    { states = finalAcc.currentStates
                    , transitions = finalAcc.currentTransitions
                    , step = StepDone
                    , processedIds = finalAcc.processedIds
                    , worklist = []
                    }
            in
            assignPositions (finalAcc.snapshots ++ [ doneSnap ])


bfsLoop : AutomatonState -> List String -> List Int -> BuildAcc -> BuildAcc
bfsLoop nfa alph nfaEndIds acc =
    case acc.worklist of
        [] ->
            acc

        dfaStateId :: restWorklist ->
            let
                accAfterSymbols =
                    List.foldl
                        (expandSymbol nfa nfaEndIds dfaStateId)
                        { acc | worklist = restWorklist }
                        alph

                markSnap =
                    { states = accAfterSymbols.currentStates
                    , transitions = accAfterSymbols.currentTransitions
                    , step = StepMarkProcessed { dfaStateId = dfaStateId }
                    , processedIds = accAfterSymbols.processedIds ++ [ dfaStateId ]
                    , worklist = accAfterSymbols.worklist
                    }

                accAfterMark =
                    { accAfterSymbols
                        | snapshots = accAfterSymbols.snapshots ++ [ markSnap ]
                        , processedIds = accAfterSymbols.processedIds ++ [ dfaStateId ]
                    }
            in
            bfsLoop nfa alph nfaEndIds accAfterMark


expandSymbol : AutomatonState -> List Int -> Int -> String -> BuildAcc -> BuildAcc
expandSymbol nfa nfaEndIds dfaStateId sym acc =
    let
        srcSubset =
            getDfaSubset dfaStateId acc.currentStates

        moved =
            moveSet nfa.transitions srcSubset sym

        closed =
            epsilonClosureSet nfa.transitions moved
    in
    case findBySubset closed acc.currentStates of
            Just existing ->
                let
                    newTrans =
                        { from = dfaStateId, to = existing.id, symbol = sym }

                    newTransitions =
                        acc.currentTransitions ++ [ newTrans ]

                    snap =
                        { states = acc.currentStates
                        , transitions = newTransitions
                        , step =
                            StepProcessSymbol
                                { dfaStateId = dfaStateId
                                , symbol = sym
                                , moveResult = moved
                                , epsClosed = closed
                                , resultDfaId = existing.id
                                , isNewState = False
                                }
                        , processedIds = acc.processedIds
                        , worklist = acc.worklist
                        }
                in
                { acc | currentTransitions = newTransitions, snapshots = acc.snapshots ++ [ snap ] }

            Nothing ->
                let
                    newId =
                        acc.nextId

                    newDfaState =
                        { id = newId
                        , subset = closed
                        , label = subsetLabel nfa.states closed
                        , isStart = False
                        , isEnd = List.any (\id -> List.member id nfaEndIds) closed
                        , x = 0
                        , y = 0
                        }

                    newStates =
                        acc.currentStates ++ [ newDfaState ]

                    newTransitions =
                        acc.currentTransitions ++ [ { from = dfaStateId, to = newId, symbol = sym } ]

                    newWorklist =
                        acc.worklist ++ [ newId ]

                    snap =
                        { states = newStates
                        , transitions = newTransitions
                        , step =
                            StepProcessSymbol
                                { dfaStateId = dfaStateId
                                , symbol = sym
                                , moveResult = moved
                                , epsClosed = closed
                                , resultDfaId = newId
                                , isNewState = True
                                }
                        , processedIds = acc.processedIds
                        , worklist = newWorklist
                        }
                in
                { acc
                    | currentStates = newStates
                    , currentTransitions = newTransitions
                    , worklist = newWorklist
                    , nextId = newId + 1
                    , snapshots = acc.snapshots ++ [ snap ]
                }


-- POSITION ASSIGNMENT


type alias PosEntry =
    { id : Int, x : Float, y : Float }


type alias LevelGroup =
    { level : Int, stateIds : List Int }


assignPositions : List StepSnapshot -> List StepSnapshot
assignPositions allSnaps =
    case List.reverse allSnaps |> List.head of
        Nothing ->
            allSnaps

        Just lastSnap ->
            let
                posMap =
                    computePositionMap lastSnap.states lastSnap.transitions

                applyToSnapshot snap =
                    { snap | states = List.map (applyPos posMap) snap.states }
            in
            List.map applyToSnapshot allSnaps


applyPos : List PosEntry -> DfaSubsetState -> DfaSubsetState
applyPos posMap state =
    case List.filter (\e -> e.id == state.id) posMap |> List.head of
        Just entry ->
            { state | x = entry.x, y = entry.y }

        Nothing ->
            state


computePositionMap : List DfaSubsetState -> List DfaSubsetTransition -> List PosEntry
computePositionMap states transitions =
    let
        allIds =
            List.map .id states

        levelGroups =
            groupByLevel (bfsLevels transitions)

        startX =
            140.0

        startY =
            80.0

        entriesForGroup group =
            List.indexedMap
                (\i sid -> { id = sid, x = startX + toFloat group.level * 230.0, y = startY + toFloat i * 140.0 })
                group.stateIds

        fromLevels =
            List.concatMap entriesForGroup levelGroups

        coveredIds =
            List.map .id fromLevels

        extraEntries =
            List.filter (\sid -> not (List.member sid coveredIds)) allIds
                |> List.indexedMap
                    (\i sid ->
                        { id = sid
                        , x = startX + toFloat (List.length levelGroups) * 230.0
                        , y = startY + toFloat i * 140.0
                        }
                    )
    in
    fromLevels ++ extraEntries


bfsLevels : List DfaSubsetTransition -> List { id : Int, level : Int }
bfsLevels transitions =
    let
        go queue visited result =
            case queue of
                [] ->
                    result

                entry :: rest ->
                    if List.member entry.id visited then
                        go rest visited result

                    else
                        let
                            neighbors =
                                List.filterMap
                                    (\t -> if t.from == entry.id then Just t.to else Nothing)
                                    transitions

                            newEntries =
                                List.map (\nid -> { id = nid, level = entry.level + 1 }) neighbors
                        in
                        go
                            (rest ++ newEntries)
                            (entry.id :: visited)
                            (result ++ [ { id = entry.id, level = entry.level } ])
    in
    go [ { id = 0, level = 0 } ] [] []


groupByLevel : List { id : Int, level : Int } -> List LevelGroup
groupByLevel entries =
    List.foldl
        (\entry acc ->
            case List.filter (\g -> g.level == entry.level) acc |> List.head of
                Just _ ->
                    List.map
                        (\g ->
                            if g.level == entry.level then
                                { g | stateIds = g.stateIds ++ [ entry.id ] }
                            else
                                g
                        )
                        acc

                Nothing ->
                    acc ++ [ { level = entry.level, stateIds = [ entry.id ] } ]
        )
        []
        entries


-- EXPORT HELPER


lastSnapshotToAutomaton : List StepSnapshot -> AutomatonState
lastSnapshotToAutomaton snapshots =
    case List.reverse snapshots |> List.head of
        Nothing ->
            { states = [], transitions = [], nextStateId = 0 }

        Just snap ->
            { states = List.map dfaSubsetStateToState snap.states
            , transitions = List.map (\dt -> { from = dt.from, to = dt.to, symbol = dt.symbol }) snap.transitions
            , nextStateId = List.length snap.states
            }


dfaSubsetStateToState : DfaSubsetState -> Shared.State
dfaSubsetStateToState ds =
    { id = ds.id, x = ds.x, y = ds.y, label = ds.label, isStart = ds.isStart, isEnd = ds.isEnd, isCompact = False }


-- STEP EXPLANATION


stepExplanation : Translations.Translations -> List State -> List DfaSubsetState -> ConversionStep -> String
stepExplanation t nfaStates dfaStates step =
    case step of
        StepInit info ->
            t.convInitPrefix
                ++ info.startLabel
                ++ t.convInitSuffix

        StepProcessSymbol info ->
            let
                srcLabel =
                    getDfaLabel info.dfaStateId dfaStates

                moveStr =
                    subsetLabel nfaStates info.moveResult

                destStr =
                    subsetLabel nfaStates info.epsClosed
            in
            t.convProcessingPrefix ++ srcLabel ++ " so symbolom '" ++ info.symbol
                    ++ t.convMovePrefix ++ moveStr ++ t.convClosurePrefix ++ destStr
                    ++ (if info.isNewState then t.convNewStateCreated else t.convStateAlreadyExists)

        StepMarkProcessed info ->
              t.convStateProcessedPrefix ++ getDfaLabel info.dfaStateId dfaStates ++ t.convStateProcessedSuffix

        StepDone ->
              t.convConstructionDone
