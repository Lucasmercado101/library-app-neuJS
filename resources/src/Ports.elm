module Ports exposing (..)

import Json.Decode exposing (Decoder)
import Json.Encode as JE


port sendRequestBooks : () -> Cmd msg


port booksReceiver : (JE.Value -> msg) -> Sub msg


type alias Book =
    { title : String
    , authors : List String
    , publishedDate : String
    , dateFinishedReading : String
    , pages : Int
    }
