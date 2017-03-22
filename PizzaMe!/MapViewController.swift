//
//  MapViewController.swift
//  PizzaMe!
//
//  Created by Hayden Goldman on 3/21/17.
//  Copyright © 2017 Hayden Goldman. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
        
        self.getPizzaLocations()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "PizzaAnnotation")
        annotationView.frame = CGRect(x: 0, y: 0, width: 25, height: 30)
        annotationView.canShowCallout = true
        annotationView.rightCalloutAccessoryView = UIButton.init(type: .infoDark)
        
        let pizzaImage = UIImage(named: "pizza_annotation.png")
        let pizzaImageView = UIImageView(image: pizzaImage)
        pizzaImageView.frame = CGRect(x: 0, y: 0, width: 25, height: 30)
        
        
        annotationView.addSubview(pizzaImageView)
        
        return annotationView
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let selectedLoc = view.annotation
        
        let lat = selectedLoc?.coordinate.latitude
        let lng = selectedLoc?.coordinate.longitude
        
        let url  = NSURL(string: "http://maps.apple.com/?q=\(lat!),\(lng!)")
        
        if UIApplication.shared.canOpenURL(url! as URL) == true {
            UIApplication.shared.open(url as! URL)
            
        }
        
    }
    
    
    func getPizzaLocations() {
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = "pizza"
        
        let region = MKCoordinateRegionMakeWithDistance((self.locationManager.location?.coordinate)!, 250, 250)
        
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { (response :MKLocalSearchResponse?, error: Error?) in
            
            for mapItem in (response?.mapItems)! {
                
                let annotation = MKPointAnnotation()
                annotation.title = mapItem.name
                annotation.coordinate = CLLocationCoordinate2D(latitude: mapItem.placemark.coordinate.latitude, longitude: mapItem.placemark.coordinate.longitude)
                
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    
    
}
