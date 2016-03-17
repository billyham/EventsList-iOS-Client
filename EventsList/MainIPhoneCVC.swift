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


private let reuseIdentifier = "Cell"
private var arrayOfEvents = [ProgramModel]()


class MainIPhoneCVC: UICollectionViewController {
    
    internal var myContext: NSManagedObjectContext?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        
        // Get data from coredata
        
        let request = NSFetchRequest.init(entityName: "Program")
        request.predicate = NSPredicate.init(format: "hideFromPublic == nil OR hideFromPublic == 0", argumentArray: nil)
        
        //execute the fetch and add to array
        do {
            let arrayResult = try myContext?.executeFetchRequest(request)
//            print("count of array from coredata \(arrayResult!.count) \(arrayResult!)")
            
            print("Executing coreData query in CVC")
            
            for object in arrayResult!{
                print("Adding item in loop")
                if object.title != nil{
                    arrayOfEvents.append(ProgramModel.init(title: object.title!!))
                }
            }
            
            self.collectionView?.reloadData()
            
//            arrayOfEvents.appendContentsOf(arrayResult as! Array)
        }catch let error as NSError{
            print("Failed to execute CoreData fetch: \(error)")
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfEvents.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
    
        // Configure the cell
        for view in cell.contentView.subviews{
            view.removeFromSuperview()
        }
        
        let modelObject = arrayOfEvents[indexPath.row]
        let newLabel = UILabel(frame: CGRectMake(0, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.height))
        newLabel.text = modelObject.title
        cell.contentView.addSubview(newLabel)
            
        return cell
    }

    // MARK: UICollectionViewDelegate

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

}
