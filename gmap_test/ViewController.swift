//
//  ViewController.swift
//  gmap_test
//
//  Created by Ziting Wei on 19/12/2017.
//  Copyright © 2017 df-dev. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class ViewController: UIViewController {

    private var mapView:GMSMapView!
    private var locationManager = CLLocationManager()
    private var clusterManager:GMUClusterManager!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Your map initiation code
        mapView = GMSMapView(frame: self.view.frame)
        mapView.accessibilityElementsHidden = false
        mapView.isMyLocationEnabled = true
        
        // settings
        mapView.settings.myLocationButton = true

        
        // current location
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        view.addSubview(mapView)
        
        WebService.bikeSites(urlStr: "http://data.taichung.gov.tw/wSite/public/data/f1501559780355.json") { (list, error) in
            
            DispatchQueue.main.async {
                if list != nil && error == nil {
                    self.showSites(sites: list!)
                } else {
                    print("error")
                }
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showSites(sites:[bikeSite]) {
        
        for point in sites {
//            print("Looping...",)
            addMarks(mapView: mapView, point: point)
        }
        
    }
    
    func addMarks(mapView:GMSMapView, point:bikeSite) {
        
        let position = CLLocationCoordinate2D(latitude: CLLocationDegrees(point.lat), longitude: CLLocationDegrees(point.lng))
        
        let marker = GMSMarker(position: position)
        marker.title = point.name
        marker.snippet = point.addr
        marker.map = mapView
    }
    
    // starter example
    func setLocation() {
        
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: 24.1469, longitude: 120.6839, zoom: 15.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.accessibilityElementsHidden = false

        view = mapView
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 24.1469, longitude: 120.6839)
        marker.title = "Taichung"
        marker.snippet = "Taiwan"
        marker.map = mapView
    }
    
}

extension ViewController:CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)
        
        self.mapView.animate(to: camera)
        
        //Finally stop updating location otherwise it will come again and again in this delegate
        self.locationManager.stopUpdatingLocation()
    }
}

extension ViewController:GMUClusterManagerDelegate {
    
}
