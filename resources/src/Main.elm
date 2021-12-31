module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (for, id, type_, value)
import Html.Events exposing (onClick, onInput)
import Svg
import Svg.Attributes
import SvgIcons exposing (bookOpenOutline, plusOutline)
import TailwindHelpers as TW exposing (..)
import Url



-- elm make src/Main.elm --output=js/elm.js --debug


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = UrlRequested
        , onUrlChange = UrlChanged
        }


type alias NewBookData =
    { title : String
    , author : String
    }


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , newBookData : Maybe NewBookData
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( { key = key
      , url = url
      , newBookData = Nothing
      }
    , Cmd.none
    )


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url.Url
    | AddNewBook
    | GotNewBookMsg NewBookMsg


type NewBookMsg
    = ChangeTitle String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlRequested urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | url = url }
            , Cmd.none
            )

        AddNewBook ->
            ( { model
                | newBookData =
                    Just
                        { title = ""
                        , author = ""
                        }
              }
            , Cmd.none
            )

        GotNewBookMsg newBookMsg ->
            case model.newBookData of
                Just newBookData ->
                    case newBookMsg of
                        ChangeTitle newTitle ->
                            ( { model | newBookData = Just { newBookData | title = newTitle } }
                            , Cmd.none
                            )

                Nothing ->
                    ( model
                    , Cmd.none
                    )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Browser.Document Msg
view model =
    { title = "Title"
    , body =
        [ div
            [ TW.apply
                [ p_36
                ]
            ]
            [ case model.newBookData of
                Just data ->
                    form []
                        [ h2 [] [ text "Add Book" ]
                        , column []
                            [ label [ for "book-title" ] [ text "Title" ]
                            , input
                                [ id "book-title"
                                , type_ "text"
                                , value data.title
                                , onInput (\l -> ChangeTitle l |> GotNewBookMsg)
                                ]
                                []
                            ]
                        ]

                Nothing ->
                    simpleEmptyState
                        { mainIcon = bookOpenOutline
                        , title = "No books"
                        , subtitle = "Get started by adding a book"
                        , buttonText = "Add book"
                        , buttonIcon = Just plusOutline
                        , buttonMsg = AddNewBook
                        }
            ]
        ]
    }


simpleEmptyState :
    { mainIcon : List (Svg.Attribute Msg) -> Html Msg
    , title : String
    , subtitle : String
    , buttonText : String
    , buttonIcon : Maybe (List (Svg.Attribute Msg) -> Html Msg)
    , buttonMsg : Msg
    }
    -> Html Msg
simpleEmptyState { mainIcon, title, subtitle, buttonText, buttonIcon, buttonMsg } =
    column
        [ TW.apply
            [ m_auto
            , text_center
            , gap_y_3
            ]
        ]
        [ mainIcon
            [ [ w_12, h_12, opacity_40, mx_auto ]
                |> String.join " "
                |> Svg.Attributes.class
            ]
        , column []
            [ p
                [ TW.apply
                    [ text_black
                    , font_semibold
                    ]
                ]
                [ text title ]
            , p
                [ TW.apply
                    [ text_black
                    , font_semibold
                    , opacity_50
                    ]
                ]
                [ text subtitle ]
            ]
        , button
            [ onClick buttonMsg
            , TW.apply
                [ flex
                , px_3
                , py_2
                , gap_x_2
                , font_semibold
                , block
                , rounded
                , mx_auto
                , text_white
                , shadow_md
                , bg_blue_600
                , hover [ bg_blue_700 ]
                ]
            ]
            [ case buttonIcon of
                Just icon ->
                    icon
                        [ [ w_6, h_6 ]
                            |> String.join " "
                            |> Svg.Attributes.class
                        ]

                Nothing ->
                    text ""
            , text
                buttonText
            ]
        ]



-- Tailwind Helpers


column : List (Attribute msg) -> List (Html msg) -> Html msg
column attrs content =
    div (TW.apply [ flex, flex_col ] :: attrs) content


row : List (Attribute msg) -> List (Html msg) -> Html msg
row attrs content =
    div (TW.apply [ flex, flex_row ] :: attrs) content
