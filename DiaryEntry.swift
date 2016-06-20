//
//  DiaryEntry.swift
//  Travel Log
//
//  Created by Sérgio Gonçalves on 26/05/16.
//  Copyright © 2016 Sérgio Gonçalves. All rights reserved.
//

import Foundation
import CoreData
import MapKit

@objc(DiaryEntry)
class DiaryEntry: NSManagedObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(location_lat as! Double, location_long as! Double)
    }
    
    var title: String? {
        return self.title_diary
    }
    
    var subtitle: String? {
        return text
    }
    
    /// Function to save CoreData values
    func save(managedObjectContext: NSManagedObjectContext) {
        do {
            try managedObjectContext.save()
        }
        catch {
            let nserror = error as NSError
            print("Error on save: \(nserror.debugDescription)")
        }
    }
    
    class func insertDiaryEntry(titleText:String, descriptionText:String, dateText:String, latitude:Double, longitude:Double, location:String, weather:String, rating:String, image:NSData, coreDataDB: NSManagedObjectContext, trip:Trip) -> DiaryEntry{
        let entity = NSEntityDescription.entityForName("DiaryEntry", inManagedObjectContext: coreDataDB)
        let newDiary = DiaryEntry(entity: entity!, insertIntoManagedObjectContext: coreDataDB)
        newDiary.title_diary = titleText
        newDiary.text = descriptionText
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = NSTimeZone(name: "GMT")
        let diaryDate:NSDate = dateFormatter.dateFromString(dateText)!
        newDiary.date = diaryDate
        newDiary.location_lat = latitude
        newDiary.location_long = longitude
        newDiary.image = image
        newDiary.weather = weather
        newDiary.location_name = location
        newDiary.rating = rating
        newDiary.trip = Trip.search((trip.title)!, details: "", inManagedObjectContext: coreDataDB)
        // CoreData save
        newDiary.save(coreDataDB)
        return newDiary
    }
    
    /// Function to check duplicate item
    ///
    /// - parameter name: Item name
    /// - parameter managedObjectContext: CoreData Connection
    ///
    class func checkDuplicate(title: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> Bool {
        return search(title, inManagedObjectContext: managedObjectContext) != nil
    }
    
    /// Function to delete a item
    ///
    /// - parameter managedObjectContext: CoreData Connection
    ///
    func destroy(managedObjectContext: NSManagedObjectContext) {
        managedObjectContext.deleteObject(self)
    }
    
    /// Function to get all CoreData values
    ///
    /// - parameter managedObjectContext: CoreData Connection
    ///
    class func fetchAll(managedObjectContext: NSManagedObjectContext) -> [DiaryEntry] {
        let listagemCoreData             = NSFetchRequest(entityName: "DiaryEntry")
        
        // Sort alphabetical by field "name"
        //let orderByName = NSSortDescriptor(key: "name", ascending: true, selector: "caseInsensitiveCompare:")
        //listagemCoreData.sortDescriptors = [orderByName]
        
        // Get items from CoreData
        return (try? managedObjectContext.executeFetchRequest(listagemCoreData)) as? [DiaryEntry] ?? []
    }
    
    /// Function to search Diary Entry by title
    ///
    /// - parameter title: Diary Entry title
    /// - parameter managedObjectContext: CoreData Connection
    ///
    class func search(title: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> DiaryEntry? {
        let fetchRequest       = NSFetchRequest(entityName: "DiaryEntry")
        let firstPredicate = NSPredicate(format: "title = %@", title)
        //let secondPredicate = NSPredicate(format: "details = %@", details)
        let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates: [firstPredicate])
        
        fetchRequest.predicate = predicate
        //fetchRequest.predicate = NSPredicate(format: "title = %@", title)
        
        let result             = (try? managedObjectContext.executeFetchRequest(fetchRequest)) as? [DiaryEntry]
        return result?.first
    }
    
    class func searchByTrip(trip: Trip, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> [DiaryEntry] {
        let fetchRequest       = NSFetchRequest(entityName: "DiaryEntry")
        let firstPredicate = NSPredicate(format: "trip = %@", trip)
        let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates: [firstPredicate])
        
        fetchRequest.predicate = predicate
        
        let result             = (try? managedObjectContext.executeFetchRequest(fetchRequest)) as? [DiaryEntry]
        return result!
    }

}
