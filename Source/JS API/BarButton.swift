//
//  BarButton.swift
//  THGHybridWeb
//
//  Created by Angelo Di Paolo on 6/4/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import JavaScriptCore
import UIKit

// TODO: change all public members to internal after migrating to Swift 2 for testability
@objc public class BarButton: NSObject {
    public let id: String
    public let title: String
    public let image: String?
    public var callback: JSValue?
    
    public init(id: String, title: String, image: String?) {
        self.id = id
        self.title = title
        self.image = image
    }
}

// MARK: - JSON Serialization

extension BarButton {
    
    public static func dictionaryFromJSONArray(array: [AnyObject], callback: JSValue?) -> [Int: BarButton] {
        var buttons = [Int: BarButton]()
        
        for (index, buttonOptions) in array.enumerate() {
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
}

// MARK: - UIBarButtonItem

extension BarButton {
    
    public var barButtonItem: UIBarButtonItem {
        return UIBarButtonItem(title: title, style: UIBarButtonItemStyle.Plain, target: self, action: "select")
    }
    
    public func select() {
        THGHybridWebLogger.sharedLogger.log(.Debug, message: "") // provide breadcrumbs
        callback?.safelyCallWithArguments([id])
    }
}
