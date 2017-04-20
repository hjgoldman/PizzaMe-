//
//  ReviewTableViewCell.swift
//  PizzaMe!
//
//  Created by Hayden Goldman on 4/20/17.
//  Copyright © 2017 Hayden Goldman. All rights reserved.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {
    @IBOutlet var nameLabel :UILabel?
    @IBOutlet var reviewTextLabel :UILabel?
    @IBOutlet var ratingLabel :UILabel?
    @IBOutlet var timeLabel :UILabel?
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
