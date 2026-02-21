port module Main exposing (..)

import Browser
import Browser.Events
import Html exposing (Html, div, button, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Json.Decode as Decode
import Pages.Editor as Editor
import Pages.Simulator as Simulator
import Shared exposing (AutomatonState)
import Utils.AutomatonCodec


port setUrlHash : String -> Cmd msg

port saveNamedAutomaton : { name : String, data : String } -> Cmd msg

port requestStoredAutomata : () -> Cmd msg

port storedAutomataLoaded : (List { name : String, data : String } -> msg) -> Sub msg


type Page
    = EditorPage
    | SimulatorPage


type alias Model =
    { currentPage : Page
    , editorModel : Editor.Model
    , simulatorModel : Simulator.Model
    }


init : Maybe String -> ( Model, Cmd Msg )
init maybeJson =
    let
        loadedAutomaton =
            maybeJson
                |> Maybe.andThen (Decode.decodeString Utils.AutomatonCodec.decoder >> Result.toMaybe)

        editorInit =
            Editor.initWith loadedAutomaton

        simulatorInit =
            Simulator.init { states = [], transitions = [], nextStateId = 0 }
    in
    ( { currentPage = EditorPage
      , editorModel = editorInit
      , simulatorModel = simulatorInit
      }
    , Cmd.none
    )


type Msg
    = EditorMsg Editor.Msg
    | SimulatorMsg Simulator.Msg
    | SwitchToEditor


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EditorMsg editorMsg ->
            case editorMsg of
                Editor.SwitchToSimulator ->
                    let
                        currentAutomaton = model.editorModel.automaton.present
                        simulatorInit = Simulator.init currentAutomaton
                    in
                    ( { model
                        | currentPage = SimulatorPage
                        , simulatorModel = simulatorInit
                      }
                    , Cmd.none
                    )

                Editor.ShareUrl ->
                    let
                        ( newEditorModel, editorCmd ) =
                            Editor.update editorMsg model.editorModel
                    in
                    ( { model | editorModel = newEditorModel }
                    , Cmd.batch [ Cmd.map EditorMsg editorCmd, setUrlHash (Utils.AutomatonCodec.encode model.editorModel.automaton.present) ]
                    )

                Editor.ConfirmSave ->
                    let
                        name = String.trim model.editorModel.saveNameInput
                        ( newEditorModel, editorCmd ) =
                            Editor.update editorMsg model.editorModel
                    in
                    if String.isEmpty name then
                        ( { model | editorModel = newEditorModel }
                        , Cmd.map EditorMsg editorCmd
                        )
                    else
                        ( { model | editorModel = newEditorModel }
                        , Cmd.batch
                            [ Cmd.map EditorMsg editorCmd
                            , saveNamedAutomaton { name = name, data = Utils.AutomatonCodec.encode model.editorModel.automaton.present }
                            ]
                        )

                Editor.LoadRequested ->
                    let
                        ( newEditorModel, editorCmd ) =
                            Editor.update editorMsg model.editorModel
                    in
                    ( { model | editorModel = newEditorModel }
                    , Cmd.batch [ Cmd.map EditorMsg editorCmd, requestStoredAutomata () ]
                    )

                Editor.LoadFromStorage ->
                    let
                        ( newEditorModel, editorCmd ) =
                            Editor.update editorMsg model.editorModel
                    in
                    ( { model | editorModel = newEditorModel }
                    , Cmd.batch [ Cmd.map EditorMsg editorCmd, requestStoredAutomata () ]
                    )

                _ ->
                    let
                        ( newEditorModel, editorCmd ) =
                            Editor.update editorMsg model.editorModel
                    in
                    ( { model | editorModel = newEditorModel }
                    , Cmd.map EditorMsg editorCmd
                    )

        SimulatorMsg simulatorMsg ->
            let
                sim =
                    model.simulatorModel
            in
            case simulatorMsg of
                Simulator.SwitchToEditor ->
                    ( { model
                        | currentPage = EditorPage
                        , simulatorModel = { sim | autoRunning = False }
                      }
                    , Cmd.none
                    )

                _ ->
                    let
                        newSimulatorModel =
                            Simulator.update simulatorMsg model.simulatorModel
                    in
                    ( { model | simulatorModel = newSimulatorModel }
                    , Cmd.none
                    )

        SwitchToEditor ->
            ( { model | currentPage = EditorPage }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.currentPage of
        EditorPage ->
            Sub.batch
                [ Browser.Events.onKeyDown (keyDecoder model)
                , storedAutomataLoaded (\list -> EditorMsg (Editor.StorageAutomataLoaded list))
                ]

        SimulatorPage ->
            Sub.map SimulatorMsg (Simulator.subscriptions model.simulatorModel)


keyDecoder : Model -> Decode.Decoder Msg
keyDecoder model =
    Decode.map3 (\key ctrl shift ->
        if ctrl && (key == "z" || key == "Z") then EditorMsg Editor.Undo
        else if ctrl && (key == "y" || key == "Y") then EditorMsg Editor.Redo
        else if shift && (key == "b" || key == "B") then EditorMsg (Editor.ChangeTool Editor.BuildTool)
        else if shift && (key == "d" || key == "D") then EditorMsg (Editor.ChangeTool Editor.DeleteTool)
        else if key == "Escape" then
            if model.editorModel.showSaveModal then EditorMsg Editor.DismissSaveModal
            else if model.editorModel.showLoadModal then EditorMsg Editor.DismissLoadModal
            else EditorMsg Editor.CancelAction
        else EditorMsg Editor.NoOp
    )
    (Decode.field "key" Decode.string)
    (Decode.field "ctrlKey" Decode.bool)
    (Decode.field "shiftKey" Decode.bool)


view : Model -> Html Msg
view model =
    case model.currentPage of
        EditorPage ->
            Html.map EditorMsg (Editor.view model.editorModel)

        SimulatorPage ->
            div
                [ style "display" "flex"
                , style "flex-direction" "column"
                , style "height" "100vh"
                ]
                [ Html.map SimulatorMsg (Simulator.view model.simulatorModel)
                ]


main : Program (Maybe String) Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
