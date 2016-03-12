//
//  Program+CoreDataProperties.swift
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

extension Program {

    @NSManaged var title: String?
    @NSManaged var descFull: String?
    @NSManaged var descMed: String?
    @NSManaged var descShort: String?
    @NSManaged var filmInfo: String?
    @NSManaged var video: String?
    @NSManaged var classInfo: String?
    @NSManaged var imageSmall: String?
    @NSManaged var imageLarge: String?
    @NSManaged var dateStart: NSDate?
    @NSManaged var dateEnd: NSDate?
    @NSManaged var hideFromPublic: NSNumber?
    @NSManaged var ticketLink: String?
    @NSManaged var venue: String?

}
