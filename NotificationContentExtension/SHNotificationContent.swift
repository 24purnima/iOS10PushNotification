//
//  SHNotificationContent.swift
//  NotificationContentExtension
//
//  Created by Purnima Singh on 16/01/18.
//  Copyright © 2018 Shephertz. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class SHNotificationContent: NSObject, iCarouselDelegate, iCarouselDataSource, UNNotificationContentExtension {
    
    static let sharedManager = SHNotificationContent()
    var carouselView = iCarousel()
    var orientationStr = ""
    var caroselItemsArray = NSMutableArray()
    var timer : Timer? = Timer()
    var viewController = UIViewController()
    
    let kApp42RichPushKey = "_app42RichPush"
    let kSliderArrayKey = "sliderArr"
    let kSliderTypeKey = "sliderType"
    let kSliderTypeCoverflowKey = "carousalImage"
    let kSliderTypeLinearKey = "sliderImage"
    let kOrientationKey = "orientation"
    let kOrientationLandscapeKey = "landscape"
    let kOrientationPotraitKey = "potrait"
//    let kItemsKey = "items"
    let kAutoPlayKey = "autoPlay"
    let kImageUrlKey = "imageUrl"
    let kCaptionKey = "title"
    let kSubCaptionKey = "description"
    let kActionUrlKey = "actionUrl"
    let kAutoPlayInterval = 3.0
    
    func loadViewCarousel(carousel : iCarousel, viewControllers : UIViewController) {
        carouselView = carousel
        carouselView.backgroundColor = UIColor.clear
        
        viewController = viewControllers
    }
    
    
    func didReceive(_ notification: UNNotification) {
        let dict = notification.request.content.userInfo
        let richPushStr = dict[kApp42RichPushKey]
        let contentDict = getJSonFromString(str: richPushStr as! String)
        let sliderType = contentDict[kSliderTypeKey] as! String
        
        if sliderType == kSliderTypeCoverflowKey {
            carouselView.type = .coverFlow2
        }
        else {
            carouselView.type = .linear
        }
        
        orientationStr = contentDict[kOrientationKey] as! String
        if orientationStr == kOrientationLandscapeKey {
            viewController.preferredContentSize = CGSize(width: 0, height: 200)
        }
        else {
            viewController.preferredContentSize = CGSize(width: 0, height: 345)
        }

        caroselItemsArray = NSMutableArray.init(array: contentDict[kSliderArrayKey] as! Array)
        carouselView.reloadData()
        
        let autoPlays = contentDict[kAutoPlayKey] as! Bool
        if autoPlays {
            startAutoPlay()
        }
        else {
            stopAutoPlay()
        }
    }

    func didReceiveNotificationResponse(response : UNNotificationResponse, completionHandler completion : (_ response : UNNotificationContentExtensionResponseOption, _ url : URL) -> Void ) {
        let actionurl = (caroselItemsArray.object(at: carouselView.currentItemIndex) as AnyObject).value(forKey: kActionUrlKey) as! URL
        completion(.doNotDismiss, actionurl)
    }
    

    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return caroselItemsArray.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        var imgView = UIImageView()
        var caption = UILabel()
        var subCaption = UILabel()
        
        if view == nil {
            if orientationStr == kOrientationLandscapeKey {
                view?.frame = CGRect(x: 10, y: 0, width: carouselView.frame.size.width - 80, height: 190)
            }
            else {
                view?.frame = CGRect(x: 10, y: 0, width: carouselView.frame.size.width - 80, height: 335)
            }
            view?.backgroundColor = UIColor.clear
            
            imgView = UIImageView.init(frame: CGRect(x: 5, y: 5, width: (view?.frame.size.width)! - 10, height: 60))
            imgView.contentMode = .scaleAspectFill
            imgView.clipsToBounds = true
            imgView.backgroundColor = UIColor.white
            downloadImageFromUrl(imageUrl: (caroselItemsArray.object(at: index) as AnyObject).value(forKey: kImageUrlKey) as! String, imageView: imgView)
            
            caption = UILabel.init(frame: CGRect(x: 5, y: imgView.frame.origin.y + imgView.frame.size.height, width: imgView.frame.size.width, height: 30))
            caption.text = (caroselItemsArray.object(at: index) as AnyObject).value(forKey: kCaptionKey) as? String
            caption.font = UIFont.systemFont(ofSize: 18)
            caption.textAlignment = .center
            caption.backgroundColor = UIColor.white
            
            subCaption = UILabel.init(frame: CGRect(x: 5, y: caption.frame.origin.y + caption.frame.size.height, width: imgView.frame.size.width, height: 20))
            subCaption.text = (caroselItemsArray.object(at: index) as AnyObject).value(forKey: kSubCaptionKey) as? String
            subCaption.font = UIFont.systemFont(ofSize: 12)
            subCaption.textAlignment = .center
            subCaption.backgroundColor = UIColor.white
            
            view?.addSubview(imgView)
            view?.addSubview(caption)
            view?.addSubview(subCaption)
        }
        return view!
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        switch option {
        case .wrap:
            return 1
        default:
            return value
        }
    }
    
    
    
    func getJSonFromString(str : String) -> NSDictionary{
        let strData = str.data(using: .utf8)
        var json = NSDictionary()
        if let jsonDict = try? JSONSerialization.jsonObject(with: strData!, options: JSONSerialization.ReadingOptions.allowFragments) {
            json = jsonDict as! NSDictionary
            return json
        }
        return json
    }
    
    func startAutoPlay() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: kAutoPlayInterval, target: self, selector:#selector(SHNotificationContent.showNext), userInfo: nil, repeats: true)
        }
    }
    
    func stopAutoPlay() {
        timer?.invalidate()
        timer = nil
    }
    
    func showNext() {
        var currentIndexCarousel = carouselView.currentItemIndex
        if currentIndexCarousel == caroselItemsArray.count - 1 {
            currentIndexCarousel = 0
        }
        else {
            currentIndexCarousel = currentIndexCarousel + 1
        }
        carouselView.scrollToItem(at: currentIndexCarousel, animated: true)
    }
    
    func downloadImageFromUrl(imageUrl : String, imageView : UIImageView) {
        let session = URLSession.init(configuration: .default)
        session.downloadTask(with: URL.init(string: imageUrl)!) { (temporaryFileLocation, response, error) in
            if error != nil {
                print(error?.localizedDescription ??  "")
            }
            else {
                if let imgData = try? Data.init(contentsOf: temporaryFileLocation!) {
                    DispatchQueue.main.async {
                        imageView.image = UIImage.init(data: imgData)
                    }
                }
            }
        }.resume()
    }
    
}
