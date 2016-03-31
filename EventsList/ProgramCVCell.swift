//
//  ProgramCVCell.swift
//  EventsList
//
//  Created by Ray Smith on 3/30/16.
//  Copyright © 2016 Hamagain LLC. All rights reserved.
//

import UIKit

class ProgramCVCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var imageRefLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    internal func assignValues(title: String, image440: String?){
        if titleLabel != nil{
            titleLabel!.text = title
        }
        
        imageRefLabel?.text = image440
    }

}
