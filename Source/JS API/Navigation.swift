//
//  Navigation.swift
//  THGHybridWeb
//
//  Created by Angelo Di Paolo on 4/22/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import JavaScriptCore

@objc protocol NavigationJSExport: JSExport {
    func animateForward(options: JSValue,  _ callback: JSValue)
    func animateBackward()
    func popToRoot()
}

@objc public class Navigation: ViewControllerChild, NavigationJSExport {
    
    weak var webViewController: WebViewController? {
        return parentViewController as? WebViewController
    }
    
    func animateForward(options: JSValue, _ callback: JSValue) {
        
        dispatch_async(dispatch_get_main_queue()) {
            self.webViewController?.pushWebViewControllerWithOptions(options)
        }
    }
    
    func animateBackward() {
        dispatch_async(dispatch_get_main_queue()) {
            self.webViewController?.popWebViewController()
        }
    }
    
    func popToRoot() {
        dispatch_async(dispatch_get_main_queue()) {
            self.parentViewController?.navigationController?.popToRootViewControllerAnimated(false)
        }
    }
}
