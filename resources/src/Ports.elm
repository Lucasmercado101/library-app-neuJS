port module Ports exposing (..)

import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE


port sendRequestBooks : () -> Cmd msg


port booksReceiver : (JE.Value -> msg) -> Sub msg


port sendCreateNewBook : NewBook -> Cmd msg


type alias NewBook =
    { title : String
    , authors : List String
    , publishedDate : String
    }


type alias Book =
    { title : String
    , authors : List String
    , publishedDate : String
    , dateFinishedReading : Maybe String
    , pages : Int
    }


bookDecoder : Decoder (List Book)
bookDecoder =
    JD.list
        (JD.map5 Book
            (JD.field "title" JD.string)
            (JD.field "authors" (JD.list JD.string))
            (JD.field "publishedDate" JD.string)
            (JD.field "dateFinishedReading" (JD.maybe JD.string))
            (JD.field "pages" JD.int)
        )
