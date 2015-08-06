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
    
    func appeared() {
        hasAppeared = true
        onAppearCallback?.callWithArguments(nil)
    }
    
    func disappeared() {
        onDisappearCallback?.callWithArguments(nil)
    }
}

extension ViewAPI: ViewJSExport {
    /// Show the web view
    func show() {
        webViewController?.showWebView()
    }
    
    func setOnAppear(callback: JSValue) {
        if NSThread.isMainThread() {
            onAppearCallback = callback
        } else {
            dispatch_sync(dispatch_get_main_queue()) {
                self.onAppearCallback = callback
            }
        }
    }
    
    func setOnDisappear(callback: JSValue) {
        if NSThread.isMainThread() {
            onDisappearCallback = callback
        } else {
            dispatch_sync(dispatch_get_main_queue()) {
                self.onDisappearCallback = callback
            }
        }
    }
}
