//
//  Navigation+External.swift
//  walmart
//
//  Created by Angelo Di Paolo on 8/25/15.
//  Copyright (c) 2015 Walmart. All rights reserved.
//

import JavaScriptCore

@objc protocol ExternalNavigationJSExport: JSExport {
    func presentExternalURL(_ options: [String: String])
    func dismissExternalURL(_ urlString: String)
}

extension Navigation: ExternalNavigationJSExport {
    
    func presentExternalURL(_ options: [String: String])  {
        log(.debug, "options:\(options)") // provide breadcrumbs
        if let externalOptions = ExternalNavigationOptions(options: options) {
            DispatchQueue.main.async {
                self.webViewController?.presentExternalURL(options: externalOptions)
            }
        }
    }
    
    func dismissExternalURL(_ urlString: String) {
        log(.debug, "urlString\(urlString)") // provide breadcrumbs
        if let url = URL(string: urlString) {
            if let presentingWebViewController = webViewController?.externalPresentingWebViewController {
                presentingWebViewController.load(url: url)
            } else {
                webViewController?.load(url: url)
            }
            
            parentViewController?.dismiss(animated: true, completion: nil)
        }
    }
}

// TODO: Make internal after migrating to Swift 2 and @testable
public struct ExternalNavigationOptions {
    public let url: URL
    private(set) public var returnURL: URL?
    private(set) public var title: String?
    
    public init?(options: [String: String]) {
        if let urlString = options["url"],
            let url = URL(string: urlString) {
                self.url = url
                
                if let returnURLString = options["returnURL"],
                    let returnURL = URL(string: returnURLString) {
                        self.returnURL = returnURL
                }
                
                self.title = options["title"]
        } else {
            return nil
        }
    }
}
