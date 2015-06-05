//
//  NavigationBar.swift
//  THGHybridWeb
//
//  Created by Angelo Di Paolo on 6/3/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import JavaScriptCore

@objc protocol NavigationBarJSExport: JSExport {
    func setTitle(title: String)
    func setButtons(buttonsToSet: [[String: AnyObject]], _ callback: JSValue)
}

@objc public class NavigationBar: ViewControllerChild {
    
    private var callback: JSValue?
    private var buttons: [Int: BarButton]? {
        didSet {
            if let leftButton = buttons?[0]?.barButtonItem {
                parentViewController?.navigationItem.leftBarButtonItem = leftButton
            }
            
            if let rightButton = buttons?[1]?.barButtonItem {
                parentViewController?.navigationItem.rightBarButtonItem = rightButton
            }
        }
    }
}

extension NavigationBar: NavigationBarJSExport {
    
    func setTitle(title: String) {
        dispatch_async(dispatch_get_main_queue()) {
            parentViewController?.title = title
        }
    }
    
    func setButtons(buttonsToSet: [[String: AnyObject]], _ callback: JSValue) {
        self.callback = callback

        dispatch_async(dispatch_get_main_queue()) {
            self.buttons = BarButton.dictionaryFromJSONArray(buttonsToSet, callback: callback) // must set buttons on main thread
        }
    }
}
