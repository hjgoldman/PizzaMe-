//
//  PizzaLocation.swift
//  PizzaMe!
//
//  Created by Hayden Goldman on 3/21/17.
//  Copyright © 2017 Hayden Goldman. All rights reserved.
//

import Foundation
import MapKit

class Location {
    var locationLat :Double?
    var locationLng :Double?
    var viewportNorthEastLat :Double?
    var viewportNorthEastLng :Double?
    var viewportSouthWestLat :Double?
    var viewportSouthWestLng :Double?
    var icon :String?
    var id :String?
    var name :String?
    var open_now :Bool?
    var place_id :String?
    var price_level :Int?
    var rating :Double?
    var vicinity :String?
    var distanceFromUser :Double?
}
