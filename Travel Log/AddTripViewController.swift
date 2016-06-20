//
//  AddTripViewController.swift
//  Travel Log
//
//  Created by Sérgio Gonçalves on 24/05/16.
//  Copyright © 2016 Sérgio Gonçalves. All rights reserved.
//

import UIKit

class AddTripViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var tfDetails: UITextView!

    @IBOutlet weak var picker: UIPickerView!
    var titleTrip:String?
    var detailsTrip:String?
    var editTrip:Trip?
    let URLWS : String = "https://restcountries.eu/rest/v1/all"
    var resultCountries = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //loadCountries()
        
        tfTitle.delegate = self
        tfDetails.delegate = self
        if editTrip != nil {
            tfTitle.text = editTrip?.title
            tfDetails.text = editTrip?.details
        }
        
    }
    
    func loadCountries(){
        
        // test code goes here like this:
        let todoEndpoint: String = "https://restcountries.eu/rest/v1/region/europe"
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
                                                                            options: []) as? [[String: AnyObject]] else {
                                                                                print("error trying to convert data to JSON")
                                                                                return
                }
                
                for country in todo {
                  self.resultCountries.append(country["name"] as! String)
                }
                self.picker.dataSource = self
                self.picker.reloadAllComponents()
            } catch {
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
        
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return resultCountries[row]
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return resultCountries.count
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    @IBAction func setInputValues(sender: AnyObject) {
        titleTrip = tfTitle.text
        detailsTrip = tfDetails.text
        
        if(titleTrip != nil && detailsTrip != nil && titleTrip != "" && detailsTrip != ""){
            self.performSegueWithIdentifier("segueGoToFirst", sender: self)
        } else {
            let alert = UIAlertController(title: "Alert", message: "Please fill all of the fields", preferredStyle: .Alert)
            let firstAction = UIAlertAction(title: "Ok", style: .Default) {
                (alert: UIAlertAction!) -> Void in
            }
            alert.addAction(firstAction)
            presentViewController(alert, animated: true, completion:nil)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
}