module SvgIcons exposing (..)

import Html exposing (Html)
import Svg
import Svg.Attributes as SA



--  https://heroicons.com/


bookOpenOutline : List (Svg.Attribute msg) -> Html msg
bookOpenOutline attrs =
    Svg.svg
        ([ SA.fill "none"
         , SA.viewBox "0 0 24 24"
         , SA.stroke "currentColor"
         ]
            ++ attrs
        )
        [ Svg.path
            [ SA.strokeLinecap "round"
            , SA.strokeLinejoin "round"
            , SA.strokeWidth "2"
            , SA.d "M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"
            ]
            []
        ]


bookOpenSolid : List (Svg.Attribute msg) -> Html msg
bookOpenSolid attrs =
    Svg.svg
        ([ SA.viewBox "0 0 20 20"
         , SA.fill "currentColor"
         ]
            ++ attrs
        )
        [ Svg.path
            [ SA.d "M9 4.804A7.968 7.968 0 005.5 4c-1.255 0-2.443.29-3.5.804v10A7.969 7.969 0 015.5 14c1.669 0 3.218.51 4.5 1.385A7.962 7.962 0 0114.5 14c1.255 0 2.443.29 3.5.804v-10A7.968 7.968 0 0014.5 4c-1.255 0-2.443.29-3.5.804V12a1 1 0 11-2 0V4.804z" ]
            []
        ]


plusOutline : List (Svg.Attribute msg) -> Html msg
plusOutline attrs =
    Svg.svg
        ([ SA.fill "none"
         , SA.viewBox "0 0 24 24"
         , SA.stroke "currentColor"
         ]
            ++ attrs
        )
        [ Svg.path
            [ SA.strokeLinecap "round"
            , SA.strokeLinejoin "round"
            , SA.strokeWidth "2"
            , SA.d "M12 4v16m8-8H4"
            ]
            []
        ]


xOutline : List (Svg.Attribute msg) -> Html msg
xOutline attrs =
    Svg.svg
        ([ SA.fill "none"
         , SA.viewBox "0 0 24 24"
         , SA.stroke "currentColor"
         ]
            ++ attrs
        )
        [ Svg.path
            [ SA.strokeLinecap "round"
            , SA.strokeLinejoin "round"
            , SA.strokeWidth "2"
            , SA.d "M6 18L18 6M6 6l12 12"
            ]
            []
        ]


photographOutline : List (Svg.Attribute msg) -> Html msg
photographOutline attrs =
    Svg.svg
        ([ SA.fill "none"
         , SA.viewBox "0 0 24 24"
         , SA.stroke "currentColor"
         ]
            ++ attrs
        )
        [ Svg.path
            [ SA.strokeLinecap "round"
            , SA.strokeLinejoin "round"
            , SA.strokeWidth "2"
            , SA.d "M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"
            ]
            []
        ]


thinPhotographOutline : List (Svg.Attribute msg) -> Html msg
thinPhotographOutline attrs =
    Svg.svg
        ([ SA.fill "none"
         , SA.viewBox "0 0 24 24"
         , SA.stroke "currentColor"
         ]
            ++ attrs
        )
        [ Svg.path
            [ SA.strokeLinecap "round"
            , SA.strokeLinejoin "round"
            , SA.strokeWidth "1"
            , SA.d "M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"
            ]
            []
        ]


plusSmOutline : List (Svg.Attribute msg) -> Html msg
plusSmOutline attrs =
    Svg.svg
        ([ SA.fill "none"
         , SA.viewBox "0 0 24 24"
         , SA.stroke "currentColor"
         ]
            ++ attrs
        )
        [ Svg.path
            [ SA.strokeLinecap "round"
            , SA.strokeLinejoin "round"
            , SA.strokeWidth "2"
            , SA.d "M12 6v6m0 0v6m0-6h6m-6 0H6"
            ]
            []
        ]


solidPlus : List (Svg.Attribute msg) -> Html msg
solidPlus attrs =
    Svg.svg
        ([ SA.viewBox "0 0 20 20"
         , SA.fill "currentColor"
         ]
            ++ attrs
        )
        [ Svg.path
            [ SA.fillRule "evenodd"
            , SA.d "M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z"
            , SA.clipRule "evenodd"
            ]
            []
        ]
