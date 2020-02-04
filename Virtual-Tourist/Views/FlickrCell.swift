//
//  FlickrCell.swift
//  Virtual-Tourist
//
//  Created by Dustin Mahone on 1/18/20.
//  Copyright © 2020 Dustin. All rights reserved.
//

import UIKit

class FlickrCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                alpha = 0.4
            }
            else {
                alpha = 1.0
            }
        }
    }
    
}
