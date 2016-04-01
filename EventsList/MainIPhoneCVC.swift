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


class MainIPhoneCVC: UICollectionViewController {
    
    private let reuseIdentifier = "Cell"
    private var arrayOfEvents = [ProgramModel]()
    
    internal var myContext: NSManagedObjectContext?

    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.registerClass(ProgramCVCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.registerNib(UINib.init(nibName: "ProgramCVCell", bundle: nil), forCellWithReuseIdentifier: "Cell")

        // Initially populate array with content and present collection view
        self.updateCollectionView(type: "Add", arrayOfChanged: nil)
        
    }
    
    // MARK: - Public methods for changing content of collection view
    
    internal func updateCollectionView(type type: String, arrayOfChanged: [CKRecord]?) {
        
        // Get an updated array of Programs objects
        
        let request = NSFetchRequest.init(entityName: "Program")
        request.predicate = NSPredicate.init(format: "hideFromPublic == nil OR hideFromPublic == 0", argumentArray: nil)
        request.sortDescriptors = [NSSortDescriptor.init(key: "title", ascending: true)]
        
        var arrayOfNewEvents = [ProgramModel]()
        
        //execute the fetch and add to a new array
        do {
            let arrayResult = try myContext?.executeFetchRequest(request)
            
            for object in arrayResult!{
                let newObject = object as! Program
                arrayOfNewEvents.append(ProgramModel.init(title: object.title!!, ckRecordName: newObject.ckRecordName!, image440: newObject.image440Name))
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
                
                var arrayOfIndexPaths = [NSIndexPath]()
                
                for record in arrayOfChanged! {
                    
                    for i in 0..<arrayOfNewEvents.count {
                        
                        if record.recordID.recordName == arrayOfNewEvents[i].ckRecordName {
                            arrayOfIndexPaths.append(NSIndexPath.init(forItem: i, inSection: 0))
                            break
                        }
                    }
                }
                
                if arrayOfIndexPaths.count > 0 {
                    self.arrayOfEvents = arrayOfNewEvents
                    dispatch_async(dispatch_get_main_queue(), {
                        self.collectionView!.insertItemsAtIndexPaths(arrayOfIndexPaths)
                    })
                }
                
            }else{
                
                fallthrough
            }
            
        case "Update":
            
            if arrayOfChanged != nil {
                
                var indexPathOld = NSIndexPath.init()
                var indexPathNew = NSIndexPath.init()
                
                for record in arrayOfChanged! {
                    
                    for i in 0..<arrayOfNewEvents.count {
                        
                        if record.recordID.recordName == arrayOfNewEvents[i].ckRecordName {
                            indexPathNew = NSIndexPath.init(forItem: i, inSection: 0)
                            break
                        }
                    }

                    for i in 0..<self.arrayOfEvents.count {
                        
                        if record.recordID.recordName == self.arrayOfEvents[i].ckRecordName {
                            indexPathOld = NSIndexPath.init(forItem: i, inSection: 0)
                            break
                        }
                    }
                    
                    self.arrayOfEvents = arrayOfNewEvents
                    dispatch_async(dispatch_get_main_queue(), {
                        self.collectionView?.moveItemAtIndexPath(indexPathOld, toIndexPath: indexPathNew)
                        self.collectionView?.reloadItemsAtIndexPaths([indexPathNew])
                    })
                }
                
            }else{
                
                fallthrough
            }
            
            
        default:
            
            // #### Wholesale array replacement ####
            
            self.arrayOfEvents = []
            
            do {
                let arrayResult = try myContext?.executeFetchRequest(request)
                
                for object in arrayResult!{
                    if object.title != nil{
                        let newObject = object as! Program
                        self.arrayOfEvents.append(ProgramModel.init(title: object.title!!, ckRecordName: newObject.ckRecordName!, image440: newObject.image440Name))
                    }
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.collectionView?.reloadData()
                })
                
            }catch let error as NSError{
                print("Failed to execute CoreData fetch: \(error)")
            }
        }
    }

    internal func deleteFromCollectionView(arrayOfChanged:[CKRecordID]?) -> Void {
        
        // Get an updated array of Programs objects
        
        let request = NSFetchRequest.init(entityName: "Program")
        request.predicate = NSPredicate.init(format: "hideFromPublic == nil OR hideFromPublic == 0", argumentArray: nil)
        request.sortDescriptors = [NSSortDescriptor.init(key: "title", ascending: true)]
        
        var arrayOfNewEvents = [ProgramModel]()
        
        //execute the fetch and add to a new array
        do {
            let arrayResult = try myContext?.executeFetchRequest(request)
            
            for object in arrayResult!{
                let newObject = object as! Program
                arrayOfNewEvents.append(ProgramModel.init(title: object.title!!, ckRecordName: newObject.ckRecordName!, image440: newObject.image440Name))
            }
            
        }catch let error as NSError{
            print("Failed to execute CoreData fetch: \(error)")
        }
        
        if arrayOfChanged != nil {
            
            var arrayOfIndexPaths = [NSIndexPath]()
            
            for recordID in arrayOfChanged! {
                
                for i in 0..<self.arrayOfEvents.count {
                    
                    if recordID.recordName == self.arrayOfEvents[i].ckRecordName {
                        arrayOfIndexPaths.append(NSIndexPath.init(forItem: i, inSection: 0))
                        break
                    }
                }
            }
            
            if arrayOfIndexPaths.count > 0 {
                self.arrayOfEvents = arrayOfNewEvents
                dispatch_async(dispatch_get_main_queue(), {
                    self.collectionView!.deleteItemsAtIndexPaths(arrayOfIndexPaths)
                })
                
            }
            
        }else{
            
            // #### Wholesale array replacement ####
            
            self.arrayOfEvents = arrayOfNewEvents
            dispatch_async(dispatch_get_main_queue(), {
                self.collectionView?.reloadData()
            })
        }
    }
    
    
    // MARK: - Responding to orientation changes
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        // Force a layout refresh
        self.collectionView?.collectionViewLayout.invalidateLayout()
        
        let widthValue = size.width
        if widthValue < 400 {
            print("Rotated to portrait")
        }else{
            print("Rotated to landscape")
        }
        
        // OK, sure, this. Un huh
        coordinator.animateAlongsideTransition(nil) { (context) in
            
            if self.collectionView?.numberOfSections() > 0 {
                if self.collectionView?.numberOfItemsInSection(0) > 0{
                    
                    // Scroll to top
                    self.collectionView!.scrollToItemAtIndexPath(NSIndexPath.init(forRow: 0, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Top, animated: false)
                    
                    // Force loading the cells in view
                    // What the hell!!!!
                    self.collectionView!.reloadData()
                }
            }
        }
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
//    override func viewWillLayoutSubviews() {
//        
//    }
//    
//    override func viewDidLayoutSubviews() {
//
//    }
    
    
    // MARK: - Flow Layout Delegate methods
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
        
        if self.collectionView!.frame.size.width < 400 {
            return CGSize.init(width: self.collectionView!.frame.size.width, height: 65.0)
        }else{
            let widthFraction = self.collectionView!.frame.size.width / 5.0
            return CGSize.init(width: widthFraction, height: widthFraction)
        }
        
    }
    

    // MARK: - UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return arrayOfEvents.count        
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ProgramCVCell
        cell.contentView.clipsToBounds = true
        
        let modelObject = self.arrayOfEvents[indexPath.row]
        cell.assignValues(modelObject.title, image440: modelObject.image440)
        
        // If modelObject has a value for image440Name, go get the image
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            
            modelObject.retrieveImage440(modelObject.image440) { (image) in
                
                // !!!!____ Do something with the returned UIImage ____!!!!
            }
        }
        
        
        return cell
    }

    // MARK: - UICollectionViewDelegate

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
