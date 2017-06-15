//
//  CollectionViewCell.swift
//  MyVirtualTourist
//
//  Created by Udumala, Mary on 5/17/17.
//  Copyright © 2017 Udumala, Mary. All rights reserved.
//

import Foundation
import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageCell: UIImageView!    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                self.layer.opacity = 0.5
            } else {
                self.layer.opacity = 1.0
            }
        }
    }
    
}
