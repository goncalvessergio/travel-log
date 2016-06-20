//
//  FirstViewController.swift
//  Travel Log
//
//  Created by Sérgio Gonçalves on 24/05/16.
//  Copyright © 2016 Sérgio Gonçalves. All rights reserved.
//

import UIKit
import CoreData

class FirstViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {

    @IBOutlet weak var tvTrips: UITableView!
    // TableView array data
    var trips = [Trip]()
    let cellIdentifier = "travel_cell"
    /// CoreData connection variable
    let coreDataDB = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var currentTrip:Trip?
    var searchController: UISearchController!
    var searchResults:[Trip] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adding a search bar
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.barTintColor = UIColor(red: 64/255.0, green: 64/255.0, blue: 64/255.0, alpha: 1.0)
        searchController.searchBar.tintColor = UIColor(red: 255.0/255.0, green: 140/255.0, blue: 0/255.0, alpha: 1.0)
        tvTrips.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        // Load CoreData data
        trips = Trip.fetchAll(coreDataDB)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "sigaToTheSecondView") {
            let destinationVC = (segue.destinationViewController as! AddTripViewController)
            if sender is UIBarButtonItem {
                destinationVC.editTrip = nil
            } else {
                destinationVC.editTrip = currentTrip
            }
        } else if segue.identifier == "sigaToDiaryEntries" {
            let navVC = segue.destinationViewController as! UITabBarController
            let diaryVC = navVC.viewControllers![0] as! DiaryEntriesViewController
            diaryVC.trip = currentTrip!
        }
    }
    
    var valueToPass:String!
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.currentTrip = self.trips[indexPath.row]
        performSegueWithIdentifier("sigaToDiaryEntries", sender: self)
        
    }
    
    func insertTrip(title:String, details:String) {
        let entity = NSEntityDescription.entityForName("Trip", inManagedObjectContext: coreDataDB)
        // Use class "Trip" to create a new CoreData object
        let newTrip = Trip(entity: entity!, insertIntoManagedObjectContext: coreDataDB)
        newTrip.title = title
        newTrip.details = details
        
        // Add trip to array
        self.trips.append(newTrip)
        
        // CoreData save
        newTrip.save(self.coreDataDB)
        
        // Reload Coredata data
        self.trips = Trip.fetchAll(self.coreDataDB)
        
        // Reload TableView
        tvTrips.reloadData()
        
    }
    
    func updateTrip(title:String, details:String) {
        
        // Update trip data
        let trip = Trip.search((currentTrip?.title)!, details: (currentTrip?.details)!, inManagedObjectContext: self.coreDataDB)
        trip?.title = title
        trip?.details = details
        trip?.save(self.coreDataDB)
        
        // Reload Coredata data
        self.trips = Trip.fetchAll(self.coreDataDB)
        
        // Reload TableView
        self.tvTrips.reloadData()
        
    }
    
    @IBAction func unwindToFirst(segue: UIStoryboardSegue) {
        if(segue.sourceViewController.isKindOfClass(AddTripViewController))
        {
            let view2:AddTripViewController = segue.sourceViewController as! AddTripViewController
            
            if view2.editTrip != nil {
                updateTrip(view2.titleTrip!, details: view2.detailsTrip!)
            } else {
                insertTrip(view2.titleTrip!, details: view2.detailsTrip!)
            }
            
            view2.editTrip = nil
        }
    }
    
    func getAllTrips(){
        let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDel.managedObjectContext
        let fetch = NSFetchRequest(entityName: "Trip")
        
        var trips = []
        do {
            try
                trips = context.executeFetchRequest(fetch)
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        print("Número de resultados devolvidos \(trips.count)")
        
        for i in 0 ..< trips.count {
            let t:Trip = trips[i] as! Trip
            print (t.title)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active {
            return searchResults.count
        } else {
            return trips.count
        }
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
            self.currentTrip = self.trips[indexPath.row]
            self.performSegueWithIdentifier("sigaToTheSecondView", sender: self)
        }
        
        let deleteSwipteButton = UITableViewRowAction(style: .Normal, title: "Delete") { (action, indexPath) in
            // Find trip
            let tripDelete = self.trips[indexPath.row]
            
            // Delete trip in CoreData
            tripDelete.destroy(self.coreDataDB)
            
            // Save trip
            tripDelete.save(self.coreDataDB)
            
            // reload array data.
            self.trips = Trip.fetchAll(self.coreDataDB)
            
            // Remove trip from TableView
            self.tvTrips.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        
        editSwipeButton.backgroundColor    = UIColor.lightGrayColor()
        deleteSwipteButton.backgroundColor = UIColor.redColor()
        
        return [editSwipeButton, deleteSwipteButton]
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        let trip = (searchController.active) ? searchResults[indexPath.row] : trips[indexPath.row]
        
        cell.textLabel?.text = trip.title
        cell.detailTextLabel?.text = trip.details
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
    
    // updateSearchResultsForSearchController
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContentForSearchText(searchText)
            tvTrips.reloadData()
        }
    }
    
    func filterContentForSearchText(searchText: String) {
        print(trips)
        searchResults = trips.filter({ (trip: Trip) -> Bool in
            let tripTitle = trip.title
            if tripTitle == nil || tripTitle == "" {
                return false
            }
            let titleMatch = trip.title!.lowercaseString.rangeOfString(searchText.lowercaseString, options: NSStringCompareOptions.CaseInsensitiveSearch)
            print(titleMatch)
            return titleMatch != nil
        })
        print(searchResults)
    }
}

