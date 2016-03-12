//
//  Date+CoreDataProperties.swift
//  EventsList
//
//  Created by Dave Hanagan on 3/11/16.
//  Copyright © 2016 Hamagain LLC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Date {

    @NSManaged var dateStart: NSDate?
    @NSManaged var dateEnd: NSDate?
    @NSManaged var live: NSNumber?
    @NSManaged var hideFromPublic: NSNumber?
    @NSManaged var dateAvailable: NSDate?
    @NSManaged var programRef: Program?

}
