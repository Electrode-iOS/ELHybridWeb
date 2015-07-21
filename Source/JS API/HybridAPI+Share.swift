//
//  HybridAPI+Share.swift
//  THGHybridWeb
//
//  Created by Angelo Di Paolo on 5/4/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import Foundation
import JavaScriptCore
import UIKit

@objc protocol ShareJSExport: JSExport {
    func share(options: [String: AnyObject])
}

extension HybridAPI: ShareJSExport {
    
    func share(options: [String: AnyObject]) {
        dispatch_async(dispatch_get_main_queue()) {
            if let activityViewController = HybridAPI.activityViewControllerWithOptions(options) {
                self.parentViewController?.presentViewController(activityViewController, animated: true, completion: nil)
            }
        }
    }
    
    private static func activityViewControllerWithOptions(options: [String: AnyObject]) -> UIActivityViewController? {
        if let items = shareItemsFromOptions(options) {
            return UIActivityViewController(activityItems: items, applicationActivities: nil)
        }
        
        return nil
    }
    
    private static func shareItemsFromOptions(options: [String: AnyObject]) -> [AnyObject]? {
        if let message = options["message"] as? String,
            let url = options["url"] as? String {
                return [url, message]
        }
        
        return nil
    }
}
