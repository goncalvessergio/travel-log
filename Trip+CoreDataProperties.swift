//
//  Trip+CoreDataProperties.swift
//  Travel Log
//
//  Created by Sérgio Gonçalves on 26/05/16.
//  Copyright © 2016 Sérgio Gonçalves. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Trip {

    @NSManaged var title: String?
    @NSManaged var details: String?
    @NSManaged var diary_entries: NSSet?

}
