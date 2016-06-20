//
//  DiaryEntry+CoreDataProperties.swift
//  Travel Log
//
//  Created by Sérgio Gonçalves on 11/06/16.
//  Copyright © 2016 Sérgio Gonçalves. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension DiaryEntry {

    @NSManaged var date: NSDate?
    @NSManaged var image: NSData?
    @NSManaged var location_lat: NSNumber?
    @NSManaged var location_long: NSNumber?
    @NSManaged var text: String?
    @NSManaged var title_diary: String?
    @NSManaged var weather: String?
    @NSManaged var location_name: String?
    @NSManaged var rating: String?
    @NSManaged var trip: Trip?

}
