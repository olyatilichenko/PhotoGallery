//
//  MapViewController.swift
//  PhotoGallery
//
//  Created by Olya Tilichenko on 26.03.2018.
//  Copyright © 2018 Olya Tilichenko. All rights reserved.
//

import UIKit
import Photos
import MapKit

class MapViewController: UIViewController {
    
    var assetCollection: PHAssetCollection!
    var photosAsset: PHFetchResult<PHAsset>!
    var index: Int!
    let regionRadius: CLLocationDistance = 1000
    var coordinate: CLLocation!
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coordinate = self.photosAsset[self.index!].location
        print(self.photosAsset[self.index!])
        print(coordinate)
        //centerMapOnLocation(location: coordinate)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
