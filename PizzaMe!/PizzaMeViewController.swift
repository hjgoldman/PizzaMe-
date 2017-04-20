//
//  PizzaMeViewController.swift
//  PizzaMe!
//
//  Created by Hayden Goldman on 3/21/17.
//  Copyright © 2017 Hayden Goldman. All rights reserved.
//

import UIKit
import MapKit
import RandomColorSwift

class PizzaMeViewController: UIViewController, CLLocationManagerDelegate, UIViewControllerTransitioningDelegate {
    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    var locationManager = CLLocationManager()
    var locations = [Location]()
    var fadeTransition = FadeTransition()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        self.view.backgroundColor = randomColor(hue: .random, luminosity: .light)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        self.indicatorView.isHidden = true
    }
    
    func findAllTheTacos() {
        
        self.indicatorView.isHidden = false
        self.indicatorView.startAnimating()
        
        // background lane for time consuming tasks
        DispatchQueue.global().async {
            
            self.getGoogleData()
            sleep(2)
            // switch to the main thread to run UI specific tasks
            DispatchQueue.main.async {
                self.indicatorView.stopAnimating()
                self.indicatorView.isHidden = true
                
                if self.locations.count == 0 {
                    
                    
                    // Create the alert controller
                    let alertController = UIAlertController(title: "No Taco Found", message:  "☹️", preferredStyle: .alert)
                    
                    // Create the actions
                    
                    let cancelAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel) {
                        UIAlertAction in
                        
                        self.locations.removeAll()
                    }
                    
                    // Add the actions
                    alertController.addAction(cancelAction)
                    
                    // Present the controller
                    self.present(alertController, animated: true, completion: nil)
                    
                } else {
                    
                    
                    let closestTaco = self.locations[0]
                    
                    guard let distance = closestTaco.distanceFromUser else {
                        return
                    }
                    
                    let distanceInMiles = String(format: "%.2f", distance / 1609.34)
                    
                    
                    // Create the alert controller
                    let alertController = UIAlertController(title: "Taco Found!", message:  "Closest Taco: \n \(closestTaco.name!) \n \(distanceInMiles) miles away", preferredStyle: .alert)
                    
                    // Create the actions
                    let moreTacoAction = UIAlertAction(title: "🌮", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        
                        self.performSegue(withIdentifier: "GoogleMapsSegue", sender: self)
                    }
                    let cancelAction = UIAlertAction(title: "🚫", style: UIAlertActionStyle.cancel) {
                        UIAlertAction in
                        
                        self.locations.removeAll()
                    }
                    
                    // Add the actions
                    alertController.addAction(moreTacoAction)
                    alertController.addAction(cancelAction)
                    
                    // Present the controller
                    self.present(alertController, animated: true, completion: nil)
                    
                }
            }
        }
    }
    
    
    @IBAction func getTacoButtonPressed(_ sender: Any) {
        self.findAllTheTacos()
    }
    
    //MARK: Custom segue
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return nil
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return self.fadeTransition
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "GoogleMapsSegue" {
            
            let navController = segue.destination as! UINavigationController
            let mapVC = navController.topViewController as! GoogleMapsViewController
            mapVC.locations = self.locations
            
            navController.transitioningDelegate = self
        }
    }
    
    //Mark: API GET request
    
    func getGoogleData() {
        
        guard let lat = self.locationManager.location?.coordinate.latitude else {
            return
        }
        
        guard let lng = self.locationManager.location?.coordinate.longitude else {
            return
        }
        
        let headers = [
            "cache-control": "no-cache",
            ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat)%2C\(lng)%0A&radius=2000&type=resturant&keyword=pizza&pagetoken&key=AIzaSyCq15vCHdT2hrT0oOrCQE18aQvkWh2i-eI")! as URL,
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
                let place_id = item["place_id"] as? String
                let price_level = item["price_level"] as? Int
                let rating = item["rating"] as? Double
                let vicinity = item["vicinity"] as? String
                
                let itemLocation = Location()
                
                if let opening_hours = item["opening_hours"] {
                    let openingHours = opening_hours as! [String:Any]
                    if let open_now = openingHours["open_now"] {
                        itemLocation.open_now = open_now as? Bool
                    }
                }
                
                itemLocation.locationLat = locationLat
                itemLocation.locationLng = locationLng
                itemLocation.name = name
                itemLocation.place_id = place_id
                itemLocation.price_level = price_level
                itemLocation.rating = rating
                itemLocation.vicinity = vicinity
                
                self.locations.append(itemLocation)
            }
            
            print(self.locations.count)
            self.findClosestTaco()
        })
        dataTask.resume()
    }
    
    //Finding the location that is closest to the user
    func findClosestTaco() {
        
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
