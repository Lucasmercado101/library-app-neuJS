port module Ports exposing (..)

import File exposing (File)
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE


port sendRequestBooks : () -> Cmd msg


port booksReceiver : (JE.Value -> msg) -> Sub msg


port sendCreateNewBook : Book -> Cmd msg


type alias Book =
    { title : String
    , authors : List String
    , publishedDate : String
    , dateFinishedReading : Maybe String
    , pages : Int
    , bookCoverPath : String
    , isbn : String
    }


bookDecoder : Decoder (List Book)
bookDecoder =
    JD.list
        (JD.map7 Book
            (JD.field "title" JD.string)
            (JD.field "authors" (JD.list JD.string))
            (JD.field "publishedDate" JD.string)
            (JD.field "dateFinishedReading" (JD.maybe JD.string))
            (JD.field "pages" JD.int)
            (JD.field "bookCoverPath" JD.string)
            (JD.field "isbn" JD.string)
        )
