//
//  DetailsViewController.swift
//  PhotoGallery
//
//  Created by Olya Tilichenko on 26.03.2018.
//  Copyright © 2018 Olya Tilichenko. All rights reserved.
//

import UIKit
import Photos

class DetailsViewController: UIViewController, UITextFieldDelegate {
    
    var assetCollection: PHAssetCollection!
    var photosAsset: PHFetchResult<PHAsset>!
    var index: Int = 0
    var size: CGRect?

    @IBOutlet weak var textField: UITextField!
    @IBOutlet private weak var imageViewDetails: UIImageView!
    @IBOutlet weak var newImageView: UIView!
    
    override func viewDidLoad() {
        textField.delegate = self
        super.viewDidLoad()
        self.displayPhoto()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Actions
    
    @IBAction func editWithText(_ sender: Any) {
        textField.clearsOnBeginEditing = true
        textField.isHidden = false
        textField.becomeFirstResponder()
    }
    
    @IBAction func handlePan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.newImageView)
        if let view = recognizer.view {
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        }
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }
    
    
    @IBAction func handlePinch(recognizer: UIPinchGestureRecognizer){
        if let view = recognizer.view {
            view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            recognizer.scale = 1
        }
    }
    
    @IBAction func handleRotation(recognizer: UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
        }
    }
    
    @IBAction func saveImage() {

        guard let size = size else {
            return
        }
        UIGraphicsBeginImageContext(size.size)
        guard let image = imageViewDetails.image else {
            return
        }
        image.draw(in: size)
        newImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let imageWithText = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.imageViewDetails.image = imageWithText
        
        textField.isHidden = true
        DispatchQueue.global().async(execute: {
            PHPhotoLibrary.shared().performChanges({
                let createAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: imageWithText!)
                let assetPlaceholder = createAssetRequest.placeholderForCreatedAsset
                if let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection, assets: self.photosAsset) {
                    albumChangeRequest.addAssets([assetPlaceholder!] as NSArray)
                }
            }, completionHandler: {(success, error)in
                DispatchQueue.main.async(execute: {
                    print("Adding Image to Library -> %@", (success ? "Sucess":"Error!"))
                })
            })
        })
    }
    
    func displayPhoto() {

        let imageManager = PHImageManager.default()
        imageManager.requestImage(for: self.photosAsset[self.index], targetSize: imageViewDetails.frame.size, contentMode: .aspectFit, options: nil, resultHandler: {
            (result, info)->Void in
            self.imageViewDetails.image = result
        })
        guard let image = self.imageViewDetails.image else { return }
        let imagesize = image.size
        let imageviewsize = self.imageViewDetails.frame.size
        let sizeBeingScaledTo = AVMakeRect(aspectRatio: imagesize, insideRect: CGRect(origin: CGPoint(x: 0, y: 0), size: imageviewsize))
        self.size = sizeBeingScaledTo
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
