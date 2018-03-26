//
//  GalleryViewController.swift
//  PhotoGallery
//
//  Created by Olya Tilichenko on 26.03.2018.
//  Copyright © 2018 Olya Tilichenko. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "Cell"
let albumName = "MyApp"

class GalleryViewController: UICollectionViewController, UIActionSheetDelegate {
    
    var assetCollection: PHAssetCollection!
    var photosAsset: PHFetchResult<PHAsset>!
    var albumFound: Bool = false
    var assetThumbnailSize:CGSize!

    override func viewDidLoad() {
        super.viewDidLoad()

        //Check if the folder exist, if not, create it
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        
        let collection:PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if(collection.firstObject != nil){
            //found the album
            self.albumFound = true
            self.assetCollection = collection.firstObject
        }else{
            //Album placeholder for the asset collection, used to reference collection in completion handler
            var albumPlaceholder:PHObjectPlaceholder!
            //create the folder
            NSLog("\nFolder \"%@\" does not exist\nCreating now...", albumName)
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
                albumPlaceholder = request.placeholderForCreatedAssetCollection
            },
                completionHandler: {(success:Bool, error:Error?) in
                    if(success){
                        print("Successfully created folder")
                        self.albumFound = true
                        let collection = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [albumPlaceholder.localIdentifier], options: nil)
                        self.assetCollection = collection.firstObject!
                        }else{
                            print("Error creating folder")
                            self.albumFound = false
                        }
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Get size of the collectionView cell for thumbnail image
        if let layout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout{
            let cellSize = layout.itemSize
            self.assetThumbnailSize = CGSize(width: cellSize.width, height: cellSize.height)
        }
        
        //fetch the photos from collection
        if(assetCollection != nil ) {//!! Use optional chaining
        self.photosAsset = PHAsset.fetchAssets(in: self.assetCollection, options: nil)
        }
        
        self.collectionView?.reloadData()
    }

    @IBAction func cameraShow(_ sender: Any) {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            //load the camera interface
            let picker : UIImagePickerController = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            picker.allowsEditing = false
            self.present(picker, animated: true, completion: nil)
        }else{
            //no camera available
            let alert = UIAlertController(title: "Error", message: "There is no camera available", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {(alertAction)in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count: Int = 0
        if(self.photosAsset != nil){
            count = self.photosAsset.count
        }
        return count;
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MyCellCollectionViewCell
    
        // Configure the cell
    
        let asset: PHAsset = self.photosAsset[indexPath.item]
        PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil, resultHandler: {(result, info)in
            if let image = result {
                cell.setImage(image)
            }
        })
        return cell
    }

    // MARK: UICollectionViewDelegate

    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]){
        NSLog("in didFinishPickingMediaWithInfo")
        if let image: UIImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {
                PHPhotoLibrary.shared().performChanges({
                    let createAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    let assetPlaceholder = createAssetRequest.placeholderForCreatedAsset
                    if let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection, assets: self.photosAsset) {
                        albumChangeRequest.addAssets([assetPlaceholder!] as NSArray)
                    }
                }, completionHandler: {(success, error)in
                    DispatchQueue.main.async(execute: {
                        NSLog("Adding Image to Library -> %@", (success ? "Sucess":"Error!"))
                        picker.dismiss(animated: true, completion: nil)
                    })
                })
                
            })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showDetail") {
            if let controller: DetailsViewController = segue.destination as? DetailsViewController{
                if let cell = sender as? UICollectionViewCell{
                    if let indexPath: IndexPath = self.collectionView!.indexPath(for: cell) {
                        controller.index = indexPath.item
                        controller.photosAsset = self.photosAsset
                        controller.assetCollection = self.assetCollection
                    }
                }
                }
            }
        if(segue.identifier == "showMap") {
            if let controller: MapViewController = segue.destination as? MapViewController{
                if let cell = sender as? UICollectionViewCell{
                    if let indexPath: IndexPath = self.collectionView!.indexPath(for: cell) {
                        controller.index = indexPath.item
                        controller.photosAsset = self.photosAsset
                        controller.assetCollection = self.assetCollection
                    }
                }
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath);
        let alert = UIAlertController(title: "Actions:", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Details", style: .default, handler: {_ in
            self.performSegue(withIdentifier: "showDetail", sender: cell)
        }))
        alert.addAction(UIAlertAction(title: "Map", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler:
            {(alertAction)in
                PHPhotoLibrary.shared().performChanges({
                    //Delete Photo
                    if let request = PHAssetCollectionChangeRequest(for: self.assetCollection){
                        request.removeAssets(at: IndexSet([indexPath.item]))
                    }
                },
                completionHandler: {(success, error)in
                NSLog("\nDeleted Image -> %@", (success ? "Success":"Error!"))
                 if(success){
                        // Move to the main thread to execute
                    DispatchQueue.main.async(execute: {
                    self.photosAsset = PHAsset.fetchAssets(in: self.assetCollection, options: nil)
                    self.collectionView?.reloadData()
                    })
                    }
                })
            }))
        self.present(alert, animated: true, completion: nil)
    }
}

