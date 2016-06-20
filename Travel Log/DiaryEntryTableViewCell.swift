//
//  DiaryEntryTableViewCell.swift
//  Travel Log
//
//  Created by Sérgio Gonçalves on 04/06/16.
//  Copyright © 2016 Sérgio Gonçalves. All rights reserved.
import UIKit

class DiaryEntryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

}

