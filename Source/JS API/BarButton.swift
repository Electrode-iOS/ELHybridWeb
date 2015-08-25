//
//  BarButton.swift
//  THGHybridWeb
//
//  Created by Angelo Di Paolo on 6/4/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import JavaScriptCore
import UIKit

@objc class BarButton {
    let id: String
    let title: String
    let image: String?
    var callback: JSValue?
    
    init(id: String, title: String, image: String?) {
        self.id = id
        self.title = title
        self.image = image
    }
}

// MARK: - JSON Serialization

extension BarButton {
    
    static func dictionaryFromJSONArray(array: [AnyObject], callback: JSValue?) -> [Int: BarButton] {
        var buttons = [Int: BarButton]()
        
        for (index, buttonOptions) in enumerate(array) {
            if let buttonOptions = buttonOptions as? [String: String],
                let id = buttonOptions["id"],
                let title = buttonOptions["title"] {
                    
                let image = buttonOptions["image"]
                var button = BarButton(id: id, title: title, image: image)
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
    
    var barButtonItem: UIBarButtonItem {
        return UIBarButtonItem(title: title, style: UIBarButtonItemStyle.Plain, target: self, action: "select")
    }
    
    func select() {
        callback?.safelyCallWithArguments([id])
    }
}
