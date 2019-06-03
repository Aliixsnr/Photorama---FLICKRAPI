//
//  PhotoStore.swift
//  Photorama1
//
//  Created by Alex on 3/21/18.
//  Copyright © 2018 Yuhbok. All rights reserved.
//

import UIKit
import CoreData
enum TagsResult {
    case success([Tag])
    case failure(Error)
}
enum ImageResult {
    case success(UIImage)
    case failure(Error)
}
enum PhotoError: Error {
    case imageCreationError
}
enum PhotoResults {
    case success([Photo])
    case failure(Error)
}
// class is responsible for initaion the webservices request
class PhotoStore {
    let imageStore = ImageStore()
    
    let persistentContainer : NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Photorama")
        container.loadPersistentStores(completionHandler: { (description, error) in
            if let error = error {
                print("Error setting up Core Data \(error)")
            }
        })
        return container
        
    }()
    
    
    // this is what transferres the request to the server
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    func fetchInterestingPhotos(completion: @escaping (PhotoResults)-> Void) {
        let url = FlickrAPI.interestingPhotosURL
        let request = URLRequest(url: url)
        
        
        let task = session.dataTask(with: request){
            (data, response, error) -> Void in
//            if let httpStatus = response as? HTTPURLResponse {
//                print("Status Code: \(httpStatus.statusCode)")
//                print("HeaderFields: \(httpStatus.allHeaderFields)")
//            }
//            var results =  self.processPhotosRequest(data: data, error: error)
//            if case .success = results {
//                do {
//                    try self.persistentContainer.viewContext.save()
//                } catch let error {
//                    results = .failure(error)
//
//                }
//            }
//
//            OperationQueue.main.addOperation {
//                 completion(results)
//
//            }
            self.processPhotosRequest(data: data, error: error, completion: { (result) in
                OperationQueue.main.addOperation {
                    completion(result)
                }
            })
           
        }
        // task are always  created in a suspended state
        task.resume()
    }
    func fetchrecentPhotos(completion: @escaping (PhotoResults)-> Void) {
        let url = FlickrAPI.recentPhotosUrl
        let request = URLRequest(url: url)
        
        
        let task = session.dataTask(with: request){
            (data, response, error) -> Void in
//            if let httpStatus = response as? HTTPURLResponse {
//                print("Status Code: \(httpStatus.statusCode)")
//                print("HeaderFields: \(httpStatus.allHeaderFields)")
//            }
//            let results =  self.processPhotosRequest(data: data, error: error)
//
//            OperationQueue.main.addOperation {
//                completion(results)
//
//            }
            self.processPhotosRequest(data: data, error: error, completion: { (result) in
                OperationQueue.main.addOperation {
                    completion(result)
                }
            })
            
        }
        // task are always  created in a suspended state
        task.resume()
    }
    // Gets the data 
    private func processPhotosRequest(data: Data?, error: Error?, completion: @escaping (PhotoResults) -> Void) {
        guard let jsonData = data else {
           completion(.failure(error!))
            return
        }
        persistentContainer.performBackgroundTask { (context) in
            let result = FlickrAPI.photos(fromJSON: jsonData, into: context)
            
            do {
                try context.save()
            } catch {
                print("Error saving to core Data: \(error)")
                completion(.failure(error))
                return
            }
            switch result {
            case let .success(photos):
                // getting an array of all the objects assocaited with objects id
                let photoIDs = photos.map{return $0.objectID}
                let viewContext = self.persistentContainer.viewContext
                let viewContextPhotos = photoIDs.map{return viewContext.object(with: $0)} as! [Photo]
                completion(.success(viewContextPhotos))
            case .failure:
                completion(result)
            }
        }
    }
    func fetchImage(for photo: Photo, completion: @escaping (ImageResult) -> Void) {
        guard let photoKey = photo.photoID else {
            preconditionFailure("Photo expectded to gave a photoID")
        }
        if let image = imageStore.image(forKey: photoKey) {
            OperationQueue.main.addOperation {
                completion(.success(image))
            }
            return
        }
        guard let photoURL = photo.remoteURL else {
            preconditionFailure("Photo expcted to have a remote URL.")
        }
        let request = URLRequest(url: photoURL as URL)
        
        let task = session.dataTask(with: request){
            (data, response, error) -> Void in
            
            let result = self.processImageReqeust(data: data, error: error)
            if case let .success(image) = result {
                self.imageStore.setImage(image, forKey: photoKey)
                
            }
            OperationQueue.main.addOperation {
                 completion(result)
               
                
            }
           

            
        }
        task.resume()
    }
    // Process the image it self out of the data
    private func processImageReqeust(data: Data?, error: Error?)-> ImageResult {
        guard   let imagData = data,
                let image = UIImage(data: imagData) else {
            if data == nil {
                return .failure(error!)
            } else {
                return .failure(PhotoError.imageCreationError)
                
            }
        }
        return .success(image)
    }
    func fetchAllPhotos(completion: @escaping (PhotoResults) -> Void) {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortByDateTaken = NSSortDescriptor(key: #keyPath(Photo.dateTaken), ascending: true)
        fetchRequest.sortDescriptors = [sortByDateTaken]
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let allPhotos = try viewContext.fetch(fetchRequest)
                completion(.success(allPhotos))
            } catch {
                completion(.failure(error))
            }
        }
    }
    func saveContextIfNeeded() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            print("Save context")
            try? context.save()
        }
    }
    func fetchAllTags(completion: @escaping (TagsResult) -> Void){
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        let sortByName = NSSortDescriptor(key: #keyPath(Tag.name), ascending: true)
        fetchRequest.sortDescriptors = [sortByName]
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let allTags = try fetchRequest.execute()
                completion(.success(allTags))
            } catch {
                completion(.failure(error))
            }
        }
    }
  
}
