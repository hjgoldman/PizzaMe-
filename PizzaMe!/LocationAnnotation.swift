//
//  LocationAnnotation.swift
//  PizzaMe!
//
//  Created by Hayden Goldman on 4/20/17.
//  Copyright © 2017 Hayden Goldman. All rights reserved.
//

import Foundation
import UIKit
import HDAugmentedReality
import MapKit

class LocationAnnotation :ARAnnotation {
    
    var itemLocation :Location!
    
    init(location :Location) {
        
        super.init()
        
        self.title = location.name
        self.location = CLLocation(latitude: location.locationLat!, longitude: location.locationLng!)
        self.itemLocation = location
    }
    
    
    
}
