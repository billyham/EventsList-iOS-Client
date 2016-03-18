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
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

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
            //            print("count of array from coredata \(arrayResult!.count) \(arrayResult!)")
            
            for object in arrayResult!{
                let newObject = object as! Program
                arrayOfNewEvents.append(ProgramModel.init(title: object.title!!, ckRecordName: newObject.ckRecordName!))
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
                    self.collectionView!.insertItemsAtIndexPaths(arrayOfIndexPaths)
                }
            
                
            }else{
                
                fallthrough
            }
            
        default:
            
            // #### Wholesale array replacement ####
            
            self.arrayOfEvents = []
            
            //execute the fetch and add to array
            do {
                let arrayResult = try myContext?.executeFetchRequest(request)
                
                for object in arrayResult!{
                    print("Adding item in loop")
                    if object.title != nil{
                        let newObject = object as! Program
                        self.arrayOfEvents.append(ProgramModel.init(title: object.title!!, ckRecordName: newObject.ckRecordName!))
                    }
                }
                
                self.collectionView?.reloadData()
                
                //            arrayOfEvents.appendContentsOf(arrayResult as! Array)
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
            //            print("count of array from coredata \(arrayResult!.count) \(arrayResult!)")
            
            for object in arrayResult!{
                let newObject = object as! Program
                arrayOfNewEvents.append(ProgramModel.init(title: object.title!!, ckRecordName: newObject.ckRecordName!))
            }
            
        }catch let error as NSError{
            print("Failed to execute CoreData fetch: \(error)")
        }
        
        if arrayOfChanged != nil {
            
            var arrayOfIndexPaths = [NSIndexPath]()
            
            for recordID in arrayOfChanged! {
                
                for i in 0..<self.arrayOfEvents.count {
                    
                    if recordID.recordName == self.arrayOfEvents[i].ckRecordName {
                        print("Found a matching record name to delete")
                        arrayOfIndexPaths.append(NSIndexPath.init(forItem: i, inSection: 0))
                        break
                    }
                    
                }
            }
            
            if arrayOfIndexPaths.count > 0 {
                self.arrayOfEvents = arrayOfNewEvents
                self.collectionView!.deleteItemsAtIndexPaths(arrayOfIndexPaths)
            }
            
        }else{
            
            // #### Wholesale array replacement ####
            
            self.arrayOfEvents = arrayOfNewEvents
            self.collectionView?.reloadData()
        }
    }
    

    // MARK: - UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        print("numberOfItemsInSection fires with count: \(self.arrayOfEvents.count)")

        return arrayOfEvents.count        
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
    
        // Configure the cell
        for view in cell.contentView.subviews{
            view.removeFromSuperview()
        }
        
        let modelObject = self.arrayOfEvents[indexPath.row]
        let newLabel = UILabel(frame: CGRectMake(0, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.height))
        newLabel.text = modelObject.title
        cell.contentView.addSubview(newLabel)
            
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
