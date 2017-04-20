//
//  LocationAnnotationView.swift
//  PizzaMe!
//
//  Created by Hayden Goldman on 4/20/17.
//  Copyright © 2017 Hayden Goldman. All rights reserved.
//

import Foundation
import UIKit
import HDAugmentedReality
import MapKit

class LocationAnnotaionView :ARAnnotationView, CLLocationManagerDelegate {
    
    //Getting user location
    var locationManager = CLLocationManager()
    //
    
    var annotationView :UIView = UIView()
    var annotationNameLabel :UILabel = UILabel()
    var annotationAddressLabel :UILabel = UILabel()
    var annotationDistanceLabel :UILabel = UILabel()
    
    var userLatitude :Double = Double()
    var userLongitude :Double = Double()
    
    
    init(annotation :ARAnnotation) {
        super.init()
        
        //Getting user location *START
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        let userLat = self.locationManager.location?.coordinate.latitude
        let userLng = self.locationManager.location?.coordinate.longitude
        // *END
        
        let locationAnnotation = annotation as! LocationAnnotation
        
        
        let userLocation = CLLocation(latitude: userLat!, longitude: userLng!)
        let location = CLLocation(latitude: locationAnnotation.itemLocation.locationLat!, longitude: locationAnnotation.itemLocation.locationLng!)
        
        //
        
        let name = locationAnnotation.itemLocation.name
        
        let address = "\(locationAnnotation.itemLocation.vicinity!)"
        
        
        let distanceInMeters = userLocation.distance(from: location)
        
        let distanceInMiles = distanceInMeters / 1609.344
        
        let roundedDistanceInMiles = String(format: "%.2f", distanceInMiles)
        
        self.annotationView.frame = CGRect(x: 0, y: 0, width: 150, height: 100)
        self.annotationView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        self.annotationNameLabel.frame = CGRect(x: 0, y: 5, width: 150, height: 20)
        self.annotationNameLabel.text = name
        self.annotationNameLabel.textColor = UIColor.white
        self.annotationNameLabel.font = UIFont.boldSystemFont(ofSize: 15)
        self.annotationNameLabel.textAlignment = .center
        self.annotationNameLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.annotationNameLabel.numberOfLines = 2
        
        self.annotationAddressLabel.frame = CGRect(x: 0, y: self.annotationNameLabel.frame.size.height + 5, width: 150, height: 50)
        self.annotationAddressLabel.text = address
        self.annotationAddressLabel.textColor = UIColor.white
        self.annotationAddressLabel.font = UIFont.systemFont(ofSize: 12)
        self.annotationAddressLabel.textAlignment = .center
        self.annotationAddressLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.annotationAddressLabel.numberOfLines = 2
        
        self.annotationDistanceLabel.frame = CGRect(x: 0, y: self.annotationAddressLabel.frame.size.height + 8, width: 150, height: 50)
        self.annotationDistanceLabel.text = "\(roundedDistanceInMiles) Miles Away"
        self.annotationDistanceLabel.textColor = UIColor.white
        self.annotationDistanceLabel.font = UIFont.systemFont(ofSize: 10)
        self.annotationDistanceLabel.textAlignment = .center
        
        self.annotationView.addSubview(self.annotationNameLabel)
        self.annotationView.addSubview(self.annotationAddressLabel)
        self.annotationView.addSubview(self.annotationDistanceLabel)
        
        self.addSubview(self.annotationView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
