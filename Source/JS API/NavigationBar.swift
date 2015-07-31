//
//  NavigationBar.swift
//  THGHybridWeb
//
//  Created by Angelo Di Paolo on 6/3/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import JavaScriptCore

@objc protocol NavigationBarJSExport: JSExport {
    func setTitle(title: JSValue, _ callback: JSValue?)
    func setButtons(buttonsToSet: AnyObject?, _ callback: JSValue?, _ testingCallback: JSValue?)
}

@objc public class NavigationBar: ViewControllerChild {
    
    private var callback: JSValue?
    private var buttons: [Int: BarButton]? {
        didSet {
            if let buttons = buttons {
                if let leftButton = buttons[0]?.barButtonItem {
                    parentViewController?.navigationItem.leftBarButtonItem = leftButton
                }
                else {
                    parentViewController?.navigationItem.leftBarButtonItem = nil
                }
                
                if let rightButton = buttons[1]?.barButtonItem {
                    parentViewController?.navigationItem.rightBarButtonItem = rightButton
                }
                else {
                    parentViewController?.navigationItem.rightBarButtonItem = nil
                }
            } else {
                parentViewController?.navigationItem.leftBarButtonItem = nil
                parentViewController?.navigationItem.rightBarButtonItem = nil
            }
        }
    }
}

extension NavigationBar: NavigationBarJSExport {
    
    func setTitle(title: JSValue, _ callback: JSValue? = nil) {
        dispatch_async(dispatch_get_main_queue()) {
            self.configureTitle(title)
            callback?.callWithArguments(nil)
        }
    }
    
    func configureTitle(title: JSValue?) {
        self.parentViewController?.navigationItem.title = title?.asString
    }
    
    func setButtons(buttonsToSet: AnyObject?, _ callback: JSValue? = nil, _ testingCallback: JSValue? = nil) {
        dispatch_async(dispatch_get_main_queue()) {
            self.setButtons(buttonsToSet, callback: callback)
            testingCallback?.callWithArguments(nil) // only for testing purposes
        }
    }
    
    func setButtons(buttonsToSet: AnyObject?, callback: JSValue? = nil) {
        self.callback = callback
        
        if let buttonsToSet = buttonsToSet as? [[String: AnyObject]],
            let callback = callback
            where buttonsToSet.count > 0 {
                self.buttons = BarButton.dictionaryFromJSONArray(buttonsToSet, callback: callback) // must set buttons on main thread
        } else {
            self.buttons = nil
        }
    }
}
