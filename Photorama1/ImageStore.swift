//
//  ImageStore.swift
//  Homepwner
//
//  Created by Alex on 3/18/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import UIKit
class ImageStore {
    // cache is of objective c so hence the reason for using NSstring
    let cache = NSCache<NSString,UIImage>()
    
    func setImage(_ image: UIImage, forKey key:String)  {
        cache.setObject(image, forKey: key as NSString)
        // creare full url for image
        let url = imageUrl(forKey: key)
        
    // turn image into JPEG DATA
        if let data = image.jpegData(compressionQuality: 0.5){
            // write it to url
            try? data.write(to: url, options: .atomic)
        }
        
//        // turn image in to png
//        if let data = UIImagePNGRepresentation(image) {
//            // then writing to url
//            try? data.write(to: url, options: .atomic)
//
//        }
        
    }
    func image(forKey key:String) -> UIImage? {
//        return cache.object(forKey: key as NSString)
        if let existingImage = cache.object(forKey: key as NSString){
            return existingImage
        }
        let url = imageUrl(forKey: key)
        guard let imageFromDisk = UIImage.init(contentsOfFile: url.path) else {
            return nil
            
        }
        cache.setObject(imageFromDisk, forKey: key  as NSString)
        return imageFromDisk
    }
    func deleteImage(forkey key:String)  {
        cache.removeObject(forKey: key as NSString)
        let url = imageUrl(forKey: key)
        do {
            try FileManager.default.removeItem(at: url)
        } catch let deleteError {
            print("Error removing the image from disk: \(deleteError)")
        }
    }
    func imageUrl(forKey key: String) -> URL {
        let documentsDirectories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirector = documentsDirectories.first!
        return documentDirector.appendingPathComponent(key)
    }
 
}
