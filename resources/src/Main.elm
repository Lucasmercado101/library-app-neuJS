module Main exposing (main)

import Array exposing (Array)
import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (for, id, type_, value)
import Html.Events exposing (onClick, onInput)
import Svg
import Svg.Attributes
import SvgIcons exposing (bookOpenOutline, plusOutline, xOutline)
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
    , authors : Array String
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
      , newBookData =
            Just
                { title = ""
                , authors = Array.fromList [ "" ]
                }

      --   , newBookData = Nothing
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
    | AddAuthor
    | ChangeAuthor Int String
    | RemoveAuthor Int


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
                        , authors = Array.fromList [ "" ]
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

                        AddAuthor ->
                            ( { model
                                | newBookData =
                                    Just
                                        { newBookData
                                            | authors = Array.push "" newBookData.authors
                                        }
                              }
                            , Cmd.none
                            )

                        ChangeAuthor index newAuthor ->
                            ( { model
                                | newBookData =
                                    Just
                                        { newBookData
                                            | authors = Array.set index newAuthor newBookData.authors
                                        }
                              }
                            , Cmd.none
                            )

                        RemoveAuthor index ->
                            ( { model
                                | newBookData =
                                    Just
                                        { newBookData
                                            | authors = removeFromArray index newBookData.authors
                                        }
                              }
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
        [ div [ TW.apply [ bg_gray_100, h_screen, w_screen ] ]
            [ div
                [ TW.apply
                    [ p_36
                    ]
                ]
                [ case model.newBookData of
                    Just newBookData ->
                        form [ TW.apply [ shadow_md, rounded_md, p_4, bg_white ] ]
                            [ bookOpenOutline
                                [ [ w_16, h_16, mx_auto ]
                                    |> String.join " "
                                    |> Svg.Attributes.class
                                ]
                            , h2
                                [ TW.apply
                                    [ text_center
                                    , text_xl
                                    , font_semibold
                                    ]
                                ]
                                [ text "Add Book" ]
                            , column [ TW.apply [ gap_4 ] ]
                                (column
                                    []
                                    [ label [ for "book-title" ] [ p [] [ text "Title" ] ]
                                    , input
                                        [ id "book-title"
                                        , type_ "text"
                                        , value newBookData.title
                                        , onInput (\l -> ChangeTitle l |> GotNewBookMsg)
                                        , TW.apply
                                            [ border
                                            , border_gray_300
                                            , p_2
                                            , pl_3
                                            , w_full
                                            , rounded_md
                                            ]
                                        ]
                                        []
                                    ]
                                    :: (Array.toList
                                            (Array.indexedMap
                                                (\index author ->
                                                    column []
                                                        [ label
                                                            [ for ("book-author-" ++ String.fromInt index)
                                                            ]
                                                            [ text ("Author " ++ String.fromInt (index + 1)) ]
                                                        , row []
                                                            [ input
                                                                [ id ("book-author-" ++ String.fromInt index)
                                                                , type_ "text"
                                                                , value
                                                                    (newBookData.authors
                                                                        |> Array.get index
                                                                        |> Maybe.withDefault ""
                                                                    )
                                                                , onInput (\l -> GotNewBookMsg (ChangeAuthor index l))
                                                                , TW.apply
                                                                    [ border
                                                                    , border_gray_300
                                                                    , p_2
                                                                    , pl_3
                                                                    , w_full
                                                                    , rounded_md
                                                                    , rounded_r_none
                                                                    ]
                                                                ]
                                                                []
                                                            , if index > 0 then
                                                                button
                                                                    [ type_ "button"
                                                                    , onClick (GotNewBookMsg (RemoveAuthor index))
                                                                    , TW.apply
                                                                        [ bg_red_500
                                                                        , rounded_r_md
                                                                        , w_10
                                                                        , h_auto
                                                                        , p_1
                                                                        , hover [ bg_red_700 ]
                                                                        ]
                                                                    ]
                                                                    [ xOutline
                                                                        [ [ text_white
                                                                          ]
                                                                            |> String.join " "
                                                                            |> Svg.Attributes.class
                                                                        ]
                                                                    ]

                                                              else
                                                                text ""
                                                            ]
                                                        ]
                                                )
                                                newBookData.authors
                                            )
                                            ++ [ button
                                                    [ onClick (GotNewBookMsg AddAuthor)
                                                    , type_ "button"
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
                                                        , w_full
                                                        , text_center
                                                        ]
                                                    ]
                                                    [ p [ TW.apply [ w_full ] ] [ text "Add Author" ] ]
                                               ]
                                       )
                                )
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


removeFromList : Int -> List a -> List a
removeFromList i xs =
    List.take i xs ++ List.drop (i + 1) xs


removeFromArray : Int -> Array a -> Array a
removeFromArray i =
    Array.toList >> removeFromList i >> Array.fromList



-- Tailwind Helpers


column : List (Attribute msg) -> List (Html msg) -> Html msg
column attrs content =
    div (TW.apply [ flex, flex_col ] :: attrs) content


row : List (Attribute msg) -> List (Html msg) -> Html msg
row attrs content =
    div (TW.apply [ flex, flex_row ] :: attrs) content
