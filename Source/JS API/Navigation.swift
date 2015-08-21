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
    func setOnBack(callback: JSValue)
    func presentExternalURL(urlString: String)
    func dismissExternalURL(urlString: String)
}

@objc public class Navigation: ViewControllerChild, NavigationJSExport {
    
    var topWebViewController: WebViewController? {
        return parentViewController?.navigationController?.topViewController as? WebViewController
    }
    private var onBackCallback: JSValue?

    func animateForward(options: JSValue, _ callback: JSValue) {
        dispatch_async(dispatch_get_main_queue()) {
            let vcOptions = WebViewControllerOptions(javaScriptValue: options)
            self.webViewController?.pushWebViewControllerWithOptions(vcOptions)
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

    func back() {
        if let validCallbackValue = onBackCallback?.asValidValue {
            onBackCallback?.safelyCallWithArguments(nil)
        } else {
            webViewController?.webView.stopLoading()
            webViewController?.webView.delegate = topWebViewController
            webViewController?.webView.goBack()
        }
    }

    func setOnBack(callback: JSValue) {
        onBackCallback = callback
    }

    func presentExternalURL(urlString: String)  {
        if let url = NSURL(string: urlString) {
            dispatch_async(dispatch_get_main_queue()) {
                webViewController?.presentExternalURL(url)
            }
        }
    }

    func dismissExternalURL(urlString: String) {
        if let url = NSURL(string: urlString) {
            if let presentingWebViewController = webViewController?.externalPresentingWebViewController {
                presentingWebViewController.loadURL(url)
            } else {
                webViewController?.loadURL(url)
            }

            parentViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
