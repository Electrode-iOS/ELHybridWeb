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
}


// MARK: - External Navigation

@objc protocol ExternalNavigationJSExport: JSExport {
    func presentExternalURL(options: [String: String])
    func dismissExternalURL(urlString: String)
}

extension Navigation: ExternalNavigationJSExport {
    
    func presentExternalURL(options: [String: String])  {
        if let presentExternalOptions = PresentExternalOptions(options: options) {
            dispatch_async(dispatch_get_main_queue()) {
                self.webViewController?.presentExternalURL(presentExternalOptions.url, redirectURL: presentExternalOptions.returnURL)
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

struct PresentExternalOptions {
    let url: NSURL
    var returnURL: NSURL?
    
    init?(options: [String: String]) {
        if let urlString = options["url"],
            let url = NSURL(string: urlString) {
                self.url = url
                
                if let returnURLString = options["returnURL"],
                    let returnURL = NSURL(string: returnURLString) {
                    self.returnURL = returnURL
                }
        } else {
            return nil
        }
    }
}
