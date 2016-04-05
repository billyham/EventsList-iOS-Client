//
//  NetworkController.swift
//  EventsList
//
//  Created by Ray Smith on 4/4/16.
//  Copyright © 2016 Hamagain LLC. All rights reserved.
//

//  ____!!!!  Follows example from https://realm.io/news/slug-marcus-zarra-exploring-mvcn-swift/  !!!!____

import UIKit
import CoreData

class NetworkController: NSObject {

    let queue = NSOperationQueue()
    var myContext: NSManagedObjectContext?
    
    init(context: NSManagedObjectContext) {
        self.myContext = context
    }
    
    func requestMyData() {
        
    }
    
//    func requestData() -> NSFetchedResultsController {
//        
//    }
    
    func requestData(completion: (Void) -> Bool) {
        
    }
    
}
