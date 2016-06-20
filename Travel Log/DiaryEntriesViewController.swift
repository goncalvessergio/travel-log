//
//  DiaryEntriesViewController.swift
//  Travel Log
//
//  Created by Sérgio Gonçalves on 04/06/16.
//  Copyright © 2016 Sérgio Gonçalves. All rights reserved.
//

import UIKit
import CoreData

class DiaryEntriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {

    @IBOutlet weak var tvDiaryEntries: UITableView!
    var searchController: UISearchController!
    var diaryEntries = [DiaryEntry]()
    let coreDataDB = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let cellIdentifier = "diaryCell"
    var trip : Trip?
    var currentDiary : DiaryEntry?
    // Stores the result of search
    var searchResults:[DiaryEntry] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adding a search bar
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.barTintColor = UIColor(red: 64/255.0, green: 64/255.0, blue: 64/255.0, alpha: 1.0)
        tvDiaryEntries.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        // Load CoreData data
        diaryEntries = DiaryEntry.searchByTrip(trip!, inManagedObjectContext: coreDataDB)
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active {
            return searchResults.count
        } else {
            return diaryEntries.count
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "sigaToViewDiary" {
            let navVC = segue.destinationViewController as! UINavigationController
            let diaryVC = navVC.viewControllers[0] as! DiaryEntryDetailsViewController
            diaryVC.diaryEntry = currentDiary!
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.currentDiary = self.diaryEntries[indexPath.row]
        performSegueWithIdentifier("sigaToViewDiary", sender: self)
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! DiaryEntryTableViewCell
        let diaryEntry = (searchController.active) ? searchResults[indexPath.row] : diaryEntries[indexPath.row]

        cell.title.text = diaryEntry.title
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = NSTimeZone(name: "GMT")
        let diaryDate:String = dateFormatter.stringFromDate(diaryEntry.date!)
        cell.date.text = diaryDate
        cell.location.text = diaryEntry.text
        //cell.thumbnail.image = UIImage(named: "Placeholder")
        cell.thumbnail.image = UIImage(data: diaryEntry.image!)
        
        let rating : Bool = diaryEntry.rating == "Positive" ? true : false
        
        cell.accessoryType = rating ? .Checkmark : .None
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if searchController.active {
            return false
        } else {
            return true
        }
    }
    
    // Allow actions on cell swipe in TableView
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    // Actions on cell swipe in TableView
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let editSwipeButton = UITableViewRowAction(style: .Default, title: "Edit") { (action, indexPath) in
            self.currentDiary = self.diaryEntries[indexPath.row]
            //self.performSegueWithIdentifier("sigaToTheSecondView", sender: self)
        }
        
        let deleteSwipteButton = UITableViewRowAction(style: .Normal, title: "Delete") { (action, indexPath) in
            
            print(indexPath)
            print(indexPath.row)
            // Find Diary Entry
            let diaryDelete = self.diaryEntries[indexPath.row]
            
            // Delete diary entry in CoreData
            diaryDelete.destroy(self.coreDataDB)
            
            // Save
            diaryDelete.save(self.coreDataDB)
            
            // reload array data.
            self.diaryEntries = DiaryEntry.searchByTrip(self.trip!, inManagedObjectContext: self.coreDataDB)
            print(self.diaryEntries)
            // Remove diary entry from TableView
            self.tvDiaryEntries.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        
        editSwipeButton.backgroundColor    = UIColor.lightGrayColor()
        deleteSwipteButton.backgroundColor = UIColor.redColor()
        
        return [editSwipeButton, deleteSwipteButton]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func prepareToinsertDiaryEntry(titleText:String, descriptionText:String, dateText:String, latitude:Double, longitude:Double, location:String, weather:String, rating:String, image:NSData) {
        
        let diary = DiaryEntry.insertDiaryEntry(titleText, descriptionText:descriptionText, dateText:dateText,
                                                latitude:latitude, longitude:longitude, location:location, weather: weather, rating:rating, image:image, coreDataDB:coreDataDB, trip:trip!)

        // Add diary to array
        self.diaryEntries.append(diary)
        
        // Reload Coredata data
        self.diaryEntries = DiaryEntry.searchByTrip(trip!, inManagedObjectContext: coreDataDB)
        
        // Reload TableView
        tvDiaryEntries.reloadData()
        
    }
    
    @IBAction func unwindToDiaryEntries(segue: UIStoryboardSegue) {
        if(segue.sourceViewController.isKindOfClass(AddDiaryEntryViewController))
        {
            let view:AddDiaryEntryViewController = segue.sourceViewController as! AddDiaryEntryViewController
            if view.saveOK == true {
                var diaryImagePNG : NSData = NSData()
                if let diaryImage = view.imageView.image {
                    diaryImagePNG = UIImagePNGRepresentation(diaryImage)!
                }
                prepareToinsertDiaryEntry(view.titleText!, descriptionText: view.descriptionText!, dateText: view.dateText, latitude: view.latitude, longitude:view.longitude, location: view.tfLocation.text!, weather: view.weather!, rating:view.tfRating.text!, image: diaryImagePNG)
            }
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContentForSearchText(searchText)
            tvDiaryEntries.reloadData()
        }
    }
    
    func filterContentForSearchText(searchText: String) {
        searchResults = diaryEntries.filter({ (diaryEntry: DiaryEntry) -> Bool in
            let diaryTitle = diaryEntry.title
            if diaryTitle == nil || diaryTitle == "" {
                return false
            }
            let titleMatch = diaryEntry.title!.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)

            return titleMatch != nil
        })
    }
    
}

