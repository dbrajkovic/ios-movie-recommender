//
//  Constants.swift
//  movie-rec
//
//  Created by Eric Drew on 3/19/16.
//  Copyright © 2016 Eric Drew. All rights reserved.
//

import Foundation
import UIKit

let DETAIL_SEGUE = "detailVC"
let FILTER_SEGUE = "filterVC"

let SIMILAR_CELL_ID = "similarCell"
let CATEGORY_CELL_ID = "categoryCell"
let SEARCH_CELL_ID = "searchCell"
let HISTORY_CELL_ID = "historyCell"

let IMDB_BASE_URL = "http://www.imdb.com/title/tt"

let API_URL = "https://api.themoviedb.org/3/movie/{0}?api_key=d585fab38c369ab218614ebc8d228d6f"
let BASE_IMG_URL = "http://image.tmdb.org/t/p/original/"

let SIM_API_URL_BASE = "https://stately-forest-126023.appspot.com/_ah/api/movierec/v1/similarMovie/"
let REC_API_URL_BASE = "https://stately-forest-126023.appspot.com/_ah/api/movierec/v1/movieRec/"

let BLUE_COLOR = UIColor(colorLiteralRed: 0.0/255.0, green: 145.0/255.0, blue: 234/255.0, alpha: 1.0)
let DARK_COLOR = UIColor(colorLiteralRed: 33.0/255.0, green: 33.0/255.0, blue: 33.0/255.0, alpha: 1.0)
let EXTRA_LIGHT_COLOR = UIColor(colorLiteralRed: 99.0/255.0, green: 99.0/255.0, blue: 99.0/255.0, alpha: 1.0)

let HISTORY_FILE_NAME = "history.txt"

let MOVIE_TAB_INDEX = 1

let UID_KEY = "UID_KEY"
let FIREBASE_REF = "https://movie-rec.firebaseIO.com"

var UID: String? {
    return NSUserDefaults.standardUserDefaults().valueForKey(UID_KEY) as? String
}
