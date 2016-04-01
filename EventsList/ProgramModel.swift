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

    var title: String
    var ckRecordName: String
    var image440: String?
    
    init(title: String, ckRecordName: String, image440: String?) {
        self.title = title
        self.ckRecordName = ckRecordName
        self.image440 = image440
    }
    
    internal func retrieveImage440(imageName: String?, completion: (image: UIImage) -> Void) -> Void {
        
        // Exit if no imageNamge exists
        if imageName == nil {
            return
        }
        
        let cacheDirAsString = self.applicationDocumentsDirectory
        if cacheDirAsString == nil{
            print("Exit because cacheDirAsString is nil")
            return
        }
        
        let fileManager = NSFileManager.defaultManager()
        do {
            let arrayOfURLs = try fileManager.contentsOfDirectoryAtPath(cacheDirAsString!)
            print("contents of cache as string: \(arrayOfURLs)")
        }catch{
            print("Exit because failed to get contents of cacheDirAsString")
            return
        }
        
//        print("Looking inside the cache director with imageName: \(imageName)")
//        print("Looking inside the cache director with cacheAsString: \(cacheDirAsString)")
        
        // Get all files in this directory
        let fm = NSFileManager.defaultManager()
        
        do {
            let fileList = try fm.contentsOfDirectoryAtPath(cacheDirAsString!)
            
//            print("Looking inside the cache director with imageName: \(imageName)")
            
            // Return a cached image with a matching name
            for stringThing in fileList {
                
                var foundMatch = false
                if stringThing == imageName {
                    
                    foundMatch = true
                    
                    let cacheDir = NSURL.init(fileURLWithPath: cacheDirAsString!)
                    
                    let imagePath: NSURL = cacheDir.URLByAppendingPathComponent(imageName!)
                    print("This is the NSURL for the NSData PNG image in cache: \(imagePath)")
                    
                    let fileHandle = NSFileHandle.init(forReadingAtPath: imagePath.absoluteString)
                    
                    if fileHandle != nil{
                        let imageAsImage = UIImage.init(data: (fileHandle?.readDataToEndOfFile())!, scale: 1.0)
                        if imageAsImage != nil {
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                    completion(image: imageAsImage!)
                                })
                            
                        }else{
                            // Failed to read data as a UIImage
                            foundMatch = false
                        }
                        
                    }else{
                        // Failed to read data in cache
                        foundMatch = false
                    }
                    
                    // No need to continue in the loop if the match is successful already
                    if foundMatch == true{
                        break
                    }
                    
                }
                // No matching files were found in the cache, try to get from cloudKit
                if foundMatch == false {
                    
                    let myRecordID = CKRecordID.init(recordName: imageName!)
                    
                    let publicDatabase = CKContainer.defaultContainer().publicCloudDatabase
                    publicDatabase.fetchRecordWithID(myRecordID, completionHandler: { (ckRecord, error) in
                        if error != nil{
                            print("Exit because error trying to fetch imageName: \(imageName) with error: \(error)")
                        }else{
                            
                            let imageAsset = ckRecord?.objectForKey("image") as! CKAsset
                            
                            let imageData = NSData(contentsOfURL: imageAsset.fileURL)
                            if let image = UIImage(data: imageData!){
                                dispatch_async(dispatch_get_main_queue(), { 
                                    completion(image: image)
                                })
                                
//                                print("Found the image in cloudkit and returning to dataSource method")
                            }else{
                                print("Exit because failed to generate UIImage with data from CloudKit, with file: \(imageAsset.fileURL.absoluteString.stringByAppendingString(".png"))")
                            }
                        }
                    })
                }
            }
        }catch{
            print("Program > retrieveImage440 failed to get contents of cache directory")
        }
    }
    
    lazy var applicationDocumentsDirectory: String? = {
        
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        if paths.count > 0 {
            let basePath = paths[0]
            return basePath
        }else{
            return nil
        }
    }()

}
