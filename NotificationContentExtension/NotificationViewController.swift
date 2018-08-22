//
//  NotificationViewController.swift
//  NotificationContentExtension
//
//  Created by Rajeev Ranjan on 31/08/17.
//  Copyright © 2017 Shephertz. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI
//import iCarousel

class NotificationViewController: UIViewController, UNNotificationContentExtension, iCarouselDataSource, iCarouselDelegate {

    @IBOutlet weak var carosel: iCarousel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SHNotificationContent.sharedManager.loadViewCarousel(carousel: carosel, viewControllers: self)
    }
    
    func didReceive(_ notification: UNNotification) {
        SHNotificationContent.sharedManager.didReceive(notification)
    }
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        let shNotiContent = SHNotificationContent.sharedManager
        shNotiContent .didReceiveNotificationResponse(response: response) { (option, url) in
            if (url != nil) {
                self.extensionContext?.open(url as URL, completionHandler: nil)
            }
            completion(option)
        }
    }
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return SHNotificationContent.sharedManager.numberOfItems(in: carosel)
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        return SHNotificationContent.sharedManager.carousel(carousel, viewForItemAt: index, reusing: view)
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        return SHNotificationContent.sharedManager.carousel(carousel, valueFor: option, withDefault: value)
    }
    
    

}
