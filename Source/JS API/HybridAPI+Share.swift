//
//  HybridAPI+Share.swift
//  ELHybridWeb
//
//  Created by Angelo Di Paolo on 5/4/15.
//  Copyright (c) 2015 WalmartLabs. All rights reserved.
//

import JavaScriptCore

@objc protocol ShareJSExport: JSExport {
    func share(options: [String: Any])
}

extension HybridAPI {
    
    func share(options: [String: Any]) {
        DispatchQueue.main.async {
            if let activityViewController = HybridAPI.activityViewController(withOptions: options) {
                self.parentViewController?.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
    
    private static func activityViewController(withOptions options: [String: Any]) -> UIActivityViewController? {
        if let items = shareItems(withOptions: options) {
            return UIActivityViewController(activityItems: items, applicationActivities: nil)
        }
        
        return nil
    }
    
    private static func shareItems(withOptions options: [String: Any]) -> [Any]? {
        if let message = options["message"] as? String,
            let url = options["url"] as? String {
                return [url, message]
        }
        
        return nil
    }
}
