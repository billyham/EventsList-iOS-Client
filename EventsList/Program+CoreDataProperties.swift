//
//  Program+CoreDataProperties.swift
//  EventsList
//
//  Created by Ray Smith on 3/30/16.
//  Copyright © 2016 Hamagain LLC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Program {

    @NSManaged var ckRecord: NSData?
    @NSManaged var ckRecordName: String?
    @NSManaged var classInfo: String?
    @NSManaged var dateEnd: NSDate?
    @NSManaged var dateStart: NSDate?
    @NSManaged var descFull: String?
    @NSManaged var descMed: String?
    @NSManaged var descShort: String?
    @NSManaged var filmInfo: String?
    @NSManaged var hideFromPublic: NSNumber?
    @NSManaged var imageLarge: String?
    @NSManaged var imageSmall: String?
    @NSManaged var ticketLink: String?
    @NSManaged var title: String?
    @NSManaged var venue: String?
    @NSManaged var video: String?
    @NSManaged var image440Name: String?
    @NSManaged var image440Ref: NSData?
    @NSManaged var dateRef: NSSet?

}
