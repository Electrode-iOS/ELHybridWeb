//
//  Navigation+Modal.swift
//  ELHybridWeb
//
//  Created by Angelo Di Paolo on 6/15/15.
//  Copyright (c) 2015 WalmartLabs. All rights reserved.
//

import JavaScriptCore

@objc protocol ModalNavigationJSExport: JSExport {
    func presentModal(options: JSValue)
    func dismissModal()
}

extension Navigation: ModalNavigationJSExport {
    func presentModal(options: JSValue) {
        log(.Debug, "\(self) options:\(options)")
        DispatchQueue.main.async {
            let vcOptions = WebViewControllerOptions(javaScriptValue: options)
            self.webViewController?.presentModalWebViewController(options: vcOptions)
        }
    }
    
    func dismissModal() {
        log(.Debug, "\(self)") // provide breadcrumbs
        DispatchQueue.main.async {
            self.parentViewController?.dismiss(animated: true, completion: nil)
        }
    }
}
