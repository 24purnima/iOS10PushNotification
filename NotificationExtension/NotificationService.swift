//
//  NotificationService.swift
//  NotificationExtension
//
//  Created by Purnima on 20/01/17.
//  Copyright © 2017 Shephertz. All rights reserved.
//

import UserNotifications
import UIKit

let richPushKey : String = "_app42RichPush"
let richPushContent : String = "content"
let richPushType : String = "type"


class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        if let bestAttemptContent = bestAttemptContent {
            var userInfo : NSDictionary? = bestAttemptContent.userInfo as NSDictionary
            print(userInfo ?? "error")
            let richPushStr = userInfo?[richPushKey] as! String
            userInfo = self.getJSonFromString(str: richPushStr)
        
            if userInfo == nil {
                self.contentHandler!(self.bestAttemptContent!)
                return
            }
            
            print("push notification userInfo: \(String(describing: userInfo))")
            
            let mediaUrl : String? = userInfo?[richPushContent] as? String
            let mediaType : String? = userInfo?[richPushType] as? String
            
            if mediaUrl == nil || mediaType == nil {
                self.contentHandler!(self.bestAttemptContent!)
                return
            }
            
            //load the atttachment
            loadAttachmentForUrlString(urlString: mediaUrl!, withType: mediaType!, completionHandler: { (attachment) in
                if (attachment != nil) {
                    self.bestAttemptContent?.attachments = [attachment!]
                }
                self.contentHandler!(self.bestAttemptContent!)
            })
        }
        
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    func loadAttachmentForUrlString(urlString : String, withType type : String, completionHandler: @escaping ((UNNotificationAttachment?) -> Void) ) {
        let attachmentUrl = URL(string: urlString)
        let fileExt = fileExtensionForMediaType(type: type)
        
        let config = URLSessionConfiguration.default
        let session = URLSession.init(configuration: config)
        session.downloadTask(with: attachmentUrl!) { (temporaryFileLocation, response, error) in
            
            if error != nil {
                print(error?.localizedDescription ?? "download error")
            }
            else {
                let fileManager = FileManager.default
                let localUrl = URL(fileURLWithPath: (temporaryFileLocation?.path.appending(fileExt))!)
                try! fileManager.moveItem(at: temporaryFileLocation!, to: localUrl)
                
                if let attachment = try? UNNotificationAttachment(identifier: "", url: localUrl, options: nil) {
                    completionHandler(attachment)
                }
            }
        }.resume()
    }
    
    func fileExtensionForMediaType(type : String) -> String {
        var ext = type
        if type == "image" {
            ext = "jpg"
        }
        
        if type == "gif" {
            ext = "gif"
        }
        
        if type == "video" {
            ext = "mp4"
        }
        
        if type == "audio" {
            ext = "mp3"
        }
        
        return ".".appending(ext)
    }
    
    func getJSonFromString(str : String) -> NSDictionary {
        let data = str.data(using: .utf8)
        var jsonDict : Any?
        
        if data != nil {
            do {
                jsonDict = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                
            }
            catch {
                print("JSON serialization failed")
            }
        }
        else {
            print("no data found")
        }
        
        return jsonDict as! NSDictionary
    }
    
    
}
