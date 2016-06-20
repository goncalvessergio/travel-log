//
//  DiaryEntryDetailsCell.swift
//  Travel Log
//
//  Created by Sérgio Gonçalves on 12/06/16.
//  Copyright © 2016 Sérgio Gonçalves. All rights reserved.
//


import UIKit

class DiaryEntryDetailsCell: UITableViewCell {
    
    @IBOutlet var fieldLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}