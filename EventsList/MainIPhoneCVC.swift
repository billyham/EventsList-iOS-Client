//
//  MainIPhoneCVC.swift
//  EventsList
//
//  Created by Ray Smith on 3/1/16.
//  Copyright © 2016 Hamagain LLC. All rights reserved.
//

import UIKit
import CoreData
import CloudKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



class MainIPhoneCVC: UICollectionViewController {
    
    fileprivate let reuseIdentifier = "Cell"
    fileprivate var arrayOfEvents = [ProgramModel]()
    fileprivate var webView: webVC?
    
    internal var myContext: NSManagedObjectContext?
    internal var myNetworkController: NetworkController?
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register for notifications
        let defaultNotificationCenter = NotificationCenter.default
        defaultNotificationCenter.addObserver(self, selector: #selector(self.newImageInCache), name: NSNotification.Name(rawValue: "newImageInCache"), object: nil)
        
        // Register cell classes
//        self.collectionView!.registerClass(ProgramCVCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(UINib.init(nibName: "ProgramCVCell", bundle: nil), forCellWithReuseIdentifier: "Cell")

        // Initially populate array with content and present collection view
        self.updateCollectionView(type: "Add", arrayOfChanged: nil)
        
    }
    
    // MARK: - Public methods for changing content of collection view
    
    internal func updateCollectionView(type: String, arrayOfChanged: [CKRecord]?) {
        
        // Get an updated array of Programs objects
        
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Program")
        request.predicate = NSPredicate.init(format: "hideFromPublic == nil OR hideFromPublic == 0", argumentArray: nil)
        request.sortDescriptors = [NSSortDescriptor.init(key: "title", ascending: true)]
        
        var arrayOfNewEvents = [ProgramModel]()
        
        //execute the fetch and add to a new array
        do {
            let arrayResult = try myContext?.fetch(request)
            
            if arrayResult != nil{
                for object in arrayResult!{
                    let newObject = object as! Program
                    arrayOfNewEvents.append(ProgramModel.init(
                        title: (object as AnyObject).title!!,
                        ckRecordName: newObject.ckRecordName!,
                        image440: newObject.image440Name,
                        video: newObject.video
                    ))
                }
            }
            
            
        }catch let error as NSError{
            print("Failed to execute CoreData fetch: \(error)")
        }
        
        switch type{
            
        case "Add":
            
            if arrayOfChanged != nil{
                
                // Find destination indexpaths for added CKRecords
//                let arrayOfIndexPaths: [NSIndexPath] = arrayOfChanged.map({
//                    recordItem in
//                    
//                    for i in 0..<arrayOfNewEvents.count {
//                        
//                        if arrayOfNewEvents[i].ckRecordName == recordItem.recordID.recordName {
//                            return NSIndexPath.init(index: i)
//                            break;
//                        }
//                    }
//                    
//                    
//                })!
                
                var arrayOfIndexPaths = [IndexPath]()
                
                for record in arrayOfChanged! {
                    
                    for i in 0..<arrayOfNewEvents.count {
                        
                        if record.recordID.recordName == arrayOfNewEvents[i].ckRecordName {
                            arrayOfIndexPaths.append(IndexPath.init(item: i, section: 0))
                            break
                        }
                    }
                }
                
                if arrayOfIndexPaths.count > 0 {
                    self.arrayOfEvents = arrayOfNewEvents
                    DispatchQueue.main.async(execute: {
                        self.collectionView!.insertItems(at: arrayOfIndexPaths)
                    })
                }
                
            }else{
                
                fallthrough
            }
            
        case "Update":
            
            if arrayOfChanged != nil {
                
                var indexPathOld = IndexPath.init()
                var indexPathNew = IndexPath.init()
                
                for record in arrayOfChanged! {
                    
                    for i in 0..<arrayOfNewEvents.count {
                        
                        if record.recordID.recordName == arrayOfNewEvents[i].ckRecordName {
                            indexPathNew = IndexPath.init(item: i, section: 0)
                            break
                        }
                    }

                    for i in 0..<self.arrayOfEvents.count {
                        
                        if record.recordID.recordName == self.arrayOfEvents[i].ckRecordName {
                            indexPathOld = IndexPath.init(item: i, section: 0)
                            break
                        }
                    }
                    
                    self.arrayOfEvents = arrayOfNewEvents
                    DispatchQueue.main.async(execute: {
                        self.collectionView?.moveItem(at: indexPathOld, to: indexPathNew)
                        self.collectionView?.reloadItems(at: [indexPathNew])
                    })
                }
                
            }else{
                
                fallthrough
            }
            
            
        default:
            
            // #### Wholesale array replacement ####
            
            self.arrayOfEvents = []
            
            do {
                let arrayResult = try myContext?.fetch(request)
                
                if arrayResult != nil{
                    for object in arrayResult!{
                        if (object as AnyObject).title != nil{
                            let newObject = object as! Program
                            self.arrayOfEvents.append(ProgramModel.init(
                                title: (object as AnyObject).title!!,
                                ckRecordName: newObject.ckRecordName!,
                                image440: newObject.image440Name,
                                video: newObject.video
                            ))
                        }
                    }
                    DispatchQueue.main.async(execute: {
                        self.collectionView?.reloadData()
                    })
                }
                
                
            }catch let error as NSError{
                print("Failed to execute CoreData fetch: \(error)")
            }
        }
    }

    internal func deleteFromCollectionView(_ arrayOfChanged:[CKRecordID]?) -> Void {
        
        // Get an updated array of Programs objects
        
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Program")
        request.predicate = NSPredicate.init(format: "hideFromPublic == nil OR hideFromPublic == 0", argumentArray: nil)
        request.sortDescriptors = [NSSortDescriptor.init(key: "title", ascending: true)]
        
        var arrayOfNewEvents = [ProgramModel]()
        
        //execute the fetch and add to a new array
        do {
            let arrayResult = try myContext?.fetch(request)
            
            for object in arrayResult!{
                let newObject = object as! Program
                arrayOfNewEvents.append(ProgramModel.init(
                    title: (object as AnyObject).title!!,
                    ckRecordName: newObject.ckRecordName!,
                    image440: newObject.image440Name,
                    video: newObject.video
                    ))
            }
            
        }catch let error as NSError{
            print("Failed to execute CoreData fetch: \(error)")
        }
        
        if arrayOfChanged != nil {
            
            var arrayOfIndexPaths = [IndexPath]()
            
            for recordID in arrayOfChanged! {
                
                for i in 0..<self.arrayOfEvents.count {
                    
                    if recordID.recordName == self.arrayOfEvents[i].ckRecordName {
                        arrayOfIndexPaths.append(IndexPath.init(item: i, section: 0))
                        break
                    }
                }
            }
            
            if arrayOfIndexPaths.count > 0 {
                self.arrayOfEvents = arrayOfNewEvents
                DispatchQueue.main.async(execute: {
                    self.collectionView!.deleteItems(at: arrayOfIndexPaths)
                })
                
            }
            
        }else{
            
            // #### Wholesale array replacement ####
            
            self.arrayOfEvents = arrayOfNewEvents
            DispatchQueue.main.async(execute: {
                self.collectionView?.reloadData()
            })
        }
    }
    
    
    // MARK: - Responding to Changes in image cache
    
    func newImageInCache(_ note: Notification) {
        
        if (note as NSNotification).userInfo != nil {
            let userDictionary = (note as NSNotification).userInfo
            let imageName = userDictionary!["imageName"] as! String
            print("notification fires, this is the userInfo: \(userDictionary!["imageName"])")
            
            for index in 0..<self.arrayOfEvents.count {
                if self.arrayOfEvents[index].image440 == imageName {
                    self.collectionView?.reloadItems(at: [IndexPath.init(row: index, section: 0)])
                    print("did reload item at index: \(index)")
                    break
                }
            }
        }else{
            print("notification fires with no userInfo")
        }
        
    }
    
    
    // MARK: - Responding to orientation changes
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        // Force a layout refresh
        self.collectionView?.collectionViewLayout.invalidateLayout()
        
        let widthValue = size.width
        if widthValue < 400 {
            print("Rotated to portrait")
        }else{
            print("Rotated to landscape")
        }
        
        // OK, sure, this. Un huh
        coordinator.animate(alongsideTransition: nil) { (context) in
            
            if self.collectionView?.numberOfSections > 0 {
                if self.collectionView?.numberOfItems(inSection: 0) > 0{
                    
                    // Scroll to top
                    self.collectionView!.scrollToItem(at: IndexPath.init(row: 0, section: 0), at: UICollectionViewScrollPosition.top, animated: false)
                }
            }
        }
        
        super.viewWillTransition(to: size, with: coordinator)
    }
    
//    override func viewWillLayoutSubviews() {
//        
//    }
//    
//    override func viewDidLayoutSubviews() {
//
//    }
    
    // MARK: - Retrieve image locally 
    func retrieveImage(_ imageName: String) -> UIImage? {
        
        let cacheDirAsString = self.applicationDocumentsCacheDirectory
        if cacheDirAsString == nil{
            print("Exit because cacheDirAsString is nil")
            return nil
        }
        
        // Get all files in the cache directory
        let fm = FileManager.default
        
        do {
            let fileList = try fm.contentsOfDirectory(atPath: cacheDirAsString!)
            
            // Return a cached image with a matching name
            for stringThing in fileList {
                
                if stringThing == imageName {
                    
                    let cacheDir = URL.init(fileURLWithPath: cacheDirAsString!)
                    
                    let imagePath: URL = cacheDir.appendingPathComponent(imageName)
                    
                    do {
                        let fileHandle = try FileHandle.init(forReadingFrom:imagePath)
                        
                        let imageAsImage = UIImage.init(data: (fileHandle.readDataToEndOfFile()), scale: 1.0)
                        if imageAsImage != nil {
                            return imageAsImage
                        }else{
                            // Failed to read data as a UIImage
                            print("Failed to read data as a UIImage")
                            return nil
                        }
                    }catch{
                        // Failed to read data in cache
                        print("Failed to read data in cache")
                        return nil
                    }
                }
            }
        }catch{
            print("Program > retrieveImage440 failed to get contents of cache directory")
            return nil
        }
        return nil
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
    
    
    // MARK: - Flow Layout Delegate methods
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize{
    
        if self.collectionView!.frame.size.width < 400 {
            return CGSize.init(width: self.collectionView!.frame.size.width, height: 65.0)
        }else{
            let widthFraction = self.collectionView!.frame.size.width / 5.0
            return CGSize.init(width: widthFraction, height: widthFraction)
        }
        
    }
    

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return arrayOfEvents.count        
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ProgramCVCell
        cell.contentView.clipsToBounds = true
        
        let modelObject = self.arrayOfEvents[(indexPath as NSIndexPath).row]
        cell.assignValues(modelObject.title, image440: modelObject.image440)
        
        // For re-used cells, remove the image if it doesn't match the
        // desired image name
        if modelObject.image440 != cell.imageName {
            if cell.image != nil {
                cell.image!.image = nil
            }
        }
        
        // ####
        // If modelObject has a value for image440Name...
        // Get image from local store
        // If it doesn't exist locally...
        // Have the network controller get the image and save locally
        // And then fire a notification that tells this VC to re-render the cell
        // ####
        
        if modelObject.image440 != nil {
            
            if let imageAsImage = self.retrieveImage(modelObject.image440!){
                if cell.image != nil {
                    cell.image!.image = imageAsImage
                    cell.imageName = modelObject.image440
                }
            }else{
                
                if self.myNetworkController != nil {
                    self.myNetworkController?.requestImageFromCloud(modelObject.image440!, completion: {
                        booleanValue in
                        
                        if (booleanValue == true){
                            print("completion says true")
                        }else{
                            print("completion is false")
                        }
                    })
                }
            }
        }
        
        return cell
    }

    // MARK: - UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Action depends on current orientation...
        
        let thisOrientation = UIDevice.current.orientation
        if thisOrientation == UIDeviceOrientation.portrait{
            self.performSegue(withIdentifier: "showDetail", sender: self.navigationController)
            
        }else{
            let webView = webVC.init(nibName: "webVC", bundle: nil)
            webView.video = self.arrayOfEvents[(indexPath as NSIndexPath).row].video
            self.webView = webView
            self.modalPresentationStyle = UIModalPresentationStyle.formSheet
            self.present(self.webView!, animated: true) {
                
            }
        }
        
        
    }
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - Memory Warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
