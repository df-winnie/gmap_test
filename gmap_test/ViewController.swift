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
import CNPPopupController

class ViewController: UIViewController {

    private var mapView:GMSMapView!
    private var locationManager = CLLocationManager()
    private var clusterManager:GMUClusterManager!

    let kClusterItemCount = 10
    let kCameraLatitude = 24.1469
    let kCameraLongitude = 120.6839
    
    var popupController:CNPPopupController?

    
    // MARK: - Clustering
    func clustering(sites:[bikeSite]) {
        
        // Set up the cluster manager with the supplied icon generator and
        // renderer.
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView,
                                                 clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm,
                                           renderer: renderer)
        
        // Generate and add random items to the cluster manager.
        generateClusterItems(sites: sites)
        
        // Call cluster() after items have been added to perform the clustering
        // and rendering on map.
        clusterManager.cluster()
        
        // Register self to listen to both GMUClusterManagerDelegate and
        // GMSMapViewDelegate events.
        clusterManager.setDelegate(self, mapDelegate: self)
    }
    
    /// Randomly generates cluster items within some extent of the camera and
    /// adds them to the cluster manager.
    private func generateClusterItems(sites:[bikeSite]) {
//        let extent = 0.2
//        for index in 1...kClusterItemCount {
        for point in sites {

            let lat = point.lat //kCameraLatitude + extent * randomScale()
            let lng = point.lng //kCameraLongitude + extent * randomScale()
            let name = point.name //"Item \(index)"
            let item =
                POIItem(position: CLLocationCoordinate2DMake(lat, lng), name: name)
            clusterManager.add(item)
            
            print(item.position)
        }
    }
    
    /// Returns a random value between -1.0 and 1.0.
    private func randomScale() -> Double {
        return Double(arc4random()) / Double(UINT32_MAX) * 2.0 - 1.0
    }
    
    // MARK: - Marking
    private func showSites(sites:[bikeSite]) {
        
        for point in sites {
//            print("Looping...",)
            addMarks(mapView: mapView, point: point)
        }
    }
    
    private func addMarks(mapView:GMSMapView, point:bikeSite) {
        
        let position = CLLocationCoordinate2D(latitude: CLLocationDegrees(point.lat), longitude: CLLocationDegrees(point.lng))
        
        let marker = GMSMarker(position: position)
        marker.title = point.name
        marker.snippet = point.addr
        marker.map = mapView
    }
    
    // starter example
    private func setLocation() {
        
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
    
    @objc func showPopup(sender:UIButton?) {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        paragraphStyle.alignment = NSTextAlignment.center
        
        let title = NSAttributedString(string: "It's A Popup!", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 24), NSAttributedStringKey.paragraphStyle: paragraphStyle])
        let lineOne = NSAttributedString(string: "You can add text and images", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18), NSAttributedStringKey.paragraphStyle: paragraphStyle])
//        let lineTwo = NSAttributedString(string: "With style, using NSAttributedString", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18), NSAttributedStringKey.foregroundColor: UIColor.init(colorLiteralRed: 0.46, green: 0.8, blue: 1.0, alpha: 1.0), NSParagraphStyleAttributeName: paragraphStyle])
        
        let button = CNPPopupButton.init(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitle("Close Me", for: UIControlState())
        
        button.backgroundColor = .green
        
        button.layer.cornerRadius = 4;
        button.selectionHandler = { (button) -> Void in
            self.popupController?.dismiss(animated: true)
            print("Block for button: \(button.titleLabel?.text)")
        }
        
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0;
        titleLabel.attributedText = title
        
        let lineOneLabel = UILabel()
        lineOneLabel.numberOfLines = 0;
        lineOneLabel.attributedText = lineOne;
        
        let imageView = UIImageView.init(image: UIImage.init(named: "icon"))
        
        let lineTwoLabel = UILabel()
        lineTwoLabel.numberOfLines = 0;
//        lineTwoLabel.attributedText = lineTwo;
        
        let customView = UIView.init(frame: CGRect(x: 0, y: 0, width: 250, height: 55))
        customView.backgroundColor = UIColor.lightGray
        
        let textField = UITextField.init(frame: CGRect(x: 10, y: 10, width: 230, height: 35))
        textField.borderStyle = UITextBorderStyle.roundedRect
        textField.placeholder = "Custom view!"
        customView.addSubview(textField)
        
        let popupController = CNPPopupController(contents:[titleLabel, lineOneLabel, imageView, lineTwoLabel, customView, button])
        popupController.theme = CNPPopupTheme.default()
        popupController.theme.popupStyle = .actionSheet
        // LFL added settings for custom color and blur
        popupController.theme.maskType = .dimmed
//        popupController.theme.customMaskColor = UIColor.red
//        popupController.theme.blurEffectAlpha = 1.0
        popupController.delegate = self
        self.popupController = popupController
        popupController.present(animated: true)
        
    }
}


extension ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        /*
        let btn = UIButton(frame: CGRect(x: 20, y: 100, width: 150, height: 50))
        btn.backgroundColor = .blue
        btn.setTitle("POPUP", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(showPopup(sender:)), for: .touchUpInside)
        
        view.addSubview(btn)
        */
        

        // your map initiation code
        mapView = GMSMapView(frame: self.view.frame)
        mapView.accessibilityElementsHidden = false
        mapView.isMyLocationEnabled = true
        
        // settings
        mapView.settings.myLocationButton = true
        
        // current location
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        view.addSubview(mapView)
        
//        setLocation()
//        clustering()
        
        WebService.bikeSites(urlStr: "http://data.taichung.gov.tw/wSite/public/data/f1501559780355.json") { (list, error) in

            DispatchQueue.main.async {
                if list != nil && error == nil {
//                    self.showSites(sites: list!)
                    print("points: ", list!.count)
                    self.clustering(sites: list!)
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
}

extension ViewController:CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        print(location?.coordinate.latitude, location?.coordinate.longitude, "CURRENT LOCATION")
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)
        
        self.mapView.animate(to: camera)
        
        //Finally stop updating location otherwise it will come again and again in this delegate
        self.locationManager.stopUpdatingLocation()
    }
}

extension ViewController:GMUClusterManagerDelegate {
    
    func clusterManager(clusterManager: GMUClusterManager, didTapCluster cluster: GMUCluster) {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
                                                           zoom: mapView.camera.zoom + 1)
        let update = GMSCameraUpdate.setCamera(newCamera)
        mapView.moveCamera(update)
    }
}


extension ViewController:GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        if let poiItem = marker.userData as? POIItem {
            // tap on marker
            NSLog("Did tap marker for cluster item \(poiItem.name)")
            print(poiItem.position,"TAPPED LOCATION")
            self.showPopup(sender: nil)
        } else {
            // tap on cluster marker
            NSLog("Did tap a normal marker")
        }
        return false
    }
    
//    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
//    }
    
}

extension ViewController : CNPPopupControllerDelegate {
    
    func popupControllerWillDismiss(_ controller: CNPPopupController) {
        print("Popup controller will be dismissed")
    }
    
    func popupControllerDidPresent(_ controller: CNPPopupController) {
        print("Popup controller presented")
    }
    
}

