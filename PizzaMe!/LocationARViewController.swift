//
//  LocationARViewController.swift
//  PizzaMe!
//
//  Created by Hayden Goldman on 4/20/17.
//  Copyright © 2017 Hayden Goldman. All rights reserved.
//

import UIKit
import MapKit
import HDAugmentedReality

class LocationARViewController: ARViewController, ARDataSource, CLLocationManagerDelegate{
    
    var locations = [Location]()
    var locationManager = CLLocationManager()
    var locationARAnnotations = [ARAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        self.dataSource = self
        self.headingSmoothingFactor = 0.05
        self.maxVisibleAnnotations = 30
        self.maxDistance = 1610
        
        self.popluateAnnotations()
    }
    
    func popluateAnnotations() {
        for location in locations {
            let annotation = LocationAnnotation(location: location)
            self.locationARAnnotations.append(annotation)
            self.setAnnotations(self.locationARAnnotations)
        }
    }
    
    func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
        let annotationView = LocationAnnotaionView(annotation: viewForAnnotation)
        return annotationView
    }
    
}
