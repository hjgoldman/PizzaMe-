//
//  LocationDetailTabBarController.swift
//  PizzaMe!
//
//  Created by Hayden Goldman on 4/20/17.
//  Copyright © 2017 Hayden Goldman. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LocationDetailTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let infoVC = self.viewControllers![0] as! MoreInfoViewController
        let reviewVC = self.viewControllers![1] as! ReviewViewController
        reviewVC.locationDetail = infoVC.locationDetail
        reviewVC.reviewsRx.value = infoVC.reviewsRx.value
    }
    
    override func awakeFromNib() {
        self.delegate = self;
    }
    
}
