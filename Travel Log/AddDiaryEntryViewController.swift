//
//  AddDiaryEntryViewController.swift
//  Travel Log
//
//  Created by Sérgio Gonçalves on 24/05/16.
//  Copyright © 2016 Sérgio Gonçalves. All rights reserved.
//
import UIKit
import CoreData

class AddDiaryEntryViewController : UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var btDone: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var tfLocation: UITextField!
    @IBOutlet weak var tfDescription: UITextField!
    @IBOutlet weak var tfDate: UITextField!
    @IBOutlet weak var imgWeather: UIImageView!
    @IBOutlet weak var tfRating: UITextField!

    var weather : String?
    var latitude : Double = 0
    var longitude : Double = 0
    
    let coreDataDB = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    var titleText : String!
    var descriptionText : String!
    var locationText : String!
    var dateText : String!
    
    var saveOK = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfDate.delegate = self
        tfTitle.delegate = self
        tfLocation.delegate = self
        tfDescription.delegate = self
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = NSTimeZone(name: "GMT")
        tfDate.text = dateFormatter.stringFromDate(NSDate())
        tfRating.text = "Positive"
    
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == 0 {
            
            if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
                
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .PhotoLibrary
                
                imagePicker.delegate = self
                
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    @IBAction func dateClick(sender: UITextField) {
    
        let datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(AddDiaryEntryViewController.handleDatePicker(_:)), forControlEvents: UIControlEvents.ValueChanged)
        btDone.hidden = false
    }
    
    @IBAction func locationClick(sender: UIButton) {
        self.performSegueWithIdentifier("segueShowMap", sender: self)
        
        
    }
    
    @IBAction func DoneButton(sender: UIButton) {
        tfDate.resignFirstResponder()
        btDone.hidden = true
    }
    
    func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        tfDate.text = dateFormatter.stringFromDate(sender.date)
    }

    
    @IBAction func saveDiary(sender: AnyObject) {
        titleText = tfTitle.text
        descriptionText = tfDescription.text
        locationText = tfLocation.text
        dateText = tfDate.text
        
        if titleText == "" || descriptionText == "" || dateText == "" {
            
            let alertController = UIAlertController(title: "Error", message: "All fields are required", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } else {
            if(longitude != 0 && latitude != 0) {
                if imageView.image != UIImage(named: "Placeholder") {
                    saveOK = true
                    self.performSegueWithIdentifier("unwindToDiaryEntries", sender: self)
                } else {
                    let alertController = UIAlertController(title: "Error", message: "Please choose an image", preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            } else {
                let alertController = UIAlertController(title: "Error", message: "Please set the diary location", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func unwindToAddDiaryEntrySave(segue: UIStoryboardSegue) {
        if(segue.sourceViewController.isKindOfClass(SelectLocationViewController))
        {
            let view:SelectLocationViewController = segue.sourceViewController as! SelectLocationViewController
            var index = 0
            if view.mapView.annotations[0].title! == "Current Location" {
                index = 1
            }
            
            let location = view.mapView.annotations[index]
            latitude = (location.coordinate.latitude)
            longitude = (location.coordinate.longitude)
            tfLocation.text = (location.title)!
            loadWeather(latitude, lon: longitude)
        }
    }
    
    @IBAction func unwindToAddDiaryEntriesRating(segue: UIStoryboardSegue) {
        if(segue.sourceViewController.isKindOfClass(RatingViewController))
        {
            let view:RatingViewController = segue.sourceViewController as! RatingViewController
            tfRating.text = view.rating
        }
    }
    
    func setWeather(){
        switch weather! {
        case "rain":
            imgWeather.image = UIImage(named: "Rain-52")
        case "clear":
            imgWeather.image = UIImage(named: "Sun-48")
        default:
            imgWeather.image = UIImage(named: "Clouds-48")

        }
    }
    
    func loadWeather(lat:Double, lon:Double){
        
        let todoEndpoint: String = "http://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&appid=70a59120832b540a2e4ed7501d1887fa&cnt=1"
        print(todoEndpoint)
        guard let url = NSURL(string: todoEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = NSURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(urlRequest) { (data, _, error) in// check for any errors
            guard error == nil else {
                print("error calling GET on /todos/1")
                print(error)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let todo = try NSJSONSerialization.JSONObjectWithData(responseData,
                                                                            options: []) as? [String: AnyObject] else {
                                                                                print("error trying to convert data to JSON")
                                                                                return
                }

                let temp = todo["list"] as! [[String:AnyObject]]
                let tempWeather = temp.first!["weather"] as! [[String:AnyObject]]
                let tempWeather2 = tempWeather.first!["main"] as! String

                self.weather = tempWeather2.lowercaseString
                self.setWeather()

            } catch {
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
        
    }
    
    @IBAction func unwindToAddDiaryEntryCancel(segue: UIStoryboardSegue) {
        if(segue.sourceViewController.isKindOfClass(SelectLocationViewController))
        {
            //let view:SelectLocationViewController = segue.sourceViewController as! SelectLocationViewController
            print("Canceled")
            
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        
        let leadingConstraint = NSLayoutConstraint(item: imageView, attribute: .Leading, relatedBy: .Equal, toItem: imageView.superview, attribute: .Leading, multiplier: 1, constant: 0)
        leadingConstraint.active = true
        
        let trailingConstraint = NSLayoutConstraint(item: imageView, attribute: .Trailing, relatedBy: .Equal, toItem: imageView.superview, attribute: .Trailing, multiplier: 1, constant: 0)
        trailingConstraint.active = true
        
        let topConstraint = NSLayoutConstraint(item: imageView, attribute: .Top, relatedBy: .Equal, toItem: imageView.superview, attribute: .Top, multiplier: 1, constant: 0)
        topConstraint.active = true
        
        let bottomConstraint = NSLayoutConstraint(item: imageView, attribute: .Bottom, relatedBy: .Equal, toItem: imageView.superview, attribute: .Bottom, multiplier: 1, constant: 0)
        bottomConstraint.active = true
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }

}