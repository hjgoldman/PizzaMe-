//
//  MapViewController.swift
//  PizzaMe!
//
//  Created by Hayden Goldman on 3/21/17.
//  Copyright © 2017 Hayden Goldman. All rights reserved.
//

import UIKit
import GoogleMaps

class GoogleMapsViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    var locationManager = CLLocationManager()
    var locations = [Location]()
    var locationPlace_id :String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        let lat = self.locationManager.location?.coordinate.latitude
        let lng = self.locationManager.location?.coordinate.longitude
        
        // creates the map and zooms the current user location, at a 6.0 zoom
        let camera = GMSCameraPosition.camera(withLatitude: lat!, longitude: lng!, zoom: 15.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        
        for location in self.locations {
            
            let marker = GMSMarker()
            
            let lat = location.locationLat
            let lng = location.locationLng
            
            marker.position = CLLocationCoordinate2D(latitude: lat!, longitude: lng!)
            marker.title = location.name
            
            if location.open_now == false {
                marker.snippet = "\(location.vicinity!)\nClosed"
            } else if location.open_now == true {
                marker.snippet = "\(location.vicinity!)\nOpen"
            } else {
                
            }
            marker.userData = location
            
            marker.icon = UIImage(named: "pizza_annotation.png")
            marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.2)
            
            marker.map = mapView
        }
        // enable my location dot
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
    }
    
    //MARK: GMSMapViewDelegate
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let customWindow = Bundle.main.loadNibNamed("CustomInfoWindow", owner: self, options: nil)?.first as! CustomInfoWindow
        
        customWindow.nameLabel.text = marker.title
        customWindow.addressLabel.text = marker.snippet
        
        return customWindow
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
        let location = marker.userData as! Location
        self.locationPlace_id = location.place_id
        self.performSegue(withIdentifier: "MoreInfoSegue", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "MoreInfoSegue" {
            
            let tabVC = segue.destination as! UITabBarController
            let moreInfoVC = tabVC.viewControllers?[0] as! MoreInfoViewController
            let reviewVC = tabVC.viewControllers?[1] as! ReviewViewController
            
            moreInfoVC.locationPlace_id = self.locationPlace_id
            reviewVC.locationPlace_id = self.locationPlace_id
            
        } else if segue.identifier == "ARSegue" {
            
            let arVC = segue.destination as! LocationARViewController
            arVC.locations = self.locations
            
        }
    }
    
}

