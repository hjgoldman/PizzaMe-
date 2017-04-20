//
//  MoreInfoViewController.swift
//  PizzaMe!
//
//  Created by Hayden Goldman on 4/20/17.
//  Copyright © 2017 Hayden Goldman. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MoreInfoViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var isOpenLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var phoneButtonOutlet: UIButton!
    
    var locationDetail = LocationDetail()
    var locationPlace_id :String!
    var reviewsRx :Variable<[Review]> = Variable([])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getLocationDetails()
        
    }
    
    func populateView() {
        
        self.nameLabel.text = self.locationDetail.name
        self.addressLabel.text = self.locationDetail.formatted_address
        self.phoneButtonOutlet.setTitle(self.locationDetail.formatted_phone_number, for: .normal)
        
        if self.locationDetail.weekday_text == nil {
            self.hoursLabel.text = "Opening Hours Not Provided"
        } else {
            
            let hours = self.locationDetail.weekday_text?.joined(separator: "\n")
            self.hoursLabel.text = hours!
        }
        
        if self.locationDetail.open_now == true {
            self.isOpenLabel.text = "Open"
            self.isOpenLabel.textColor = UIColor(fromHexString: "006400")
        } else if self.locationDetail.open_now == false {
            self.isOpenLabel.text = "Closed"
            self.isOpenLabel.textColor = UIColor(fromHexString: "8B0000")
        } else {
            self.isOpenLabel.text = ""
        }
        
    }
    
    func getLocationDetails() {
        
        let headers = [
            "cache-control": "no-cache",
            ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(self.locationPlace_id!)&key=AIzaSyA3RhbSXz2Enph92mEeehvXogH8cDg5VGQ")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            let json = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
            
            let result = json["result"] as! [String:Any]
            
            let geometry = result["geometry"] as! [String:Any]
            let location = geometry["location"] as! [String:Any]
            //let opening_hours = result["opening_hours"] as! [String:Any]
            
            if let opening_hours = result["opening_hours"] as? [String:Any] {
                
                let weekday_text = opening_hours["weekday_text"] as? [String]
                self.locationDetail.weekday_text = weekday_text
                
                if let open_now = opening_hours["open_now"] {
                    self.locationDetail.open_now = open_now as? Bool
                }
            }
            
            guard let formatted_address = result["formatted_address"] as? String,
                let formatted_phone_number = result["formatted_phone_number"] as? String,
                let lat = location["lat"] as? Double,
                let lng = location["lng"] as? Double,
                let name = result["name"] as? String,
                let rating = result["rating"] as? Double,
                let url = result["url"] as? String,
                let international_phone_number = result["international_phone_number"] as? String
                else {
                    return
            }
            
            
            if let website = result["website"] {
                self.locationDetail.website = website as? String
            }
            
            if let price_level = result["price_level"] {
                self.locationDetail.price_level = price_level as? Double
            }
            
            self.locationDetail.formatted_address = formatted_address
            self.locationDetail.formatted_phone_number = formatted_phone_number
            self.locationDetail.lat = lat
            self.locationDetail.lng = lng
            self.locationDetail.name = name
            self.locationDetail.rating = rating
            self.locationDetail.url = url
            self.locationDetail.international_phone_number = international_phone_number
            
            // Save the rewivew into my review object
            
            let reviews = result["reviews"] as! [[String:Any]]
            for item in reviews {
                
                let author_name = item["author_name"] as! String
                let rating = item["rating"] as! Int
                let relative_time_description = item["relative_time_description"] as! String
                let text = item["text"] as! String
                
                let review = Review()
                review.author_name = author_name
                review.rating = rating
                review.relative_time_description = relative_time_description
                review.text = text
                review.isTacoMeReview = false
                
                self.reviewsRx.value.append(review)
                
            }
            DispatchQueue.main.async {
                self.populateView()
            }
        })
        dataTask.resume()
    }
    
    //MARK: Buttons
    
    @IBAction func phoneButtonPressed(_ sender: Any) {
        let formattedPhoneNumber = self.locationDetail.international_phone_number?.replacingOccurrences(of: " ", with: "")
        if let phoneCallURL = URL(string: "tel://\(String(describing: formattedPhoneNumber!))") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    @IBAction func directionsButtonPressed(_ sender: Any) {
        let noSpacesString = self.locationDetail.formatted_address?.replacingOccurrences(of: " ", with: "%20")
        let noSpacesAndNoCommaString = noSpacesString?.replacingOccurrences(of: ",", with: "%2C")
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            let url = URL(string: "comgooglemaps-x-callback://?daddr=\(noSpacesAndNoCommaString!)&directionsmode=driving&x-success=OpenInGoogleMapsSample%3A%2F%2F&x-source=OpenInGoogleMapsSample")
            UIApplication.shared.open(url!)
        } else {
            let url = URL(string: "https://maps.apple.com/?daddr=\(noSpacesAndNoCommaString!)&dirflg=d")
            UIApplication.shared.open(url!)
        }
    }
}
