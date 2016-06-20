//
//  RatingViewController.swift
//  Travel Log
//
//  Created by Sérgio Gonçalves on 18/06/16.
//  Copyright © 2016 Sérgio Gonçalves. All rights reserved.
//

import UIKit
import CoreData

class RatingViewController: UIViewController {
    
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var btDislike: UIButton!
    @IBOutlet weak var btLike: UIButton!
    @IBOutlet weak var btClose: UIButton!
    var rating : String = "Positive"
    
    override func viewDidLoad() {

        let blurEffect = UIBlurEffect(style: .Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        bgImage.addSubview(blurEffectView)
        
        let translate = CGAffineTransformMakeTranslation(0, 500)
        btDislike.transform = translate
        btLike.transform = translate
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        // Spring animation
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            
            self.btLike.transform = CGAffineTransformIdentity
            
            }, completion: nil)
        
        UIView.animateWithDuration(0.5, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            
            self.btDislike.transform = CGAffineTransformIdentity
            
            }, completion: nil)
        
    }
    
    @IBAction func like(sender: UIButton) {
        rating = "Positive"
        performSegueWithIdentifier("unwindToAddDiaryEntriesRating", sender: sender)
    }
    
    @IBAction func dislike(sender: UIButton) {
        rating = "Negative"
        performSegueWithIdentifier("unwindToAddDiaryEntriesRating", sender: sender)
    }
}
