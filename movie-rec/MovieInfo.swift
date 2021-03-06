//
//  MovieInfo.swift
//  movie-rec
//
//  Created by Eric Drew on 3/21/16.
//  Copyright © 2016 Eric Drew. All rights reserved.
//

import Foundation
import Alamofire

class MovieInfo {
    static let instance = MovieInfo()
    
    private var _infoAr = [Movie]()
    private var _historyDict = Dictionary<History, CGFloat>()
    private var _categories = Dictionary<String, Bool>()
    private var _movieIdDict = Dictionary<String, Movie>()
    
    var movieList: [Movie] {
        return _infoAr
    }
    
    var historyList: [History] {
        return Array(_historyDict.keys)
    }
    
    var historySet: Dictionary<History, CGFloat> {
        return _historyDict
    }
    
    var categoryList: [String] {
        return Array(_categories.keys)
    }
    
    init() {
        movieTitles()
        loadHistory()
        loadcategories()
    }
    
    func getSimilarAr(movie: Movie, completion: (movieAr: Array<Similar>) -> ()) {
        var result = [Similar]()
        let id = movie.movieId
        let urlStr = SIM_API_URL_BASE + "\(id)"
        Alamofire.request(.GET, urlStr).responseJSON(completionHandler: { response in
            if let json = response.result.value as? Dictionary<String, AnyObject> {
                if let ar = json["items"] as? Array<String> {
                    for i in 0..<10 {
                        let movieId = ar[i]
                        if let mov = self._movieIdDict[movieId] {
                            result.append(Similar(index: i+1, movie: mov))
                        }
                    }
                    completion(movieAr: result)
                }
            }
        })
    }
    
    func getRec(completionBlock: (mov: Movie) -> ()) {
        let urlStr = REC_API_URL_BASE + "2"
        Alamofire.request(.GET, urlStr).responseJSON(completionHandler: { response in
            if let json = response.result.value as? Dictionary<String, AnyObject> {
                if let movieId = json["movieId"] as? String {
                    if let mov = self._movieIdDict[movieId] {
                        let index = Int(arc4random_uniform(UInt32(self._infoAr.count)))
                        completionBlock(mov: self._infoAr[index])
                        //completionBlock(mov: mov)
                    }
                }
            }
        })
    }
    
    func movieTitles() {
        if let path = NSBundle.mainBundle().pathForResource("movieInfo", ofType: "csv") {
            do {
                var file = try NSString(contentsOfFile: path, encoding: NSASCIIStringEncoding)
                file = file.stringByReplacingOccurrencesOfString("\r", withString: "\n")
                file = file.stringByReplacingOccurrencesOfString("\n\n", withString: "\n")
                let rowAr = file.componentsSeparatedByString("\n")
                for row in rowAr {
                    var doubleQuote = row.componentsSeparatedByString("\"")
                    if doubleQuote.count > 1 {
                        let title = doubleQuote[1..<doubleQuote.count-1]
                        var col = (doubleQuote[0] + doubleQuote[doubleQuote.count-1]).componentsSeparatedByString(",")
                        col[1] = title.joinWithSeparator("")
                        let mov = Movie(movieId: col[0], title: col[1], genres: col[2], imdbId: col[3], tmdbId: col[4])
                        _movieIdDict[mov.movieId] = mov
                        _infoAr.append(mov)
                        
                    } else {
                        let col = row.componentsSeparatedByString(",")
                        let mov = Movie(movieId: col[0], title: col[1], genres: col[2], imdbId: col[3], tmdbId: col[4])
                        _movieIdDict[mov.movieId] = mov
                        _infoAr.append(mov)
                    }
                }
            } catch let error as NSError {
                print(error.debugDescription)
            }
        } else {
            print("no path")
        }
        _infoAr.removeAtIndex(0)
    }
    
    func loadHistory() {
        let documentDirectoryURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
        let historyUrl = documentDirectoryURL.URLByAppendingPathComponent(HISTORY_FILE_NAME)
        
        _historyDict = [:]
        if let resAr: [History] = NSKeyedUnarchiver.unarchiveObjectWithFile(historyUrl.path!) as? [History] {
            for item in resAr {
                _historyDict[item] = item.rating
            }
        }
    }
    
    func loadcategories() {
        for movie in _infoAr {
            for cat in movie.genres {
                if cat != "(no genres listed)" {
                    _categories[cat] = true
                }
            }
        }
    }
    
    func saveHistory() {
        let documentDirectoryURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        let historyUrl = documentDirectoryURL.URLByAppendingPathComponent(HISTORY_FILE_NAME)
        let result = NSKeyedArchiver.archiveRootObject(historyList, toFile: historyUrl.path!)
        print("saving data worked: \(result)")
    }
    
    func addReview(movie: History) {
        _historyDict[movie] = movie.rating
    }
    
    func removeReview(movie: History) {
        _historyDict.removeValueForKey(movie)
    }
    
    func retrieveData(tmdbId: String, completion: (image: UIImage) -> ()) {
        let urlString = API_URL.stringByReplacingOccurrencesOfString("{0}", withString: tmdbId)
        if let url = NSURL(string: urlString) {
            Alamofire.request(.GET, url).responseJSON { response in
                if let json = response.result.value as? Dictionary<String, AnyObject> {
                    if let postPath = json["poster_path"] as? String {
                        Alamofire.request(.GET, BASE_IMG_URL+postPath).response { request, response, data, error in
                            if let img = UIImage(data: data!) {
                                completion(image: img)
                            } else {
                                print("could not load image from data")
                            }
                        }
                    } else {
                        if let collection = json["belongs_to_collection"] as? Dictionary<String, AnyObject> {
                            if let postPath = collection["poster_path"] as? String {
                                Alamofire.request(.GET, BASE_IMG_URL+postPath).response { request, response, data, error in
                                    if let img = UIImage(data: data!) {
                                        completion(image: img)
                                    } else {
                                        print("could not load image from data")
                                    }
                                }
                            } else {
                                print("could not parse collection json")
                            }
                        } else {
                            print("could not parse json")
                        }
                    }
                } else {
                    print("could not parse response")
                }
            }
        } else {
            print(urlString)
        }
    }
    
}



