//
//  MapInterfaceController.swift
//  PizzaMe!
//
//  Created by Hayden Goldman on 5/1/17.
//  Copyright © 2017 Hayden Goldman. All rights reserved.
//

import WatchKit
import Foundation
import MapKit


class MapInterfaceController: WKInterfaceController, CLLocationManagerDelegate {
    @IBOutlet var map: WKInterfaceMap!
    var locationManager = CLLocationManager()
    var closestPizza: Location?
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        if let closestPizza = context as? Location {
            self.closestPizza = closestPizza
            let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees((self.closestPizza?.locationLat)!), longitude: CLLocationDegrees((self.closestPizza?.locationLng)!))
            
            let coordinateSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let coordinateRegion = MKCoordinateRegion(center: coordinate, span: coordinateSpan)
            map.setRegion(coordinateRegion)
            
            map.addAnnotation(coordinate, withImageNamed: "pizza_marker.png", centerOffset: CGPoint(x: 0, y: 0))
        }
        
    }
    
    
    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}
