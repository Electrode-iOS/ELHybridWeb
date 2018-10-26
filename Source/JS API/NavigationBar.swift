//
//  NavigationBar.swift
//  ELHybridWeb
//
//  Created by Angelo Di Paolo on 6/3/15.
//  Copyright (c) 2015 WalmartLabs. All rights reserved.
//

import JavaScriptCore

@objc protocol NavigationBarJSExport: JSExport {
    func setTitle(_ title: JSValue, _ callback: JSValue?)
    func setButtons(_ buttonsToSet: JSValue?, _ callback: JSValue?, _ testingCallback: JSValue?)
}

@objc public class NavigationBar: ViewControllerChild {
    public var title: String? {
        didSet {
            parentViewController?.navigationItem.title = title
        }
    }
    
    fileprivate var buttons: [Int: BarButton]? {
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
                parentViewController?.navigationItem.hidesBackButton = true
                parentViewController?.navigationItem.leftBarButtonItem = nil
                parentViewController?.navigationItem.rightBarButtonItem = nil
            }
        }
    }
}

extension NavigationBar: NavigationBarJSExport {
    func setTitle(_ title: JSValue, _ callback: JSValue? = nil) {
        log(.debug, "title:\(title), callback\(String(describing: callback))") // provide breadcrumbs
        DispatchQueue.main.async {
            self.title = title.asString
            callback?.safelyCall(withArguments: nil)
        }
    }
    
    func setButtons(_ buttonsToSet: JSValue?, _ callback: JSValue? = nil, _ testingCallback: JSValue? = nil) {
        log(.debug, "buttonsToSet\(String(describing: buttonsToSet)), callback:\(String(describing: callback))") // provide breadcrumbs
        DispatchQueue.main.async {
            self.configureButtons(buttonsToSet, callback: callback)
            testingCallback?.safelyCall(withArguments: nil) // only for testing purposes
        }
    }
    
    func configureButtons(_ buttonsToSet: JSValue?, callback: JSValue?) {
        log(.debug, "buttonsToSet\(String(describing: buttonsToSet)), callback:\(String(describing: callback))") // provide breadcrumbs
        if let buttonOptions = buttonsToSet?.toObject() as? [AnyObject] {
            buttons = BarButton.dictionary(fromJSONArray: buttonOptions, callback: callback) // must set buttons on main thread
        } else {
            buttons = nil
        }
    }
}
