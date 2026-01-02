module Main exposing (..)

import Browser
import Browser.Events
import Html exposing (Html, div, button, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Json.Decode as Decode
import Pages.Editor as Editor
import Pages.Simulator as Simulator
import Shared exposing (AutomatonState)


type Page
    = EditorPage
    | SimulatorPage


type alias Model =
    { currentPage : Page
    , editorModel : Editor.Model
    , simulatorModel : Simulator.Model
    }


init : () -> ( Model, Cmd Msg )
init _ =
    let
        editorInit = Editor.init
        simulatorInit = Simulator.init { states = [], transitions = [], nextStateId = 0 }
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

                _ ->
                    let
                        ( newEditorModel, editorCmd ) =
                            Editor.update editorMsg model.editorModel
                    in
                    ( { model | editorModel = newEditorModel }
                    , Cmd.map EditorMsg editorCmd
                    )

        SimulatorMsg simulatorMsg ->
            case simulatorMsg of
                Simulator.SwitchToEditor ->
                    ( { model | currentPage = EditorPage }
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
            Browser.Events.onKeyDown (keyDecoder model)

        SimulatorPage ->
            Sub.none


keyDecoder : Model -> Decode.Decoder Msg
keyDecoder model =
    Decode.map3 (\key ctrl shift -> 
        if ctrl && (key == "z" || key == "Z") then EditorMsg Editor.Undo
        else if ctrl && (key == "y" || key == "Y") then EditorMsg Editor.Redo
        else if shift && (key == "s" || key == "S") then EditorMsg (Editor.ChangeTool Editor.AddStateTool)
        else if shift && (key == "d" || key == "D") then EditorMsg (Editor.ChangeTool Editor.DeleteTool)
        else if shift && (key == "e" || key == "E") then EditorMsg (Editor.ChangeTool Editor.AddTransitionTool)
        else if shift && (key == "r" || key == "R") then EditorMsg (Editor.ChangeTool Editor.RenameTool)
        else if shift && (key == "a" || key == "A") then EditorMsg (Editor.ChangeTool Editor.MoveTool)
        else if shift && (key == "f" || key == "F") then EditorMsg (Editor.ChangeTool Editor.SetEndStateTool)
        else if shift && (key == "q" || key == "Q") then EditorMsg (Editor.ChangeTool Editor.SetStartStateTool)
        else if key == "Escape" then EditorMsg Editor.CancelAction
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


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
