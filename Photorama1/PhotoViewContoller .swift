//
//  PhotoViewContoller .swift
//  Photorama1
//
//  Created by Alex on 3/21/18.
//  Copyright © 2018 Yuhbok. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController,UICollectionViewDelegate {
    @IBOutlet var collectionView: UICollectionView!
    var store: PhotoStore!
    var photoDataSource = PhotoDataSource()
    
    override func viewDidLoad() {
        collectionView.dataSource = photoDataSource
        collectionView.delegate = self
        
        self.updateDataSource()
        store.fetchInterestingPhotos { (photoResults) -> Void in
            self.updateDataSource()
        }
//        store.fetchrecentPhotos { (photoResults)-> Void in
//            self.updateDataSource()
//        }
    }
    private func updateDataSource(){
        store.fetchAllPhotos { (PhotosResult) in
            switch PhotosResult {
            case let .success(photos):
                self.photoDataSource.photos = photos
            case .failure:
                self.photoDataSource.photos.removeAll()
            }
            self.collectionView.reloadSections(IndexSet(integer: 0))
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photo = photoDataSource.photos[indexPath.row]
        // download the image data, which could take some time
        store.fetchImage(for: photo) { (result) -> Void in
    // The index path for the photo might have chanded between the time the request started and finished, so find the most recent index path
            guard let photoIndex = self.photoDataSource.photos.index(of: photo),
                case let .success(image) = result else {
                    return
            }
            let photoIndexPath = IndexPath(item: photoIndex, section: 0)
            if  let cell = self.collectionView.cellForItem(at: photoIndexPath) as? PhotoCollectionViewCell {
                cell.update(with: image)
                
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch  segue.identifier {
        case "showPhoto"?:
            if let selectedPath = collectionView.indexPathsForSelectedItems?.first {
                let photo = photoDataSource.photos [selectedPath.row]
                
                let destinationVC = segue.destination as! PhotoInfoViewController
                destinationVC.photo = photo
                destinationVC.store = store
                
              
                
            }
        default:
            preconditionFailure("Unexpected segue idetifier.")
        }
    }
    
}
