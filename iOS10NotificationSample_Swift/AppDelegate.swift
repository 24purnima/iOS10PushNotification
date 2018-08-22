//
//  AppDelegate.swift
//  iOS10NotificationSample_Swift
//
//  Created by Purnima on 20/01/17.
//  Copyright © 2017 Shephertz. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
//import Shephertz_App42_iOS_API


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {


        App42API.initialize(withAPIKey: Consts.app42ApiKey, andSecretKey: Consts.app42SecretKey)
        App42API.enableApp42Trace(true)
        App42API.enableAppAliveTracking(true)
        App42API.enableEventService(true)
        App42API.enableAppStateEventTracking(true)
        
        App42CacheManager.shared().setPolicy(App42CachePolicy.init(rawValue: 1))
                
        App42API.setBaseUrl("https://in-api.shephertz.com")
        App42API.setEventBaseUrl("https://in-analytics.shephertz.com")
        
        
        DispatchQueue.main.async {
            self.registerPush()
        }
//        registerForRemoteNotification(application: application)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "iOS10NotificationSample_Swift")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    
    
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        print("device token:- \(token)")
        registerUserForPushNotificationToApp42Cloud(deviceToken: token);
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("error: \(error)")
        
    }
    
    // MARK: Called when a notification is delivered to a foreground app.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("will present : =\(notification.request.content.userInfo)")
    }
    
    // MARK: receive local notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("user info: \(response.notification.request.content.userInfo)")
        
        print("notification json: \(response.notification)")

        print("APPDELEGATE: didReceiveResponseWithCompletionHandler \(response.notification.request.content.userInfo)")
                
        completionHandler()
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("did receive remote notification \(userInfo)")
    }
    
    
    // MARK: receive remote notification
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        
        print("did receive remote notification completionHandler ",userInfo);
        completionHandler(.newData)
    }
    
    
    private func registerPush() {
        UNUserNotificationCenter.current().delegate = self
        
        // request permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert, .badge]) {
            (granted, error) in
            if (granted) {
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.registerForRemoteNotifications()
                })
            }
        }
    }
    
    
    // MARK: Notification Settings
    func registerForRemoteNotification(application: UIApplication) {
        
        // iOS 10 support
        if #available(iOS 10, *) {
            
            //Request for notification
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            
            
//            application.registerUserNotificationSettings(settings)
            
            center.requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            application.registerForRemoteNotifications()

            //get settings of user notifications
            center.getNotificationSettings { (notificationCenterSettings) in
                print(notificationCenterSettings);
                
            }
            
            print("remote noti: \(application.isRegisteredForRemoteNotifications)")
            //check if user device support context extensions
            print("supportsContentExtensions :\(center.supportsContentExtensions)")
        }
            // iOS 9 support
//        else if #available(iOS 9, *) {
//            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
//            UIApplication.shared.registerForRemoteNotifications()
//        }
//            // iOS 8 support
//        else if #available(iOS 8, *) {
//            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
//            UIApplication.shared.registerForRemoteNotifications()
//        }
//            // iOS 7 support
//        else {  
//            application.registerForRemoteNotifications(matching: [.badge, .sound, .alert])
//        }
        
    }
    
    
    func registerUserForPushNotificationToApp42Cloud(deviceToken : String) {
        
        let pushObj = App42API.buildPushService() as! PushNotificationService
        
        pushObj.registerDeviceToken(deviceToken as String!, withUser: "Purnima", completionBlock: { (true , test, error) in
            
            
            
        })
        
//        print("push not: \(pushNoti)")
    }
    
    
    
}


// {"mutable-content":"1","category":"customContentIdentifier","alert":{"title":"Hello Title","subtitle":"Hello Sub Title","body":"notification body"},"attachment-url":"https://pusher.com/static_logos/320x320.png"}

//{"mutable-content" : "1", "category" : "customContentIdentifier", "alert" : { "title" : "Hello Title", "subtitle" : "Hello Sub Title", "body" : "notification body"}, "attachment-url" : "https://pusher.com/static_logos/320x320.png"}


//{"aps":{
//    
//    "alert":{
//        "title": "This is an iOS 10 Push!",
//        "subtitle": "Notification subtitle is displayed when you 3D touch",
//        "body": "this is the push body displayed when you 3D touch the notification popup"
//    },
//    "mutable-content":1,
//    "content-available" : 1 },
//    "customInfo" : {
//        "title" : "This is our push title in the advanced screen",
//        "imageLink" : "http://cms.geteve.de/assets/looksimages/150922-FischgraetenFake-Cynthia-Nathalie-01-Step-1.jpg",
//        "intro" : "Haare gut durchkämen. Dann einen seitlichen Zopf binden und am oberen Ende eine Lücke bilden",
//        "contentSlug" : "perfekte-rote-lippen",
//        "video" : "http://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_1mb.mp4"
//    }
//}


//

extension Data {
    func hexString() -> String {
        return self.reduce("") { string, byte in
            string + String(format: "%02X", byte)
        }
    }
}



//{"alert":{"body":"Het gaat over 15 minuten regenen in Alkmaar","title":"Buienalert"},"mutable-content":1},"attachment-url":"https://api.buienradar.nl/Image/1.0/RadarMapNL"}
