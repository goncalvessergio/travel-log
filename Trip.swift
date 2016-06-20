//
//  Trip.swift
//  Travel Log
//
//  Created by Sérgio Gonçalves on 26/05/16.
//  Copyright © 2016 Sérgio Gonçalves. All rights reserved.
//

import Foundation
import CoreData

@objc(Trip)
class Trip: NSManagedObject {

    /// Function to initialize a new Trip
    convenience init(title: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Trip", inManagedObjectContext: managedObjectContext)!
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
        self.title = title
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
    
    /// Function to check duplicate item
    ///
    /// - parameter name: Item name
    /// - parameter managedObjectContext: CoreData Connection
    ///
    class func checkDuplicate(name: String, details: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> Bool {
        return search(name, details: details, inManagedObjectContext: managedObjectContext) != nil
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
    class func fetchAll(managedObjectContext: NSManagedObjectContext) -> [Trip] {
        let listagemCoreData             = NSFetchRequest(entityName: "Trip")
        
        // Sort alphabetical by field "name"
        //let orderByName = NSSortDescriptor(key: "name", ascending: true, selector: "caseInsensitiveCompare:")
        //listagemCoreData.sortDescriptors = [orderByName]
        
        // Get items from CoreData
        return (try? managedObjectContext.executeFetchRequest(listagemCoreData)) as? [Trip] ?? []
    }
    
    /// Function to search trip by name, details or both
    ///
    /// - parameter title: Trip title
    /// - parameter managedObjectContext: CoreData Connection
    ///
    class func search(title: String, details: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> Trip? {
        let fetchRequest       = NSFetchRequest(entityName: "Trip")
        let firstPredicate = NSPredicate(format: "title = %@", title)
        let secondPredicate = NSPredicate(format: "details = %@", details)
        let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates: [firstPredicate, secondPredicate])

        fetchRequest.predicate = predicate
        //fetchRequest.predicate = NSPredicate(format: "title = %@", title)
        
        let result             = (try? managedObjectContext.executeFetchRequest(fetchRequest)) as? [Trip]
        return result?.first
    }
}
