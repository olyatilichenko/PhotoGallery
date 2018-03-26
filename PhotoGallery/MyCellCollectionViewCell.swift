//
//  MyCellCollectionViewCell.swift
//  PhotoGallery
//
//  Created by Olya Tilichenko on 26.03.2018.
//  Copyright © 2018 Olya Tilichenko. All rights reserved.
//

import UIKit

class MyCellCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func setImage(_ image: UIImage) {
        self.imageView.image = image
    }
}
