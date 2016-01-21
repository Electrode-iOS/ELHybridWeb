//
//  HybridAPI+View.swift
//  ELHybridWeb
//
//  Created by Angelo Di Paolo on 7/21/15.
//  Copyright (c) 2015 WalmartLabs. All rights reserved.
//

import JavaScriptCore
import UIKit

@objc protocol ViewJSExport: JSExport {
    func show()
    func setOnAppear(callback: JSValue)
    func setOnDisappear(callback: JSValue)
}

@objc public class ViewAPI: ViewControllerChild  {

    internal var onAppearCallback: JSValue?
    private var onDisappearCallback: JSValue?
    internal var onShowCallback: (() -> Void)?
    
    public func appeared() {
        onAppearCallback?.safelyCallWithArguments(nil)
    }
    
    public func disappeared() {
        onDisappearCallback?.safelyCallWithArguments(nil)
    }
}

extension ViewAPI: ViewJSExport {
    /// Show the web view
    public func show() {
        dispatch_async(dispatch_get_main_queue()) {
            self.webViewController?.showWebView()
            self.onShowCallback?()
        }
    }
    
    public func setOnAppear(callback: JSValue) {
        onAppearCallback = callback
    }
    
    public func setOnDisappear(callback: JSValue) {
        onDisappearCallback = callback
    }
}
