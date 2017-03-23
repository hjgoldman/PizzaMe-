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
    
    @IBOutlet weak var indicatorView :UIActivityIndicatorView!
    var locationManager = CLLocationManager()
    var pizzaLocations = [PizzaLocation]()
    var closestPizza = PizzaLocation()
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
        self.indicatorView.isHidden = true
        
    }
    
    private func launchTimerToLetEverythingLoad() {
        
        self.findPizzas()
        sleep(2);
        self.findClosestPizza()
        
    }
    
    
    @IBAction func getPizzaButtonPressed(_ sender: Any) {
        
        self.indicatorView.isHidden = false
        self.indicatorView.startAnimating()
        
        // background // lane for time consuming tasks
        DispatchQueue.global().async {
            
            self.launchTimerToLetEverythingLoad()
            
            // switch to the main thread to run UI specific tasks
            DispatchQueue.main.async {
                self.indicatorView.stopAnimating()
                self.indicatorView.isHidden = true
                
                
                guard let distance = self.closestPizza.distanceFromUser else {
                    return
                }
                
                let distanceInMiles = String(format: "%.2f", distance / 1609.34)
                
                
                // Create the alert controller
                let alertController = UIAlertController(title: "Pizza Found!", message:  "\(self.closestPizza.name!): \(distanceInMiles) miles away", preferredStyle: .alert)
                
                // Create the actions
                let getPizzaAction = UIAlertAction(title: "Get Directions", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    //self.performSegue(withIdentifier: "MapSegue", sender: self)
                    
                    let url  = NSURL(string: "http://maps.apple.com/?q=\(self.closestPizza.coordinate.coordinate.latitude),\(self.closestPizza.coordinate.coordinate.longitude)")
                    
                    if UIApplication.shared.canOpenURL(url! as URL) == true {
                        UIApplication.shared.open(url as! URL)
                        
                    }
                }
                let morePizzaAction = UIAlertAction(title: "More Pizzas", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    self.performSegue(withIdentifier: "MapSegue", sender: self)
                    
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
                    UIAlertAction in
                    
                }
                
                // Add the actions
                alertController.addAction(getPizzaAction)
                alertController.addAction(morePizzaAction)
                alertController.addAction(cancelAction)
                
                // Present the controller
                self.present(alertController, animated: true, completion: nil)
                
                
            }
        }
        
        
    }
    
    func findPizzas() {
        let categoryRequest = MKLocalSearchRequest()
        
        categoryRequest.naturalLanguageQuery = "pizza"
        
        let region = MKCoordinateRegionMakeWithDistance((self.locationManager.location?.coordinate)!, 250, 250)
        
        categoryRequest.region = region
        
        let search = MKLocalSearch(request: categoryRequest)
        search.start { (response :MKLocalSearchResponse?, error: Error?) in
            
            for requestItem in (response?.mapItems)! {
                
                let pizzaLocation = PizzaLocation()
                pizzaLocation.name = requestItem.name
                pizzaLocation.coordinate = requestItem.placemark.location
                pizzaLocation.address = requestItem.placemark.addressDictionary?["FormattedAddressLines"] as! [String]
                pizzaLocation.street = requestItem.placemark.addressDictionary?["Street"] as! String!
                pizzaLocation.city = requestItem.placemark.addressDictionary?["City"] as! String
                pizzaLocation.state = requestItem.placemark.addressDictionary?["State"] as! String
                pizzaLocation.zip = requestItem.placemark.addressDictionary?["ZIP"] as! String
                
                self.pizzaLocations.append(pizzaLocation)
            }
        }
        
    }
    
    //Finding the location that is closest to the user
    func findClosestPizza() {
        
        var distances = [Double]()
        
        //looping to get all the location distance from user
        for locationDistance in self.pizzaLocations {
            
            let distance = self.locationManager.location?.distance(from: locationDistance.coordinate)
            locationDistance.distanceFromUser = distance as Double!
            distances.append(distance!)
            
        }
        
        let minDistance = distances.min()
        
        //setting the closest location object to the location with the closest distance
        for location in self.pizzaLocations {
            
            if self.locationManager.location?.distance(from: location.coordinate) == minDistance {
                self.closestPizza = location
            }
        }
    }
    
    //Custom segue
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return nil
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return self.fadeTransition
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let mapVC = segue.destination as! MapViewController
        mapVC.transitioningDelegate = self
        
    }
    
    
    
    
}
