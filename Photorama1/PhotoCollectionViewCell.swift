//
//  PhotoCollectionViewCell.swift
//  Photorama1
//
//  Created by Alex on 3/25/18.
//  Copyright © 2018 Yuhbok. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    var photoDescription: String?
    
    override var accessibilityLabel: String? {
        get {
            return photoDescription
        } set {
            // Ignore attempts to set
        }
    }
    override var accessibilityTraits: UIAccessibilityTraits {
        get {
            return UIAccessibilityTraits(rawValue: super.accessibilityTraits.rawValue | UIAccessibilityTraits.image.rawValue)
        } set {
            // ignore attempts
        }
    }
    
    override var isAccessibilityElement: Bool {
        get {
            return true
        } set {
            
            super.isAccessibilityElement = newValue
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Let the spinner we on when the cell is just being created
        update(with: nil)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        update(with: nil)
    }
    
    func update(with image: UIImage?){
        if let imageToDisplay = image {
            spinner.stopAnimating()
            imageView.image = imageToDisplay
        } else {
            spinner.startAnimating()
            imageView.image = nil
        }
    }
}
