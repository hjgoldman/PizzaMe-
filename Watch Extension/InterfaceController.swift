//
//  InterfaceController.swift
//  Watch Extension
//
//  Created by Hayden Goldman on 5/1/17.
//  Copyright © 2017 Hayden Goldman. All rights reserved.
//

import WatchKit
import Foundation
import MapKit


class InterfaceController: WKInterfaceController, CLLocationManagerDelegate {
    var locationManager = CLLocationManager()
    var locations = [Location]()
    
    @IBOutlet var pizzaImage: WKInterfaceImage!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        self.locations.removeAll()
        
        self.pizzaImage.stopAnimating()
        self.pizzaImage.setImageNamed("frame_1")
    }
    
    @IBAction func tacoTap(_ sender: Any) {
        
        print("pizza has been tapped")
        self.tacoAnimationWithResults()
        
    }
    
    func tacoAnimationWithResults() {
        self.pizzaImage.setImageNamed("frame_")
        self.pizzaImage.startAnimatingWithImages(in: NSMakeRange(0, 30), duration: 1, repeatCount: -1)
        DispatchQueue.global().async {
            
            self.getGoogleData()
            sleep(5)
            
            DispatchQueue.main.async {
                self.pizzaImage.stopAnimating()
                self.presentAlerts()
                
            }
        }
    }
    
    func presentAlerts() {
        
        if self.locations.count == 0 {
            
            let cancelAction = WKAlertAction(title: "Dismiss", style: .default) {
                
                self.locations.removeAll()
            }
            
            self.presentAlert(withTitle: "No Pizza Found", message: "☹️", preferredStyle: .actionSheet, actions: [cancelAction])
            
        } else {
            
            let closestPizza = self.locations[0]
            
            guard let distance = closestPizza.distanceFromUser else {
                
                return
            }
            
            let distanceInMiles = String(format: "%.2f", distance / 1609.34)
            
            let action1 = WKAlertAction(title: "Map", style: .default) {
                
                print("ok")
                
                self.presentController(withName: "Map", context: closestPizza)
                
            }
            let cancelAction = WKAlertAction(title: "🚫", style: .cancel) {
                self.locations.removeAll()
            }
            
            self.presentAlert(withTitle: "Pizza Found!", message: "Closest Pizza: \n \(closestPizza.name!) \n \(distanceInMiles) miles away", preferredStyle: .actionSheet, actions: [action1,cancelAction])
        }
    }
    
    func getGoogleData() {
        
        self.locations.removeAll()
        
        guard let lat = self.locationManager.location?.coordinate.latitude else {
            return
        }
        
        guard let lng = self.locationManager.location?.coordinate.longitude else {
            return
        }
        
        let headers = [
            "cache-control": "no-cache",
            ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat)%2C\(lng)%0A&radius=2000&type=resturant&keyword=pizza&pagetoken&key=AIzaSyBbvw_RKKdzBigdZGjXTJZjgC3IMJVV6rU")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            if (error != nil) {
                print(error!)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse!)
            }
            
            let json = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
            
            let results = json["results"] as! [[String:Any]]
            
            for item in results {
                
                let geometry = item["geometry"] as! [String:Any]
                let location = geometry["location"] as! [String:Any]
                
                let name = item["name"] as? String
                let locationLat = location["lat"] as? Double
                let locationLng = location["lng"] as? Double
                
                let itemLocation = Location()
                
                itemLocation.locationLat = locationLat
                itemLocation.locationLng = locationLng
                itemLocation.name = name
                
                self.locations.append(itemLocation)

            }
            
            print(self.locations.count)
            self.findClosestPizza()
        })
        dataTask.resume()
    }
    
    //Mark: Finding the location that is closest to the user
    func findClosestPizza() {
        
        var distances = [Double]()
        //looping to get all the location distance from user
        for location in self.locations {
            let distance = self.locationManager.location?.distance(from: CLLocation(latitude: CLLocationDegrees(location.locationLat!), longitude: CLLocationDegrees(location.locationLng!)))
            location.distanceFromUser = distance as Double!
            distances.append(distance!)
        }
        self.locations.sort(by: {$0.distanceFromUser! < $1.distanceFromUser!})
    }
}
