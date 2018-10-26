//
//  Navigation.swift
//  ELHybridWeb
//
//  Created by Angelo Di Paolo on 4/22/15.
//  Copyright (c) 2015 WalmartLabs. All rights reserved.
//

import JavaScriptCore

@objc protocol NavigationJSExport: JSExport {
    func animateForward(_ options: JSValue,  _ callback: JSValue)
    func animateBackward()
    func popToRoot()
    func setOnBack(_ callback: JSValue)
}

@objc public class Navigation: ViewControllerChild, NavigationJSExport {
    
    var topWebViewController: WebViewController? {
        return parentViewController?.navigationController?.topViewController as? WebViewController
    }
    private var onBackCallback: JSValue?

    func animateForward(_ options: JSValue, _ callback: JSValue) {
        log(.debug, "\(self) options:\(options), callback:\(callback)") // provide breadcrumbs
        DispatchQueue.main.async {
            let vcOptions = WebViewControllerOptions(javaScriptValue: options)
            self.webViewController?.pushWebViewController(options: vcOptions)
        }
    }
    
    func animateBackward() {
        log(.debug, "\(self)") // provide breadcrumbs
        DispatchQueue.main.async {
            self.webViewController?.popWebViewController()
        }
    }
    
    func popToRoot() {
        log(.debug, "\(self)") // provide breadcrumbs
        DispatchQueue.main.async {
            self.webViewController?.popToRootWebViewController(animated: false)
        }
    }

    func back() {
        log(.debug, "\(self)") // provide breadcrumbs
        if let _ = onBackCallback?.asValidValue {
            onBackCallback?.safelyCall(withArguments: nil)
        } else {
            webViewController?.webView.stopLoading()
            webViewController?.webView.delegate = topWebViewController
            webViewController?.webView.goBack()
        }
    }

    func setOnBack(_ callback: JSValue) {
        log(.debug, "\(self) callback:\(callback)") // provide breadcrumbs
        onBackCallback = callback
    }
}
