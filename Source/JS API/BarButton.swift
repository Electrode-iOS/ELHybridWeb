//
//  BarButton.swift
//  ELHybridWeb
//
//  Created by Angelo Di Paolo on 6/4/15.
//  Copyright (c) 2015 WalmartLabs. All rights reserved.
//

import JavaScriptCore
import UIKit

@objc public class BarButton: NSObject {
    let id: String
    let title: String
    let image: String?
    var callback: JSValue?
    
    public init(id: String, title: String, image: String?) {
        self.id = id
        self.title = title
        self.image = image
    }
    
    // MARK: JSON Serialization
    
    public static func dictionary(fromJSONArray array: [Any], callback: JSValue?) -> [Int: BarButton] {
        var buttons = [Int: BarButton]()

        for (index, buttonOptions) in array.enumerated() {
            if let buttonOptions = buttonOptions as? [String: String],
                let id = buttonOptions["id"],
                let title = buttonOptions["title"] {
                    
                let image = buttonOptions["image"]
                let button = BarButton(id: id, title: title, image: image)
                button.callback = callback
                buttons[index] = button
            } else if buttonOptions is NSNull {
                buttons[index] = nil
            }
        }
        
        return buttons
    }
    
    // MARK: UIBarButtonItem
    
    public var barButtonItem: UIBarButtonItem {
        return UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(BarButton.select))
    }
    
    @objc public func select() {
        log(.debug, "") // provide breadcrumbs
        callback?.safelyCall(withArguments: [id])
    }
}
