//
//  VideoDetailViewController.swift
//  PhotoGallery
//
//  Created by Olga on 5/25/18.
//  Copyright © 2018 Olya Tilichenko. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class VideoDetailViewController: UIViewController, UITextFieldDelegate {

    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var stringUrl: String?
    var assetCollection: PHAssetCollection!
    var photosAsset: PHFetchResult<PHAsset>!
    var index: Int = 0
    var playerItem: AVPlayerItem?
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var playerSlider: UISlider!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        
        let stop = UITapGestureRecognizer()
        self.view.addGestureRecognizer(stop)
        stop.addTarget(self, action: #selector(self.stopPlaying))
        getVideo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard (photosAsset[index].mediaType == .video)
            else {
                print("Not a valid video media type")
                return
        }
    }
    
    // MARK: - Actions
    
    @IBAction func editWithText(_ sender: Any) {
        
        textField.clearsOnBeginEditing = true
        textField.isHidden = false
        textField.becomeFirstResponder()
    }
    
    @IBAction func saveVideo() {
        guard let player = player  else {
            return
        }
        player.pause()
        
        guard let playerItem = self.playerItem else { return }
        let asset = playerItem.asset
       
        guard let textImage = getImage() else { return }
        
        let merge = Merge(config: .standard)
        merge.overlayVideo(video: asset, overlayImage: textImage, completion: { url in
            DispatchQueue.global().async(execute: {
                PHPhotoLibrary.shared().performChanges({
                    guard let url = url else { return }
                    let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                    guard let assetPlaceholder = createAssetRequest?.placeholderForCreatedAsset else { return }
                    if let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection, assets: self.photosAsset) {
                        albumChangeRequest.addAssets([assetPlaceholder] as NSArray)
                    }
                }, completionHandler: {(success, error)in
                    DispatchQueue.main.async(execute: {
                        print("Adding video to Library -> %@", (success ? "Sucess":"Error!"))
                    })
                })
            })
        }, progressHandler: { progress in print(progress) })
    
        textField.isHidden = true
    }
    
    @IBAction func handlePan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.textView)
        if let view = recognizer.view {
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        }
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }
    
    
    @IBAction func handlePinch(recognizer: UIPinchGestureRecognizer) {
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
    
    func getVideo() {
        
        PHImageManager().requestPlayerItem(forVideo: photosAsset[index], options: nil, resultHandler: {(playerItem, result) in
            guard playerItem != nil else {
                print("something bad happened")
                return
            }
            self.playerItem = playerItem
            
            DispatchQueue.main.async {
                self.display(item: playerItem!)
            }
        })
    }
    
    func getImage() -> UIImage? {
        
        textView.layer.addSublayer(textField.layer)
        UIGraphicsBeginImageContext(self.textView.frame.size)
        textView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let imageWithText = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return imageWithText
    }
    
    func display(item:AVPlayerItem) {
        
        player = AVPlayer(playerItem: item)
        guard let player = player else {
            return
        }
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        guard let playerLayer = playerLayer else {
            return
        }
        playerLayer.frame = CGRect(x:0, y:0, width:self.videoView.frame.width, height:self.videoView.frame.height)
        self.videoView.layer.addSublayer(playerLayer)
        self.videoView.addSubview(playerSlider)
        self.videoView.addSubview(textField)
        
        let duration : CMTime = item.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        
        playerSlider.maximumValue = Float(seconds)
        playerSlider.minimumValue = 0
        playerSlider.isContinuous = true
        playerSlider.setThumbImage(UIImage(), for: .normal)
        
        _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
        
        playerSlider.addTarget(self, action: #selector(self.playbackSliderValueChanged(_:)), for: .valueChanged)
        player.play()
    }
    
    @objc func playbackSliderValueChanged(_ playSlider:UISlider) {
        guard let player = player else {
            return
        }
        if let duration = player.currentItem?.duration {
            let totalSeconds = CMTimeGetSeconds(duration)
            
            let value = Float64(playSlider.value) * totalSeconds
            
            let seekTime = CMTime(value: Int64(value), timescale: 1)
            
            player.seek(to: seekTime)
            
            if player.rate == 0
            {
                player.play()
            }
        }
    }
    
    @objc func updateSlider() {
        let currentTimeInSeconds = CMTimeGetSeconds((player?.currentTime())!)
        playerSlider.value = Float(currentTimeInSeconds)
    }
    
    @objc func stopPlaying() {
        guard let player = player else {
            return
        }
        if (player.rate == 1.0 ) {
            player.pause()
        } else {
            player.play()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
