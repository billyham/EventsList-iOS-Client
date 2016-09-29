//
//  AppDelegate.swift
//  EventsList
//
//  Created by Ray Smith on 3/1/16.
//  Copyright © 2016 Hamagain LLC. All rights reserved.
//

import UIKit
import CoreData
import CloudKit



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var myContext: NSManagedObjectContext?
    var myNetworkController: NetworkController?

    func testZone(_ zoneString: String, completion:@escaping (_ result: Bool) -> Void) {
        
        let container = CKContainer.init(identifier: "iCloud.David-Vincent-Hanagan.EventsList")
        let database = container.privateCloudDatabase
        
        let recordZoneID = CKRecordZoneID.init(zoneName: "Standard", ownerName: CKOwnerDefaultName)
        
        database.fetch(withRecordZoneID: recordZoneID) { (recordZone, error) -> Void in
            
            if ((error) != nil){
                let recordZone = CKRecordZone.init(zoneName: "Standard")
                let array = [recordZone]
                let operation = CKModifyRecordZonesOperation.init(recordZonesToSave: array, recordZoneIDsToDelete: nil)
                operation.modifyRecordZonesCompletionBlock = {(saved, _, error) in
                    if ((error) != nil){
                        print("failed to create Standard zone")
                        completion(false)
                    }else{
                        completion(true)
                    }
                }
                database.add(operation)
                
            }else{
                completion(true)
            }
        }
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // #### Save Initial user defaults ####
        
        let sampleDefault = ["key": "someValue"]
        let changeToken = ["PreviousChangeToken": "fakeData"]
        
        let appDefaults = ["firstDictionary": sampleDefault, "SubscriptionKeys": changeToken]
        
        let standardDefaults = UserDefaults.standard
        standardDefaults.register(defaults: appDefaults)

        
        // #### Initiate CloudKit subscription ####

        // Test if subscription already exists
        let publicDatabase = CKContainer.default().publicCloudDatabase
        
        // Get the unique subscriptionID from userDefaults
        let secretObject: NSDictionary = UserDefaults.standard.object(forKey: "firstDictionary") as! NSDictionary
        let secretValue: String = secretObject.object(forKey: "key") as! String
        
//        print("Here is the subscriptionID from userDefaults: \(secretValue)")

        // Fetch the unique CKSubscription by name
        publicDatabase.fetch(withSubscriptionID: secretValue) { (subscription, error) -> Void in
            
            if (error) != nil{
                print("error trying to retrieve subscriptions \(error)")
                
                // #### After failing to retrieve the specified subscription, it should delete any existing subscriptions... ####
                
                // Try looking at all subscriptions
                publicDatabase.fetchAllSubscriptions(completionHandler: { (subscriptionArray, error) -> Void in
                    if subscriptionArray != nil{
                        
                        var countOfSubs = subscriptionArray!.count
                        print("count of subscriptions: \(subscriptionArray!.count)")
                        
                        if countOfSubs > 0 {
                            
                            for subscriptionItem in subscriptionArray! {
                                publicDatabase.delete(withSubscriptionID: subscriptionItem.subscriptionID, completionHandler: {(subscriptionID, error) -> Void in
                                    
                                    if error != nil{
                                        print("Error attempting to delete subscriptionID: \(error))")
                                    }
                                    
                                    countOfSubs -= countOfSubs
                                    if countOfSubs < 1 {
                                        self.createSubscription(application, publicDatabase: publicDatabase)
                                    }
                                    
                                })
                            }
                        }else{
                            
                            self.createSubscription(application, publicDatabase: publicDatabase)
                        }
                    }else{
                        
                        self.createSubscription(application, publicDatabase: publicDatabase)
                    }
                })
            }else{
                
                // The correct subscription exists, query for changes
                
                // #### Fetch Changed Records from CloudKit ####
                self.queryForRecordIDs({ success in
                    
                })
            }
        }
        
        // #### Pass the CoreData context to the main view controller ####
        let navigationController = self.window!.rootViewController as! UINavigationController
        let controller = navigationController.topViewController as! MainIPhoneCVC
        controller.myContext = self.managedObjectContext;
        self.myContext = controller.myContext
        
        // #### Pass the NetworkController to the main view controller ####
        self.myNetworkController = NetworkController.init(context: self.myContext)
        controller.myNetworkController = self.myNetworkController
        
        return true
    }
    
    
    func createSubscription(_ application: UIApplication, publicDatabase: CKDatabase) {
        
        // Get all existing data in Programs (because a new subscription will pass over this data)
        let predicateTest = NSPredicate.init(format: "TRUEPREDICATE", argumentArray: nil)
        let query = CKQuery.init(recordType: "Program", predicate: predicateTest)
        publicDatabase.perform(query, inZoneWith: nil) { (arrayOfRecords, error) -> Void in
            if error != nil {
                print("Error trying to download all existing Programs before assigning the subscription")
            }else{
                if arrayOfRecords != nil {
                    
                    self.addPrograms(arrayOfRecords!)
                    
                }else{
                    print("Array of Program data in nil")
                }
            }
        }
        
        
        // #### Create subscription ####
        
        // A unique subscription ID
        
        //__1__
//        let tempUUID = NSUUID.init().UUIDString
//        let stringIndex = tempUUID.startIndex.advancedBy(8)
//        let shortUUID = tempUUID.substringToIndex(stringIndex)
        
        //__2__
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            
            if error != nil{
               print("error trying to access user recordID \(error?.localizedDescription)")
                
            }else{
                
                let tempUUID = recordID!.recordName
                let stringIndex = tempUUID.characters.index(tempUUID.startIndex, offsetBy: 1)
                let shortUUID = tempUUID.substring(from: stringIndex)
                print("this is the user record name: \(shortUUID)")

                
                // Register app for remote notifications
                let notificationSettings = UIUserNotificationSettings.init(types: UIUserNotificationType.alert, categories: nil)
                application.registerUserNotificationSettings(notificationSettings)
                application.registerForRemoteNotifications()
                
                // Create subscription
                let options = CKSubscriptionOptions.firesOnRecordCreation.union(
                    CKSubscriptionOptions.firesOnRecordDeletion).union(CKSubscriptionOptions.firesOnRecordUpdate)
                
                let predicate = NSPredicate.init(format: "TRUEPREDICATE", argumentArray: nil)
                let subscription = CKSubscription.init(recordType:"Program", predicate: predicate, subscriptionID:shortUUID , options: options)
                
                // Notification on the subscription
                let notificationInfo = CKNotificationInfo.init()
                notificationInfo.shouldBadge = true
                notificationInfo.alertLocalizationKey = "Change to EventsList"
                notificationInfo.shouldSendContentAvailable = true
                subscription.notificationInfo = notificationInfo
                
                // Attempt to save the subscription
                publicDatabase.save(subscription, completionHandler: { (subscriptionResult, error) -> Void in
                    
                    if (error) != nil{
                        print("error at saving subscription: \(error)")
                    }else{
                        UserDefaults.standard.set(["key": shortUUID], forKey: "firstDictionary")
                        
                        // #### Fetch Changed Records from CloudKit ####
                        self.queryForRecordIDs({ success in
                            
                        })
                    }
                }) 
                
            }
            
        }
        
        
 

    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        self.queryForRecordIDs({ success in
            
        })
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Load CoreData with CloudKit data
    
    func addPrograms(_ arrayOfCKRecords: [CKRecord]) {
        
        var context: NSManagedObjectContext
        if self.myContext != nil{
            context = self.myContext!
        }else{
            context = self.managedObjectContext
        }
        
        // Get existing CoreData records to ensure a duplicate entry is not added. 
        var arrayOfExistingProgramModels = [String]()
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Program")
        request.predicate = NSPredicate.init(format: "TRUEPREDICATE", argumentArray: nil)
        
        //execute the fetch and add to a new array
        do {
            let arrayResult = try context.fetch(request)
            for doodad in arrayResult{
                let programThing = doodad as! Program
                arrayOfExistingProgramModels.append(programThing.ckRecordName!)
            }
            
        }catch{
            print("AppDelegate > addPrograms failed to execcute fetch on coredata")
        }
        
        var arrayOfFilteredCKRecords = [CKRecord]()
        
        for record in arrayOfCKRecords {
            
            if let _ = arrayOfExistingProgramModels.index(of: record.recordID.recordName) {
                continue
            }else{
                arrayOfFilteredCKRecords.append(record)
            }
            
            let programAddition = NSEntityDescription.insertNewObject(forEntityName: "Program", into: context) as! Program
            
            self.mutateProgramWithCKRecord(programAddition, record: record, context: context)
            
            programAddition.hideFromPublic = 0
        }
        
        if context.hasChanges {
            do {
                try context.save()
                
                // Refresh the collectionView
                let navigationController = self.window!.rootViewController as! UINavigationController
                let controller = navigationController.topViewController as! MainIPhoneCVC
                controller.updateCollectionView(type: "Add", arrayOfChanged: arrayOfFilteredCKRecords)
                
            }catch{
                fatalError("Failure to save context: \(error)")
            }
        }else{
            print("context says it has no changes to save")
        }
        
    }
    

    
    func deletePrograms(_ arrayOfRecordIDs: [CKRecordID]?) {
        
        var context: NSManagedObjectContext
        if self.myContext != nil{
            context = self.myContext!
        }else{
            context = self.managedObjectContext
        }
        
        var arrayOfFinalRecordsIDs = [CKRecordID]()
        
        if arrayOfRecordIDs != nil{
            for recordID in arrayOfRecordIDs! {
                
                let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Program")
                request.predicate = NSPredicate.init(format: "ckRecordName == %@", argumentArray: [recordID.recordName])
                
                //execute the fetch and add to a new array
                do {
                    let arrayResult = try context.fetch(request)
                    if arrayResult.count > 0{
                        context.delete(arrayResult[0] as! NSManagedObject)
                        arrayOfFinalRecordsIDs.append(recordID)
                    }
                }catch{
                    print("Error trying to retrieve object to be deleted")
                }
            }
            
            do {
                try context.save()
                
                // Refresh the collectionView
                let navigationController = self.window!.rootViewController as! UINavigationController
                let controller = navigationController.topViewController as! MainIPhoneCVC
                controller.deleteFromCollectionView(arrayOfFinalRecordsIDs)
 
            }catch{
                fatalError("Failure to save context on deletions: \(error)")
            }
        }
    }
    
    func updatePrograms(_ arrayOfCKRecords: [CKRecord]) {
        
        var context: NSManagedObjectContext
        if self.myContext != nil{
            context = self.myContext!
        }else{
            context = self.managedObjectContext
        }
        
        // Get matching coredata records to update
        var arrayOfExistingPrograms = [Program]()
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Program")
        request.predicate = NSPredicate.init(format: "TRUEPREDICATE", argumentArray: nil)
        
        //execute the fetch
        do {
            arrayOfExistingPrograms = try context.fetch(request) as! [Program]
        }catch{
            print("Failed coredata fetch")
            return
        }
        
        // Filter the fetch result array to just the items
        let filteredArrayResult = arrayOfExistingPrograms.filter({ (programItem) -> Bool in
            var boolValue = false
            for ckItem in arrayOfCKRecords {
                if ckItem.recordID.recordName == programItem.ckRecordName{
                    boolValue = true
                    break
                }
            }
            return boolValue
        })
        
        // TODO: Change Map to Loop?
        _ = filteredArrayResult.map { (programItem) -> Program in
            for ckItem in arrayOfCKRecords {
                if ckItem.recordID.recordName == programItem.ckRecordName{
                    
                    // Update the record
                    self.mutateProgramWithCKRecord(programItem, record: ckItem, context: context)
                    
                    break
                }
            }
            return programItem
        }
        
        if context.hasChanges {
            do {
                try context.save()
                                
                let navigationController = self.window!.rootViewController as! UINavigationController
                let controller = navigationController.topViewController as! MainIPhoneCVC
                controller.updateCollectionView(type: "Update", arrayOfChanged: arrayOfCKRecords)
                
            }catch{
                fatalError("Failure to save context: \(error)")
            }
        }
    }
    
    func mutateProgramWithCKRecord(_ programAddition: Program, record: CKRecord, context: NSManagedObjectContext) -> Void {
        
        programAddition.title = record.object(forKey: "title") as? String
        programAddition.ckRecordName = record.recordID.recordName
        programAddition.image440Name = record.object(forKey: "imageRef") as? String
        programAddition.video = record.object(forKey: "video") as? String
        
        if let tempRecord: CKReference = record.object(forKey: "imageRef") as? CKReference{
            programAddition.image440Name = tempRecord.recordID.recordName
        }
        
        // Save CKRecord System properties to managed object
        let archivedData = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: archivedData)
        archiver.requiresSecureCoding = true
        record.encodeSystemFields(with: archiver)
        archiver.finishEncoding()
        programAddition.ckRecord = archivedData as Data
    }
    

    // MARK: - Handle Remote Notifications
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let newThing  = userInfo as? [String:NSObject]
        
        let cloudKitNotification = CKNotification.init(fromRemoteNotificationDictionary: newThing!)
        print("received notification \(cloudKitNotification)")
        
        self.queryForRecordIDs { (success) -> Void in
            
            if (success){
                completionHandler(UIBackgroundFetchResult.newData)
            }else{
                completionHandler(UIBackgroundFetchResult.failed)
            }
        }
    }
    
    // MARK: - Use CloudKit to retrieve CloudKit recordIDs and then records
    
    func queryForRecordIDs(_ completionHandler:@escaping (_ success: Bool) -> Void) -> Void {
        
        let serverChangeToken: CKServerChangeToken? = previousChangeToken
        let notificationChangesOperation = CKFetchNotificationChangesOperation(previousServerChangeToken: serverChangeToken)
        
        var newRecordIDs = [CKRecordID]()
        var deleteRecordIDs = [CKRecordID]()
        var updateRecordIDs = [CKRecordID]()
        
        notificationChangesOperation.notificationChangedBlock = {notification in
            
            let queryNote = notification as! CKQueryNotification
            
            // #### Determine reason for change and act accordingly ####
            
            if queryNote.queryNotificationReason == CKQueryNotificationReason.recordCreated{
                if (!newRecordIDs.contains(queryNote.recordID!)) {
                    newRecordIDs.append(queryNote.recordID!)
                }
            }else if queryNote.queryNotificationReason == CKQueryNotificationReason.recordDeleted{
                if (!deleteRecordIDs.contains(queryNote.recordID!)) {
                    deleteRecordIDs.append(queryNote.recordID!)
                }
            }else if queryNote.queryNotificationReason == CKQueryNotificationReason.recordUpdated{
                if (!updateRecordIDs.contains(queryNote.recordID!)) {
                    updateRecordIDs.append(queryNote.recordID!)
                }
            }
        }
        
        notificationChangesOperation.fetchNotificationChangesCompletionBlock = {serverChangeToken, error in

            if ((error) != nil) {
                print("failed to fetch notification with \(error)")
                completionHandler(false)
                return
            }
            
            // Exit if the tokens are identitcal 
            if self.previousChangeToken == serverChangeToken {
                print("Exit from fetchNotificationChangesCompletionBlock because token hasn't changed")
                completionHandler(true)
                return
            }
            
            self.previousChangeToken = serverChangeToken
            
            // #### 1. ADD new records ####
            if (newRecordIDs.count > 0) {
                self.queryMessagesWithIDs(newRecordIDs, completionHandler: { (messages, error) -> Void in
                    
                    if ((error) != nil){
                        print("Error in queryMessagesWithIDs: \(error)")
                        completionHandler(false)
                        return
                    }
                    
                    // Save CKRecords to CoreData
                    self.addPrograms(messages!)
                    completionHandler(true)
                })
            }
            
            // #### 2. DELETE records ####
            if deleteRecordIDs.count > 0 {
                self.deletePrograms(deleteRecordIDs)
                completionHandler(true)
            }
            
            // #### 3. UPDATE existing records ####
            if (updateRecordIDs.count > 0) {
                self.queryMessagesWithIDs(updateRecordIDs, completionHandler: { (messages, error) -> Void in
                    
                    if ((error) != nil){
                        print("Error in queryMessagesWithIDs: \(error)")
                        completionHandler(false)
                        return
                    }
                    
                    self.updatePrograms(messages!)
                    completionHandler(true)
                })
            }
            
        }
        
        CKContainer.default().add(notificationChangesOperation)
    }
    
    
    func queryMessagesWithIDs(_ IDs:[CKRecordID], completionHandler: @escaping ([CKRecord]?, NSError?) -> Void) -> Void {
        
        let fetchRecordsOperation = CKFetchRecordsOperation(recordIDs: IDs)
        
        var newMessages = [CKRecord]()
        
        fetchRecordsOperation.perRecordCompletionBlock = {record, recordID, error in
            if ((error == nil)){
                newMessages.append(record!)
            }else{
                print("failed to get message with ID \(recordID)")
            }
        }
        
        fetchRecordsOperation.fetchRecordsCompletionBlock = {_, error in
            if ((error) != nil){
                print("completion block error: \(error)")
            }else{
                newMessages.sort{$0.creationDate!.compare($1.creationDate!) == ComparisonResult.orderedAscending}
            }
            
            DispatchQueue.main.async(execute: {completionHandler(newMessages, error as NSError!)})
        }
        
        let publicDatabase = CKContainer.default().publicCloudDatabase
        publicDatabase.add(fetchRecordsOperation)
        
    }
    
    
    // MARK: - Access User Defaults
    
    // This is a computed property
    var previousChangeToken:CKServerChangeToken? {
        get {
            // let subscriptionKeys = (UserDefaults.standard.object(forKey: "SubscriptionKeys"));
            // let objData = subscriptionKeys.object(forKey: "PreviousChangeToken");
            //let encodedObjectData = (UserDefaults.standard.object(forKey: "SubscriptionKeys")? as AnyObject).object(forKey: "PreviousChangeToken") as? Data
            let encodedObjectData = (UserDefaults.standard.object(forKey: "SubscriptionKeys") as! NSDictionary).object(forKey: "PreviousChangeToken") as? Data
            
            if ((encodedObjectData) != nil) {
                return NSKeyedUnarchiver.unarchiveObject(with: encodedObjectData!) as? CKServerChangeToken
            }
            
            return nil
        }
        set(newToken) {
            if ((newToken) != nil) {
                print("set new token as \(newToken)")
                
                UserDefaults.standard.set(["PreviousChangeToken": NSKeyedArchiver.archivedData(withRootObject: newToken!)], forKey: "SubscriptionKeys")
            }
        }
    }
    
    
    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "David-Vincent-Hanagan.EventsList" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "EventsList", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

