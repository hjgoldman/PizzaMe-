//
//  FadeTransition.swift
//  PizzaMe!
//
//  Created by Hayden Goldman on 3/23/17.
//  Copyright © 2017 Hayden Goldman. All rights reserved.
//

import Foundation
import UIKit

class FadeTransition :NSObject, UIViewControllerAnimatedTransitioning {
    
    let durantion = 1.0
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return durantion
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)
        
        toView?.alpha = 0
        containerView.addSubview(toView!)
        
        UIView.animate(withDuration: durantion, animations: {
            
            toView?.alpha = 1
            
        }) { (_) in
            
            transitionContext.completeTransition(true)
            
        }
    }
}
