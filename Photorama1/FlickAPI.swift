//
//  FlickAPI.swift
//  Photorama1
//
//  Created by Alex on 3/21/18.
//  Copyright © 2018 Yuhbok. All rights reserved.
//

import Foundation
import CoreData
enum FlickrError:Error {
    case invalidJSONData
}
enum Method:String {
    //This is the endpoint on the flickr server, meaning what and you are looking for
    case interestingPhotos = "flickr.interestingness.getList"
    case recentPhotos = "flickr.photos.getRecent"
   
}
struct FlickrAPI{
  private static let baseUrlString = "https://api.flickr.com/services/rest"
  private static let apiKey = "a6d819499131071f158fd740860a5a88"
  private static func flickrUrl(method: Method, parameters: [String:String]?)-> URL{
        // instance of the base url and this is what creates the final url so everyone has to go to him 
        var components = URLComponents(string: baseUrlString)!
        var queryItems = [URLQueryItem]()
        let baseParams = ["method": method.rawValue, "format": "json", "nojsoncallback": "1", "api_key": apiKey]
        for (key, value) in baseParams {
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        
        
        // if there is adiational parameters that are needed it will be constructed from this also
        if let additionalParams = parameters {
            for(key, value) in additionalParams {
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
        }
    print(queryItems)
    
        components.queryItems = queryItems
    
        return components.url!
        
  
    }
    static var interestingPhotosURL: URL {
        // this method will pass the information in that needs to make up the url for interestingPhotos
        return flickrUrl(method: .interestingPhotos, parameters: ["extras": "url_h,date_taken"])
    }
    static var recentPhotosUrl : URL {
        return flickrUrl(method: .recentPhotos, parameters: ["extras" : "url_h,date_taken"])
    }
    static func photos(fromJSON data: Data, into context: NSManagedObjectContext) -> PhotoResults{
        do {
         let jsonObject =  try JSONSerialization.jsonObject(with: data, options: [])
            guard
                // this is to dig in throughnt the strucutre of informtion to get the array of photos only
            let jsonDictionary = jsonObject as? [AnyHashable: Any],
            let photos = jsonDictionary["photos"] as? [String:Any],
            let photosaArray = photos["photo"] as? [[String:Any]] else {
                // If THE JSON strucutre doesn't math our expectations
                return .failure(FlickrError.invalidJSONData)
            }
            var finalPhotos = [Photo]()
            for photoJSON  in photosaArray {
                if let photo = photo(fromJSON: photoJSON, into: context){
                    finalPhotos.append(photo)
                }
            
            }
            // Final photos that would contaainted the parsed out photos and the photos array is no then there is and error in parising out
           if finalPhotos.isEmpty && !photosaArray.isEmpty {
                return .failure(FlickrError.invalidJSONData)
            }
            return .success(finalPhotos)
        } catch let error {
            return .failure(error)
        }
        
    }
    // this closures formats the date of the text
    private static let dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
        
    }()
    private static func photo(fromJSON json:[String:Any], into context: NSManagedObjectContext) ->Photo? {
        guard
        let PhotoID = json["id"] as? String,
        let title = json["title"] as? String,
        let dateString = json["datetaken"] as? String,
        let photoURLString = json["url_h"] as? String,
        let url = URL(string: photoURLString),
        let dateTaken = dateFormatter.date(from: dateString)
        else {
            return nil
        }
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "\(#keyPath(Photo.photoID)) == \(PhotoID)")
        fetchRequest.predicate = predicate
        
        var fetchedPhotos: [Photo]?
        context.performAndWait {
            fetchedPhotos = try? fetchRequest.execute()
        }
        if let existingPhoto = fetchedPhotos?.first {
            return existingPhoto
        }
        
        var photo : Photo!
        context.performAndWait {
            photo = Photo(context: context)
            photo.title = title
            photo.photoID = PhotoID
            photo.remoteURL = url as NSURL
            photo.dateTaken = dateTaken as NSDate
            photo.views = 0
        }
        return photo
    }
    
    
    
}








