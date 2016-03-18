//
//  EventModel.swift
//  EventsList
//
//  Created by Ray Smith on 3/1/16.
//  Copyright © 2016 Hamagain LLC. All rights reserved.
//

import UIKit

class ProgramModel: NSObject {

    var title: String
    var ckRecordName: String
    
    init(title: String, ckRecordName: String) {
        self.title = title
        self.ckRecordName = ckRecordName
    }
}
