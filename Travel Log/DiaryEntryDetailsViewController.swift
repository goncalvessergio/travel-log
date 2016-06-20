//
//  DiaryEntryDetailsViewController.swift
//  Travel Log
//
//  Created by Sérgio Gonçalves on 12/06/16.
//  Copyright © 2016 Sérgio Gonçalves. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class DiaryEntryDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var imageRating: UIImageView!
    var diaryEntry: DiaryEntry!
    @IBOutlet weak var image: UIImageView!
    var senderMap : Bool = false
    @IBOutlet weak var imageWeather: UIImageView!
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    @IBOutlet weak var barButtonRead: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        image.image = UIImage(data: diaryEntry.image!)
        

        var image2 : UIImage?
        
        switch diaryEntry.weather! {
        case "rain":
            image2 = UIImage(named: "Rain-52")
        case "clear":
            image2 = UIImage(named: "Sun-48")
        default:
            image2 = UIImage(named: "Clouds-48")
        }
        
        imageWeather.image = image2
        
        var image3 : UIImage?
        
        if diaryEntry.rating == "Positive" {
            image3 = UIImage (named: "Good Quality-48")
        } else {
            image3 = UIImage (named: "Poor Quality-48")

        }
        
        imageRating.image = image3
        
    }
    
    @IBAction func barButtonReadAction(sender: AnyObject) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MMMM-dd"
        dateFormatter.timeZone = NSTimeZone(name: "GMT")
        
        var weather : String = ""
        
        switch diaryEntry.weather! {
            case "rain":
                weather = "rainy"
            case "clear":
                weather = "sunny"
            default:
                weather = "cloudy"
        }
        
        let text : String = "Reading diary \(diaryEntry.title!). \(diaryEntry.text!). This diary was in \(diaryEntry.location_name!) and in this day the weather was \(weather). The date of this diary is  \(dateFormatter.stringFromDate(diaryEntry.date!)) and the rating is \(diaryEntry.rating!)."
        
        myUtterance = AVSpeechUtterance(string: text)
        myUtterance.rate = 0.3
        synth.speakUtterance(myUtterance)    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    @IBAction func backButton(sender: AnyObject) {
        if senderMap == true {
            performSegueWithIdentifier("unwindToMap", sender: self)
        } else {
            performSegueWithIdentifier("unwindToDiaryEntries", sender: self)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! DiaryEntryDetailsCell
        
        cell.backgroundColor = UIColor.clearColor()
        
        switch indexPath.row {
        case 0:
            cell.fieldLabel.text = "Title"
            cell.valueLabel.text = diaryEntry.title
        case 1:
            cell.fieldLabel.text = "Text"
            cell.valueLabel.text = diaryEntry.text
        case 2:
            cell.fieldLabel.text = "Location"
            cell.valueLabel.text = diaryEntry.location_name
        case 3:
            cell.fieldLabel.text = "Date"
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.timeZone = NSTimeZone(name: "GMT")
            cell.valueLabel.text = dateFormatter.stringFromDate(diaryEntry.date!)
        default:
            cell.fieldLabel.text = ""
            cell.valueLabel.text = ""
        }
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
