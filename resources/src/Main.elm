module Main exposing (main)

import Array exposing (Array)
import Browser
import Browser.Navigation as Nav
import File exposing (File)
import File.Select as Select
import Html exposing (..)
import Html.Attributes exposing (for, id, required, src, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit, preventDefaultOn)
import Json.Decode as JD
import Ports
import Svg
import Svg.Attributes
import SvgIcons
    exposing
        ( bookOpenOutline
        , photographOutline
        , plusOutline
        , plusSmOutline
        , solidPlus
        , thinPhotographOutline
        , xOutline
        )
import TailwindHelpers as TW exposing (..)
import Task
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


type NewBookStatus
    = NotCreating
    | EditingNewData NewBook
    | Creating NewBook


type alias NewBook =
    { title : String
    , authors : Array String
    , publishedDate : String
    , pages : String
    , dateFinishedReading : String
    , cover : Maybe File
    , coverUrl : Maybe String
    , isbn : String
    }


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , newBookData : NewBookStatus
    , state : State
    , hover : Bool
    }


type State
    = FetchingBooks
    | FetchedBooks (List Ports.Book)


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( { key = key
      , url = url
      , newBookData = NotCreating
      , state = FetchingBooks
      , hover = False
      }
    , Ports.sendRequestBooks ()
    )


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url.Url
    | AddNewBook
    | GotNewBookMsg NewBookMsg
    | GotBooks (Result JD.Error (List Ports.Book))
    | DragEnter
    | DragLeave
    | GotSendBase64ImageResponse (Result JD.Error Bool)
    | GotFiles File (List File)


type NewBookMsg
    = ChangeTitle String
    | AddAuthor
    | ChangeAuthor Int String
    | RemoveAuthor Int
    | ChangePublishedDate String
    | ChangePages String
    | ChangeReadDate String
    | ChangeISBN String
    | CoverLoaded File
    | RequestCover
    | GotCoverUrl String
    | RemoveCover
    | CreateNewBook


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
                    EditingNewData
                        { title = ""
                        , authors = Array.fromList [ "" ]
                        , publishedDate = ""
                        , pages = "1"
                        , dateFinishedReading = ""
                        , cover = Nothing
                        , coverUrl = Nothing
                        , isbn = ""
                        }
              }
            , Cmd.none
            )

        GotBooks res ->
            case res of
                Ok books ->
                    case model.newBookData of
                        Creating _ ->
                            ( { model | newBookData = NotCreating, state = FetchedBooks books }
                            , Cmd.none
                            )

                        NotCreating ->
                            ( { model | state = FetchedBooks books }
                            , Cmd.none
                            )

                        EditingNewData _ ->
                            ( { model | state = FetchedBooks books }
                            , Cmd.none
                            )

                Err _ ->
                    ( model, Cmd.none )

        DragEnter ->
            ( { model | hover = True }, Cmd.none )

        DragLeave ->
            ( { model | hover = False }, Cmd.none )

        GotFiles file files ->
            case model.newBookData of
                EditingNewData newBookData ->
                    ( { model
                        | newBookData =
                            EditingNewData
                                { newBookData
                                    | cover = Just file
                                }
                      }
                    , File.toUrl file |> Task.perform (\l -> GotNewBookMsg (GotCoverUrl l))
                    )

                NotCreating ->
                    ( model, Cmd.none )

                Creating _ ->
                    ( model, Cmd.none )

        GotSendBase64ImageResponse res ->
            case res of
                Ok _ ->
                    case model.newBookData of
                        Creating newBookData ->
                            ( model
                            , Ports.sendCreateNewBook
                                { title = newBookData.title
                                , authors = Array.toList newBookData.authors
                                , publishedDate = newBookData.publishedDate
                                , pages = newBookData.pages |> String.toInt |> Maybe.withDefault 0
                                , bookCoverPath = Just ("base64-cover-" ++ newBookData.isbn)
                                , dateFinishedReading =
                                    if newBookData.dateFinishedReading == "" then
                                        Nothing

                                    else
                                        Just newBookData.dateFinishedReading
                                , isbn = newBookData.isbn
                                }
                            )

                        NotCreating ->
                            ( model, Cmd.none )

                        EditingNewData _ ->
                            ( model, Cmd.none )

                -- TODO handle if failed to save image
                Err _ ->
                    ( model, Cmd.none )

        GotNewBookMsg newBookMsg ->
            case model.newBookData of
                EditingNewData newBookData ->
                    case newBookMsg of
                        ChangeTitle newTitle ->
                            ( { model | newBookData = EditingNewData { newBookData | title = newTitle } }
                            , Cmd.none
                            )

                        AddAuthor ->
                            ( { model
                                | newBookData =
                                    EditingNewData
                                        { newBookData
                                            | authors = Array.push "" newBookData.authors
                                        }
                              }
                            , Cmd.none
                            )

                        ChangeAuthor index newAuthor ->
                            ( { model
                                | newBookData =
                                    EditingNewData
                                        { newBookData
                                            | authors = Array.set index newAuthor newBookData.authors
                                        }
                              }
                            , Cmd.none
                            )

                        RemoveAuthor index ->
                            ( { model
                                | newBookData =
                                    EditingNewData
                                        { newBookData
                                            | authors = removeFromArray index newBookData.authors
                                        }
                              }
                            , Cmd.none
                            )

                        ChangePublishedDate newDate ->
                            ( { model
                                | newBookData =
                                    EditingNewData
                                        { newBookData
                                            | publishedDate = newDate
                                        }
                              }
                            , Cmd.none
                            )

                        ChangePages newPages ->
                            ( { model
                                | newBookData =
                                    EditingNewData
                                        { newBookData
                                            | pages = newPages
                                        }
                              }
                            , Cmd.none
                            )

                        ChangeReadDate newRead ->
                            ( { model
                                | newBookData =
                                    EditingNewData
                                        { newBookData
                                            | dateFinishedReading = newRead
                                        }
                              }
                            , Cmd.none
                            )

                        RequestCover ->
                            ( model, Cmd.map GotNewBookMsg (Select.file [ "image/*" ] CoverLoaded) )

                        CoverLoaded file ->
                            ( { model
                                | newBookData =
                                    EditingNewData
                                        { newBookData
                                            | cover = Just file
                                        }
                              }
                            , File.toUrl file |> Task.perform (\l -> GotNewBookMsg (GotCoverUrl l))
                            )

                        GotCoverUrl url ->
                            ( { model
                                | newBookData =
                                    EditingNewData
                                        { newBookData
                                            | coverUrl = Just url
                                        }
                              }
                            , Cmd.none
                            )

                        RemoveCover ->
                            ( { model
                                | newBookData =
                                    EditingNewData
                                        { newBookData
                                            | cover = Nothing
                                            , coverUrl = Nothing
                                        }
                              }
                            , Cmd.none
                            )

                        ChangeISBN newIsbn ->
                            ( { model
                                | newBookData =
                                    EditingNewData
                                        { newBookData
                                            | isbn = newIsbn
                                        }
                              }
                            , Cmd.none
                            )

                        CreateNewBook ->
                            case newBookData.coverUrl of
                                -- An image was uploaded...
                                Just coverUrl ->
                                    ( { model | newBookData = Creating newBookData }, Ports.sendBase64Image { data = coverUrl, name = newBookData.isbn } )

                                Nothing ->
                                    ( { model | newBookData = Creating newBookData }
                                    , Ports.sendCreateNewBook
                                        { title = newBookData.title
                                        , authors = Array.toList newBookData.authors
                                        , publishedDate = newBookData.publishedDate
                                        , pages = newBookData.pages |> String.toInt |> Maybe.withDefault 0
                                        , bookCoverPath = Nothing
                                        , dateFinishedReading =
                                            if newBookData.dateFinishedReading == "" then
                                                Nothing

                                            else
                                                Just newBookData.dateFinishedReading
                                        , isbn = newBookData.isbn
                                        }
                                    )

                NotCreating ->
                    ( model, Cmd.none )

                Creating _ ->
                    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Ports.booksReceiver (\l -> JD.decodeValue Ports.bookDecoder l |> GotBooks)
        , Ports.base64ImageConfirmationReceiver (\l -> JD.decodeValue JD.bool l |> GotSendBase64ImageResponse)
        ]


view : Model -> Browser.Document Msg
view model =
    { title = "Title"
    , body =
        [ row [ TW.apply [ bg_gray_100, h_screen, w_screen, overflow_auto ] ]
            [ --     div
              --     [ TW.apply
              --         [ overflow_auto
              --         , w_2_slash_3
              --         , grid
              --         , gap_x_3
              --         , sm [ grid_cols_2 ]
              --         , md [ grid_cols_3 ]
              --         , lg [ grid_cols_4 ]
              --         , xl [ grid_cols_5 ]
              --         , s2xl [ grid_cols_6 ]
              --         -- , md [ flex, flex_col ]
              --         ]
              --     ]
              --     [ book
              --     , book
              --     , book
              --     , book
              --     , book
              --     , book
              --     , book
              --     , book
              --     , book
              --     , book
              --     , book
              --     , book
              --     , book
              --     , book
              --     , book
              --     ]
              -- , bookDetails
              case model.state of
                FetchingBooks ->
                    p [ TW.apply [ block, m_auto, text_2xl ] ] [ text "Loading..." ]

                FetchedBooks fetchedBooks ->
                    case fetchedBooks of
                        [] ->
                            case model.newBookData of
                                EditingNewData newBookData ->
                                    form
                                        [ onSubmit (GotNewBookMsg CreateNewBook)
                                        , TW.apply
                                            [ shadow_md
                                            , rounded_md
                                            , p_4
                                            , bg_white
                                            , m_auto
                                            , w_96
                                            ]
                                        ]
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
                                                    , required True
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
                                                                            , required True
                                                                            , value author
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
                                                                [ p
                                                                    [ TW.apply [ w_full ]
                                                                    ]
                                                                    [ text "Add Author" ]
                                                                ]
                                                           , column []
                                                                [ label [ for "book-published-date" ] [ p [] [ text "Published Date" ] ]
                                                                , input
                                                                    [ id "book-published-date"
                                                                    , type_ "date"
                                                                    , value newBookData.publishedDate
                                                                    , required True
                                                                    , onInput (\l -> ChangePublishedDate l |> GotNewBookMsg)
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
                                                           , column []
                                                                [ label [ for "book-total-pages" ] [ p [] [ text "Total Pages" ] ]
                                                                , input
                                                                    [ id "book-total-pages"
                                                                    , type_ "number"
                                                                    , Html.Attributes.min "1"
                                                                    , value newBookData.pages
                                                                    , required True
                                                                    , onInput (\l -> ChangePages l |> GotNewBookMsg)
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
                                                           , column []
                                                                [ label [ for "book-read-date" ] [ p [] [ text "Read Date" ] ]
                                                                , input
                                                                    [ id "book-read-date"
                                                                    , type_ "date"
                                                                    , value newBookData.dateFinishedReading
                                                                    , required False
                                                                    , onInput (\l -> ChangeReadDate l |> GotNewBookMsg)
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
                                                           , column []
                                                                [ label [ for "book-isbn" ] [ p [] [ text "ISBN (International Standard Book Number)" ] ]
                                                                , input
                                                                    [ id "book-isbn"
                                                                    , type_ "number"
                                                                    , value newBookData.isbn
                                                                    , required True
                                                                    , onInput (\l -> ChangeISBN l |> GotNewBookMsg)
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
                                                           , case newBookData.cover of
                                                                Just coverImage ->
                                                                    row [ TW.apply [ justify_evenly ] ]
                                                                        [ img
                                                                            [ TW.apply
                                                                                [ bg_black
                                                                                , w_40
                                                                                , h_64
                                                                                , object_center
                                                                                , shrink_0
                                                                                , object_cover
                                                                                ]
                                                                            , src (newBookData.coverUrl |> Maybe.withDefault "")
                                                                            ]
                                                                            []
                                                                        , column [ TW.apply [ mt_auto, gap_y_2 ] ]
                                                                            [ blueButton
                                                                                [ type_ "button"
                                                                                , onClick (GotNewBookMsg RequestCover)
                                                                                ]
                                                                                [ text "Change Cover" ]
                                                                            , blueButton
                                                                                [ type_ "button"
                                                                                , onClick (GotNewBookMsg RemoveCover)
                                                                                ]
                                                                                [ text "Remove Cover" ]
                                                                            ]
                                                                        ]

                                                                Nothing ->
                                                                    column []
                                                                        [ p [] [ text "Book Cover" ]
                                                                        , div
                                                                            [ onClick (GotNewBookMsg RequestCover)
                                                                            , hijackOn "dragenter" (JD.succeed DragEnter)
                                                                            , hijackOn "dragover" (JD.succeed DragEnter)
                                                                            , hijackOn "dragleave" (JD.succeed DragLeave)
                                                                            , hijackOn "drop" dropDecoder
                                                                            , TW.apply
                                                                                [ h_64
                                                                                , w_full
                                                                                , rounded_md
                                                                                , border_dashed
                                                                                , border_gray_300
                                                                                , border_2
                                                                                , flex
                                                                                , cursor_pointer
                                                                                , if model.hover then
                                                                                    border_blue_300

                                                                                  else
                                                                                    ""
                                                                                ]
                                                                            ]
                                                                            [ column [ TW.apply [ m_auto, pointer_events_none ] ]
                                                                                [ div [ TW.apply [ relative, w_16, h_16, m_auto ] ]
                                                                                    [ thinPhotographOutline
                                                                                        [ [ text_gray_400
                                                                                          , if model.hover then
                                                                                                text_blue_300

                                                                                            else
                                                                                                ""
                                                                                          ]
                                                                                            |> String.join " "
                                                                                            |> Svg.Attributes.class
                                                                                        ]
                                                                                    , solidPlus
                                                                                        [ [ absolute
                                                                                          , bg_white
                                                                                          , rounded_full
                                                                                          , text_gray_400
                                                                                          , w_6
                                                                                          , h_6
                                                                                          , bottom_0
                                                                                          , right_0
                                                                                          , if model.hover then
                                                                                                text_blue_300

                                                                                            else
                                                                                                ""
                                                                                          ]
                                                                                            |> String.join " "
                                                                                            |> Svg.Attributes.class
                                                                                        ]
                                                                                    ]
                                                                                , p [ TW.apply [ font_bold ] ] [ text "Choose or drag an image" ]
                                                                                ]
                                                                            ]
                                                                        ]
                                                           , row []
                                                                [ button
                                                                    [ type_ "submit"
                                                                    , TW.apply
                                                                        [ flex
                                                                        , px_3
                                                                        , py_2
                                                                        , gap_x_2
                                                                        , font_semibold
                                                                        , block
                                                                        , rounded
                                                                        , ml_auto
                                                                        , text_white
                                                                        , shadow_md
                                                                        , bg_blue_600
                                                                        , hover [ bg_blue_700 ]
                                                                        ]
                                                                    ]
                                                                    [ text "Add Book" ]
                                                                ]
                                                           ]
                                                   )
                                            )
                                        ]

                                NotCreating ->
                                    simpleEmptyState
                                        { mainIcon = bookOpenOutline
                                        , title = "No books"
                                        , subtitle = "Get started by adding a book"
                                        , buttonText = "Add book"
                                        , buttonIcon = Just plusOutline
                                        , buttonMsg = AddNewBook
                                        }

                                Creating _ ->
                                    p [ TW.apply [ block, m_auto, text_2xl ] ] [ text "Creating book..." ]

                        first :: rest ->
                            text ""
            ]
        ]
    }


bookDetails =
    column
        [ TW.apply
            [ h_full
            , bg_black
            , w_1_slash_3
            , pt_14
            , px_12
            , pb_6
            , text_white
            , items_center
            , gap_y_8
            ]
        ]
        [ p
            [ TW.apply
                [ text_2xl
                , font_semibold
                ]
            ]
            [ text "Book Details" ]
        , img
            [ src "https://ia800604.us.archive.org/view_archive.php?archive=/7/items/olcovers68/olcovers68-L.zip&file=680401-L.jpg"
            , TW.apply
                [ object_center
                , shrink_0
                , object_cover
                , rounded_2xl
                , overflow_hidden
                , h_96
                , w_60
                ]
            ]
            []
        , column [ TW.apply [ text_center ] ]
            [ p [ TW.apply [ text_3xl, font_semibold ] ] [ text "Klan-destine Relationships: A Black Man's Odyssey in the Ku Klux Klan" ]
            , p [ TW.apply [ text_2xl, font_medium, mt_1, opacity_50 ] ] [ text "Daryl Davis" ]
            ]
        , div
            [ TW.apply
                [ bg_gray_900
                , p_6
                , rounded_md
                , text_center
                , w_32
                ]
            ]
            [ p
                [ TW.apply
                    [ text_white
                    , text_2xl
                    ]
                ]
                [ text "200" ]
            , p [ TW.apply [ text_gray_400 ] ] [ text "pages" ]
            ]
        , div [ TW.apply [ overflow_hidden ] ]
            [ p [ TW.apply [ text_xl, font_bold, mb_2 ] ] [ text "Plot" ]
            , div [ TW.apply [ overflow_x_auto, h_full, text_lg ] ]
                [ text
                    "While marching in a cub-scout parade, young Daryl Davis was pelted by rocks and bottles. As a teenager he was told he would be shipped back to Africa. Driven by an intense need to understand those who hate him because of the colour of his skin, Davis decided to seek out the roots of racism."
                ]
            ]
        ]


book =
    column
        [ TW.apply
            [ hover [ bg_blue_500, text_white ]
            , p_4
            , rounded_2xl
            , cursor_pointer
            ]
        ]
        [ img
            [ src "https://ia800604.us.archive.org/view_archive.php?archive=/7/items/olcovers68/olcovers68-L.zip&file=680401-L.jpg"
            , TW.apply
                [ object_center
                , object_cover
                , rounded_2xl
                , overflow_hidden
                ]
            ]
            []
        , p
            [ TW.apply
                [ mt_3
                , font_semibold
                , text_lg
                ]
            ]
            [ text "Klan-destine Relationships: A Black Man's Odyssey in the Ku Klux Klan" ]
        , p [ TW.apply [ font_semibold, mt_1, text_gray_400 ] ] [ text "Daryl Davis" ]
        ]


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


blueButton attrs content =
    button
        ([ TW.apply
            [ px_3
            , py_2
            , gap_x_2
            , font_semibold
            , block
            , rounded
            , text_white
            , shadow_md
            , bg_blue_600
            , hover [ bg_blue_700 ]
            ]
         ]
            ++ attrs
        )
        content



-- Tailwind Helpers


column : List (Attribute msg) -> List (Html msg) -> Html msg
column attrs content =
    div (TW.apply [ flex, flex_col ] :: attrs) content


row : List (Attribute msg) -> List (Html msg) -> Html msg
row attrs content =
    div (TW.apply [ flex, flex_row ] :: attrs) content



-- https://elm-lang.org/examples/drag-and-drop


dropDecoder : JD.Decoder Msg
dropDecoder =
    JD.at [ "dataTransfer", "files" ] (JD.oneOrMore GotFiles File.decoder)


hijackOn : String -> JD.Decoder msg -> Attribute msg
hijackOn event decoder =
    preventDefaultOn event (JD.map hijack decoder)


hijack : msg -> ( msg, Bool )
hijack msg =
    ( msg, True )
