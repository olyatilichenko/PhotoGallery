//
//  PermissionsViewController.swift
//  PhotoGallery
//
//  Created by Olya Tilichenko on 27.03.2018.
//  Copyright © 2018 Olya Tilichenko. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation

class PermissionsViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!
    var authStatusloc =  CLLocationManager.authorizationStatus()
    var authStatusCam =  AVCaptureDevice.authorizationStatus(for: .video)

    @IBAction func locationButton(_ sender: Any) {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        if(CLLocationManager.locationServicesEnabled()){
            locationManager.requestWhenInUseAuthorization()
        }
        showGallery()
    }
    
    @IBAction func cameraButton(_ sender: Any) {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: {accessGranted in
            guard accessGranted == true else { return }
        })
        showGallery()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showGallery()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showGallery() {
        if (authStatusCam == .authorized) && (authStatusloc == .authorizedWhenInUse) {
            performSegue(withIdentifier: "showGallery", sender: self)
        }
    }
}
