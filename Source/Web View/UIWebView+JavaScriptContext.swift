//
//  UIWebView+JavaScriptContext.swift
//  ELHybridWeb
//
//  Created by Angelo Di Paolo on 5/12/15.
//  Copyright (c) 2015 WalmartLabs. All rights reserved.
//

import UIKit
import JavaScriptCore

// MARK: - UIWebView's JavaScriptContext

private let webViewJavaScriptContextPath = "documentView.webView.mainFrame.javaScriptContext"

public extension UIWebView {
    /**
    Retreive the JavaScript context from the web view.
    */
    var javaScriptContext: JSContext? {
        return valueForKeyPath(webViewJavaScriptContextPath) as? JSContext
    }
}
