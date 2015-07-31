//
//  Navigation+Modal.swift
//  THGHybridWeb
//
//  Created by Angelo Di Paolo on 6/15/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import JavaScriptCore

@objc protocol ModalNavigationJSExport: JSExport {
    func presentModal(callback: JSValue)
    func dismissModal()
}

extension Navigation: ModalNavigationJSExport {
    
    func presentModal(callback: JSValue) {
        dispatch_async(dispatch_get_main_queue()) {
            self.webViewController?.presentModalWebViewController(callback)
        }
    }
    
    func dismissModal() {
        dispatch_async(dispatch_get_main_queue()) {
            self.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
