//
//  BarButton.swift
//  THGHybridWeb
//
//  Created by Angelo Di Paolo on 6/4/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import JavaScriptCore

@objc protocol BarButtonJSExport: JSExport {
    var title: String? {get set}
    var onClick: JSValue? {get set}
}

@objc class BarButton: NSObject, BarButtonJSExport {
    
    var title: String?
    var onClick: JSValue?
    var barButtonItem: UIBarButtonItem {
        return UIBarButtonItem(title: title, style: UIBarButtonItemStyle.Plain, target: self, action: "select")
    }
    
    init(title: String, onClick: JSValue) {
        self.title = title
        self.onClick = onClick
    }
    
    func select() {
        onClick?.callWithArguments(nil)
    }
}

extension BarButton {
    
    class func dictionaryFromArray(array: [BarButton]) -> [Int: BarButton] {
        var buttons = [Int: BarButton]()
        
        for (index, button) in enumerate(array) {
            buttons[index] = button
        }
        
        return buttons
    }
}
