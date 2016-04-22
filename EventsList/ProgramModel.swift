//
//  EventModel.swift
//  EventsList
//
//  Created by Ray Smith on 3/1/16.
//  Copyright © 2016 Hamagain LLC. All rights reserved.
//

import UIKit
import CloudKit

class ProgramModel: NSObject {

    let title: String
    let ckRecordName: String
    let image440: String?
    let video: String?
    
    init(title: String, ckRecordName: String, image440: String?, video: String?) {
        self.title = title
        self.ckRecordName = ckRecordName
        self.image440 = image440
        self.video = video
    }


}
