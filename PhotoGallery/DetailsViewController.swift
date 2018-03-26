//
//  DetailsViewController.swift
//  PhotoGallery
//
//  Created by Olya Tilichenko on 26.03.2018.
//  Copyright © 2018 Olya Tilichenko. All rights reserved.
//

import UIKit
import Photos

class DetailsViewController: UIViewController {
    
    var assetCollection: PHAssetCollection!
    var photosAsset: PHFetchResult<PHAsset>!
    var index: Int = 0

    @IBOutlet private weak var imageViewDetails: UIImageView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    
        self.displayPhoto()
    }
    
    func displayPhoto(){

        let screenSize: CGSize = UIScreen.main.bounds.size
        let targetSize = CGSize(width: screenSize.width, height: screenSize.height)
        let imageManager = PHImageManager.default()
        imageManager.requestImage(for: self.photosAsset[self.index], targetSize: targetSize, contentMode: .aspectFill, options: nil, resultHandler: {
            (result, info)->Void in
            self.imageViewDetails.image = result
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
