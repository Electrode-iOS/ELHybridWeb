//
//  Navigation+External.swift
//  walmart
//
//  Created by Angelo Di Paolo on 8/25/15.
//  Copyright (c) 2015 Walmart. All rights reserved.
//

import JavaScriptCore

@objc protocol ExternalNavigationJSExport: JSExport {
    func presentExternalURL(options: [String: String])
    func dismissExternalURL(urlString: String)
}

extension Navigation: ExternalNavigationJSExport {
    
    func presentExternalURL(options: [String: String])  {
        if let externalOptions = ExternalNavigationOptions(options: options) {
            dispatch_async(dispatch_get_main_queue()) {
                self.webViewController?.presentExternalURLWithOptions(externalOptions)
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

// TODO: Make internal after migrating to Swift 2 and @testable
public struct ExternalNavigationOptions {
    public let url: NSURL
    private(set) public var returnURL: NSURL?
    private(set) public var title: String?
    
    public init?(options: [String: String]) {
        if let urlString = options["url"],
            let url = NSURL(string: urlString) {
                self.url = url
                
                if let returnURLString = options["returnURL"],
                    let returnURL = NSURL(string: returnURLString) {
                        self.returnURL = returnURL
                }
                
                self.title = options["title"]
        } else {
            return nil
        }
    }
}
