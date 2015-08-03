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
    
    private var onAppearCallback: JSManagedValue? {
        didSet {
            if hasAppeared {
                appeared()
            }
        }
    }
    
    private var onDisappearCallback: JSManagedValue?
    
    weak var webViewController: WebViewController? {
        return parentViewController as? WebViewController
    }
    
    func appeared() {
        hasAppeared = true
        self.onAppearCallback?.value?.callWithArguments(nil)
    }
    
    func disappeared() {
        self.onDisappearCallback?.value?.callWithArguments(nil)
    }
}

extension ViewAPI: ViewJSExport {
    /// Show the web view
    func show() {
        webViewController?.showWebView()
    }
    
    func setOnAppear(callback: JSValue) {
        dispatch_async(dispatch_get_main_queue()) {
            self.onAppearCallback = JSManagedValue(value: callback)
        }
    }
    
    func setOnDisappear(callback: JSValue) {
        dispatch_async(dispatch_get_main_queue()) {
            self.onDisappearCallback = JSManagedValue(value: callback)
        }
    }
}
