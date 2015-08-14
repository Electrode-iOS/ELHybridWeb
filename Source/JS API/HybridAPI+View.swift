//
//  HybridAPI+View.swift
//  THGHybridWeb
//
//  Created by Angelo Di Paolo on 7/21/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import JavaScriptCore
import UIKit

@objc protocol ViewJSExport: JSExport {
    func show()
    func setOnAppear(callback: JSValue)
    func setOnDisappear(callback: JSValue)
}

@objc public class ViewAPI: ViewControllerChild  {

    private var hasAppeared = false
    
    internal var onAppearCallback: JSValue? {
        didSet {
            if hasAppeared {
                appeared()
            }
        }
    }
    
    private var onDisappearCallback: JSValue?
    
    weak var webViewController: WebViewController? {
        return parentViewController as? WebViewController
    }
    
    public func appeared() {
        hasAppeared = true
        onAppearCallback?.safelyCallWithArguments(nil)
    }
    
    public func disappeared() {
        onDisappearCallback?.safelyCallWithArguments(nil)
    }
}

extension ViewAPI: ViewJSExport {
    /// Show the web view
    public func show() {
        webViewController?.showWebView()
    }
    
    public func setOnAppear(callback: JSValue) {
        onAppearCallback = callback
    }
    
    public func setOnDisappear(callback: JSValue) {
        onDisappearCallback = callback
    }
}
