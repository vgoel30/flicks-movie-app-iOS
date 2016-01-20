//
//  MovieCell.swift
//  flicks
//
//  Created by Varun Goel on 1/18/16.
//  Copyright © 2016 Varun Goel. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {
    
    //title label
    @IBOutlet weak var titleLabel: UILabel!
    
    //overview label
    @IBOutlet weak var overviewLabel: UILabel!
    
    //outlet for image
    @IBOutlet weak var posterView: UIImageView!
    
    //will hold the rating
    @IBOutlet weak var ratingLabel: UILabel!
    
    //holds the date of release
    @IBOutlet weak var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
