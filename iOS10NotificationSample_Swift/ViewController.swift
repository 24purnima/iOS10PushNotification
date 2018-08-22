//
//  ViewController.swift
//  iOS10NotificationSample_Swift
//
//  Created by Purnima on 20/01/17.
//  Copyright © 2017 Shephertz. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func notiButtonClick(_ sender: Any) {
        
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        appDelegate.reminderNotification()
  
        //reminderNotification()
        testing()
    }
    
    
    func testing() {
        
//        collection name: [settings, statistic, vocabulary, word]
        
        
        let dbName = "ROXYPENGUIN"
        let collectionName = "word"
        let max:Int32 = 1000
        let offset:Int32 = 0
        let key1 = "originValue"
        let value1 = "шл" //equal
        
        let key2 = "nativeLanguage"
        let value2 = "uk"
        
        let key3 = "translatedLanguage"
        let value3 = "en"
        
        
        let key4 = "ownerId"
        let value4 = "kirill.ge@gmail.com"
        
        let storageService : StorageService = App42API.buildStorageService() as! StorageService
        let query1 = QueryBuilder.buildQuery(withKey: key1, value: value1, andOperator:APP42_OP_EQUALS)
        let query2 = QueryBuilder.buildQuery(withKey: key2, value: value2, andOperator:APP42_OP_EQUALS)
        let query3 = QueryBuilder.buildQuery(withKey: key3, value: value3, andOperator:APP42_OP_EQUALS)
        
        let halfQuery = QueryBuilder.combineQuery(query1, with: query2, usingOperator: APP42_OP_AND)
        let anotherQuery = QueryBuilder.combineQuery(halfQuery, with: query3, usingOperator: APP42_OP_AND)
        
        
        var query4 = QueryBuilder.buildQuery(withKey: key4, value: value4, andOperator:APP42_OP_EQUALS)
        let completeQuery = QueryBuilder.combineQuery(anotherQuery, with: query4, usingOperator: APP42_OP_AND)
        
//        print(halfQuery?.getJsonQuery() ?? "")
//        print(anotherQuery?.getJsonQuery() ?? "")
//        print(completeQuery?.getJsonQuery() ?? "")
        
        /*storageService.findDocsWithQueryPagingOrder(by: dbName, collectionName: collectionName, query: query, max: max, offset: offset, orderByKey:key, orderByType: APP42_ORDER_ASCENDING) { (success, responseObj, exception) in
            if(success)
            {
                let app42Response = responseObj as! App42Response
                NSLog("app42Response is %@", app42Response.strResponse)
                NSLog("totalRecords %d", app42Response.totalRecords)
            }
            else
            {
                NSLog("%@", exception?.reason! ?? "")
                NSLog("%d", exception?.appErrorCode ?? "")
                NSLog("%d", exception?.httpErrorCode ?? "")
                NSLog("%@", exception?.userInfo ?? "")
            }
        }*/
        
 
        
        
        storageService.findDocuments(by: completeQuery, dbName: dbName, collectionName: collectionName) { (success, responseObj, exception) in
            if(success)
            {
                let app42Response = responseObj as! App42Response
                NSLog("app42Response is %@", app42Response.strResponse)
                NSLog("totalRecords %d", app42Response.totalRecords)
            }
            else
            {
                NSLog("%@", exception?.reason ?? "")
                NSLog("%d", exception?.appErrorCode ?? "")
                NSLog("%d", exception?.httpErrorCode ?? "")
                NSLog("%@", exception?.userInfo ?? "")
            }
        }
        
        query4 = nil

        
        /*
        storageService.findAllDocuments(dbName, collectionName: collectionName) { (success, responseObj, exception) in
            if(success)
            {
                let app42Response = responseObj as! App42Response
                NSLog("app42Response is %@", app42Response.strResponse)
                NSLog("totalRecords %d", app42Response.totalRecords)
            }
            else
            {
                NSLog("%@", exception?.reason ?? "")
                NSLog("%d", exception?.appErrorCode ?? "")
                NSLog("%d", exception?.httpErrorCode ?? "")
                NSLog("%@", exception?.userInfo ?? "")
            }
        }*/
        
        
        
        
        storageService.findAllCollections(dbName) { (success, responseObj, exception) in
            if(success)
            {
                let app42Response = responseObj as! App42Response
                NSLog("app42Response is %@", app42Response.strResponse)
                NSLog("totalRecords %d", app42Response.totalRecords)
            }
            else
            {
                NSLog("%@", exception?.reason! ?? "")
                NSLog("%d", exception?.appErrorCode ?? "")
                NSLog("%d", exception?.httpErrorCode ?? "")
                NSLog("%@", exception?.userInfo! ?? "")
            }
        }
        
        
        /*let storageService : StorageService = App42API.buildStorageService() as! StorageService
        storageService.findDocsWithQueryPagingOrder(by: "", collectionName: "", query: "", max: 20, offset: 10, orderByKey: "", orderByType: "") { (success, responseObj, exception) in
            
        }
        
        let collectionName = type.dbCollectionName
        storageService.findDocsWithQueryPagingOrder(by: currentDbName, collectionName: collectionName, query: query,
                                                    max: objectsInPage, offset: offset,
                                                    orderByKey: orderByKey, orderByType: orderType) { (success, response, exception) in
                                                        if success, let storage = response as? Storage {
                                                            var objects:[T] = []
                                                            objects = storage.jsonDocArray.map({$0 as? JSONDocument})
                                                                .flatMap({$0})
                                                                .flatMap({type.makeWith($0)})
                                                                .flatMap({$0})
                                                            completionHandler?(objects, nil)
                                                        } else {
                                                            completionHandler?([], AppError.prepareWith(errorCode:.dataTransferError, exception:exception))
                                                        }
        }*/
    }
    
    
    //create a notification for reminer
    func reminderNotification()
    {
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey:
            "Hello!", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey:
            "hello test message", arguments: nil)
        content.categoryIdentifier = "myCategory"
        
        if let path = Bundle.main.path(forResource: "cartoon_birds_blue_flying_animation_clipart", ofType: "gif") {
            let url = URL(fileURLWithPath: path)
            
            do {
                let attachment = try UNNotificationAttachment(identifier: "logo", url: url, options: nil)
                content.attachments = [attachment]
            } catch {
                print("The attachment was not loaded.")
            }
        }
        //
        
        //        do{
        //            let attachment = try UNNotificationAttachment(identifier: "image", url: URL(string:"http://www.logospike.com/wp-content/uploads/2015/11/Logo_Image_05.jpg")!, options: nil)
        //            content.attachments = [attachment]
        //        }catch{
        //            print("The attachment was not loaded.")
        //        }
        //
        //
        //
        //
        //        let url = "http://www.logospike.com/wp-content/uploads/2015/11/Logo_Image_05.jpg"
        //        if let urlString = url as? String , let fileUrl = URL(string: urlString) {
        //            URLSession.shared.downloadTask(with: fileUrl) { (location, response, error) in
        //                if let location = location {
        //                    let options = [UNNotificationAttachmentOptionsTypeHintKey:kUTTypePNG]
        //                    if let attachment = try? UNNotificationAttachment(identifier: "", url: location, options: options) {
        //                        self.bestAttemptContent.attachments = [attachment]
        //                    }
        //                }
        //
        //                }.resume()
        //        }
        
        
        
        
        // Deliver the notification in five seconds.
        content.sound = UNNotificationSound.default()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5,
                                                        repeats: false)
        
        
        //        let action = UNNotificationAction(identifier: "remindLater", title: "Remind me later", options: [])
        //        let category = UNNotificationCategory(identifier: "myCategory", actions: [action], intentIdentifiers: [], options: [])
        //        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        
        // Schedule the notification.
        let request = UNNotificationRequest(identifier: "FiveSecond", content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: nil)
    }
    

    func revokeAccess() {
        
        let dbName = "<Your_DataBase_Name>"
        let collectionName = "Your_Collection_Name"
        let docId = "docId"
        let acl = ACL.init(userName: "PUBLIC", andPermission: APP42_READ)
        let aclList : NSArray? = NSArray(objects: acl ?? "")
        App42API.initialize(withAPIKey: "APP_KEY", andSecretKey: "SECRET_KEY")
        let storageService : StorageService = App42API.buildStorageService() as! StorageService
        storageService.grantAccess(onDoc: dbName, collectionName: collectionName, docId: docId, andAclList: aclList as! [Any]) { (success, response, exception) in
            if success {
                let storage = response as! Storage
                NSLog("dbName is : %@", storage.dbName)
                NSLog("collectionName is : %@", storage.collectionName)
                let jsonDocList = storage.jsonDocArray
                for jsonDoc in jsonDocList! {
                    print("Docid is : \((jsonDoc as AnyObject).docId)")
                    print("CreatedAt is : \((jsonDoc as AnyObject).createdAt)")
                    print("UpdatedAt is : \((jsonDoc as AnyObject).updatedAt)")
                    print("JsonDoc is : \((jsonDoc as AnyObject).jsonDoc)")
                }
            }
            else {
                NSLog((exception?.reason!)!)
                NSLog("\(exception!.appErrorCode)")
                NSLog("\(exception!.httpErrorCode)")
                NSLog("\(exception!.userInfo!)")
                
            }
        }
        
        
        storageService.revokeAccess(onDoc: dbName, collectionName: collectionName, docId: docId, andAclList: aclList as! [Any]) { (success, response, exception) in
            if success {
                let storage = response as! Storage
                NSLog("dbName is : %@", storage.dbName)
                NSLog("collectionName is : %@", storage.collectionName)
                let jsonDocList = storage.jsonDocArray
                for jsonDoc in jsonDocList! {
                    print("Docid is : \((jsonDoc as AnyObject).docId)")
                    print("CreatedAt is : \((jsonDoc as AnyObject).createdAt)")
                    print("UpdatedAt is : \((jsonDoc as AnyObject).updatedAt)")
                    print("JsonDoc is : \((jsonDoc as AnyObject).jsonDoc)")
                }
            }
            else {
                NSLog((exception?.reason!)!)
                NSLog("\(exception!.appErrorCode)")
                NSLog("\(exception!.httpErrorCode)")
                NSLog("\(exception!.userInfo!)")

            }
        }
        
        
        
        
    }
    
    func grantAccess() {
        
    }
}


//{"aps":{"alert": {"title": "Pusher's Native Push Notifications API","subtitle": "Bringing you iOS 10 support!","body": "Now add more content to your Push Notifications!"},"mutable-content": 1,"category": "pusher"},"data":{"attachment-url": "https://pusher.com/static_logos/320x320.png"}}}

