//
//  DiaryEntry+CoreDataProperties.swift
//  Travel Log
//
//  Created by CapitanBanana on 04/06/16.
//  Copyright © 2016 CapitanBanana. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension DiaryEntry {

    @NSManaged var date: NSDate?
    @NSManaged var location_lat: String?
    @NSManaged var location_long: String?
    @NSManaged var text: String?
    @NSManaged var title: String?
    @NSManaged var image: NSData?
    @NSManaged var trip: Trip?

}
