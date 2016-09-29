//
//  NetworkController.swift
//  EventsList
//
//  Created by Ray Smith on 4/4/16.
//  Copyright © 2016 Hamagain LLC. All rights reserved.
//

// #### Follows example from https://realm.io/news/slug-marcus-zarra-exploring-mvcn-swift/ ####

import UIKit
import CoreData
import CloudKit

// A small discrete unit of work
class MyImageRequest: Operation {
    
    var context: NSManagedObjectContext?
    fileprivate var innerContext: NSManagedObjectContext?
    let imageName: String
    let cacheDir: String?
    
    init(imageName: String, cacheDir: String?) {
        self.imageName = imageName
        self.cacheDir = cacheDir
        super.init()
    }
    
    override func main() {
        
        if self.isCancelled {
            return
        }
        
        let myRecordID = CKRecordID.init(recordName: self.imageName)
        
        let publicDatabase = CKContainer.default().publicCloudDatabase
        publicDatabase.fetch(withRecordID: myRecordID, completionHandler: { (ckRecord, error) in
            if error != nil{
                print("Exit because error trying to fetch imageName: \(self.imageName) with error: \(error)")
            }else{
                
                let imageAsset = ckRecord?.object(forKey: "image") as! CKAsset
                
                let imageData = try? Data(contentsOf: imageAsset.fileURL)
                if let image = UIImage(data: imageData!){
                    
                    // Save image to cache
                    self.saveImage(image, imageName: self.imageName)
                    
                    // Do this in the main thread...
                    DispatchQueue.main.async(execute: {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "newImageInCache"), object: nil, userInfo: ["imageName": self.imageName])
                    })
                    
                }else{
                    print("Exit because failed to generate UIImage with data from CloudKit, with file: \(imageAsset.fileURL.absoluteString + ".png")")
                }
            }
        })
    }
    
    func saveImage(_ image: UIImage, imageName: String) {
        
        if self.cacheDir == nil {
            print("MyImageSave has nil for cacheDir")
            return
        }
        
        let PNGImage = UIImagePNGRepresentation(image)
        
        if PNGImage == nil {
            print ("Exit because failed to create PNGimage")
            return
        }
        
        let path = self.cacheDir! + "/" + imageName
        
        let ok = FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
        
        if ok == false {
            print("Exit because Error creating image file")
            return
        }
        
        let cacheDir = URL.init(fileURLWithPath: self.cacheDir!)
        let imagePath: URL = cacheDir.appendingPathComponent(imageName)
        
        do {
            let myFileHandle = try FileHandle.init(forWritingTo: imagePath)
            myFileHandle.write(PNGImage!)
            myFileHandle.closeFile()
            print("Saved image to cache")
            return
        }catch{
            print("NSURL throws error")
            return
        }
    }
}


//class MyImageSave: NSOperation {
//    
//    var context: NSManagedObjectContext?
//    private var innerContext: NSManagedObjectContext?
//    let imageName: String
//    let image: UIImage
//    let cacheDir: String?
//    var success: Bool = false
//    
//    init(image: UIImage, imageName: String, cacheDir: String?) {
//        self.imageName = imageName
//        self.image = image
//        self.cacheDir = cacheDir
//        super.init()
//    }
//    
//    override func main() {
//        
//        if self.cancelled {
//            return
//        }
//        
//        if self.cacheDir == nil {
//            print("MyImageSave has nil for cacheDir")
//            return
//        }
//        
//        let PNGImage = UIImagePNGRepresentation(image)
//        
//        if PNGImage == nil {
//            print ("Exit because failed to create PNGimage")
//            return
//        }
//        
//        let path = self.cacheDir! + "/" + imageName
//        
//        let ok = NSFileManager.defaultManager().createFileAtPath(path, contents: nil, attributes: nil)
//        
//        if ok == false {
//            print("Exit becauseeError creating image file")
//            return
//            
//        }
//        
//        let cacheDir = NSURL.init(fileURLWithPath: self.cacheDir!)
//        let imagePath: NSURL = cacheDir.URLByAppendingPathComponent(imageName)
//        
//        do {
//            let myFileHandle = try NSFileHandle.init(forWritingToURL: imagePath)
//            myFileHandle.writeData(PNGImage!)
//            myFileHandle.closeFile()
//            print("Saved image to cache")
//            self.success = true
//            return
//        }catch{
//            print("NSURL throws error")
//            return
//        }
//    }
//}


class NetworkController: NSObject {

    let queue = OperationQueue()
    var myContext: NSManagedObjectContext?
    
    lazy var imageQueue: OperationQueue = {
       var queue = OperationQueue()
        queue.name = "Image queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    init(context: NSManagedObjectContext?) {
        self.myContext = context
    }
    
    
    
    // MARK: - Image Cache
    
    internal func requestImageFromCloud(_ imageName: String, completion: ((Bool) -> Void)) {
        
        // ####
        // Get images from CloudKit
        // Place in cache i.e. cache folder in app document folder
        // Tell view controller that an update has occurred, it will re-render the appropriate cells
        // ####
        
        let request = MyImageRequest.init(imageName: imageName,
                                          cacheDir: self.applicationDocumentsCacheDirectory)
        
        let operationQueue = imageQueue
        operationQueue.addOperation(request)
        
        // This return value is misleading, it potentially fires before the execution of the NSOperation
        completion(true)
    }
    
    
    // MARK: - Cache Directory
    
    lazy var applicationDocumentsCacheDirectory: String? = {
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        if paths.count > 0 {
            let basePath = paths[0]
            return basePath
        }else{
            return nil
        }
    }()
    
    // MARK: - Suggested methdos from Marcus Zarra demo
    
    func requestMyData() {
        
    }
    
//    func requestData() -> NSFetchedResultsController {
//        
//    }
    
    func requestData(_ completion: (Void) -> Bool) {
        
    }
    
}
