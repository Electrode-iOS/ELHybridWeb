//
//  BarButton.swift
//  THGHybridWeb
//
//  Created by Angelo Di Paolo on 6/4/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import JavaScriptCore

@objc class BarButton: NSObject {
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
    
    static func dictionaryFromJSONArray(array: [[String: AnyObject]], callback: JSValue) -> [Int: BarButton] {
        var buttons = [Int: BarButton]()
        
        for (index, buttonDictionary) in array.enumerate() {
            if let id = buttonDictionary["id"] as? String,
                let title = buttonDictionary["title"] as? String {
                    let image = buttonDictionary["image"] as? String
                    let button = BarButton(id: id, title: title, image: image)
                    button.callback = callback
                    buttons[index] = button
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
        callback?.callWithArguments([id])
    }
}
