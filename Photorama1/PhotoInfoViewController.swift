//
//  PhotoInfoViewController.swift
//  Photorama1
//
//  Created by Alex on 3/25/18.
//  Copyright © 2018 Yuhbok. All rights reserved.
//

import UIKit

class PhotoInfoViewController: UIViewController {
    @IBOutlet var pictureViews: UILabel!
    @IBOutlet var imageView: UIImageView!
    var photoViews: Int16 = 0 {
        didSet {
            photo.views = photoViews
            store.saveContextIfNeeded()
            self.pictureViews.text = "Views: \(photoViews)"
            
        }
    }
    var views: Int16 = 0 {
        didSet {
            photoViews = views + photo.views
            
        }
    }
    var store : PhotoStore!
    var photo : Photo! {
        didSet {
            navigationItem.title = photo.title
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.accessibilityLabel = photo.title
        views += 1
        store.saveContextIfNeeded()
        store.fetchImage(for: photo) { (result) -> Void  in
            switch result {
            case  let .success(image):
                self.imageView.image = image
                
            case let .failure(error):
                print("Error fetuching image for photo : \(error)")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showTags"?:
            let navController = segue.destination as! UINavigationController
            let tagController = navController.topViewController as! TagsViewController
            
            tagController.store = store
            tagController.photo = photo
        default:
           preconditionFailure("Unexpectd segue idetifier.")
        }
    }
    
    
}
