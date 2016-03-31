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
//        let cacheDirAsString = cacheDir.absoluteString
        
        if cacheDirAsString == nil{
            print("Exit because cacheDirAsString is nil")
            return
        }
        
        let fileManager = NSFileManager.defaultManager()
        do {
            let arrayOfURLs = try fileManager.contentsOfDirectoryAtPath(cacheDirAsString!)
            print("contents of cache as string: \(arrayOfURLs)")
        }catch{
//            print("Failed to get contents of cacheAsString")
        }
        

        
//        print("Looking inside the cache director with imageName: \(imageName)")
//        print("Looking inside the cache director with cacheAsString: \(cacheDirAsString)")
        
        // Check if cache dir exists
        
        // Get all files in this directory
        let fm = NSFileManager.defaultManager()
        
        do {
            let fileList = try fm.contentsOfDirectoryAtPath(cacheDirAsString!)
            
//            print("Looking inside the cache director with imageName: \(imageName)")
            
            // return the cached image
            for stringThing in fileList {
                
                if stringThing == imageName {
                    
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
                            
                        }
                        
                    }else{
                        
                    }
                    
                    
                    
                    // ____!!!! Return the uiimage in the completion block !!!!____
                    
                }
            }
            
        }catch{
//            print("Program > retrieveImage440 failed to get contents of cache directory")
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
