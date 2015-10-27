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

    internal var onAppearCallback: JSValue?
    private var onDisappearCallback: JSValue?
    
    public func appeared() {
        THGHybridWebLogger.sharedLogger.log(.Debug, message: "\(self) onAppearCallback:\(onAppearCallback)") // provide breadcrumbs
        onAppearCallback?.safelyCallWithArguments(nil)
    }
    
    public func disappeared() {
        THGHybridWebLogger.sharedLogger.log(.Debug, message: "\(self) onDisappearCallback:\(onDisappearCallback)") // provide breadcrumbs
        onDisappearCallback?.safelyCallWithArguments(nil)
    }
}

extension ViewAPI: ViewJSExport {
    /// Show the web view
    public func show() {
        THGHybridWebLogger.sharedLogger.log(.Debug, message: "\(self)") // provide breadcrumbs
        webViewController?.showWebView()
    }
    
    public func setOnAppear(callback: JSValue) {
        THGHybridWebLogger.sharedLogger.log(.Debug, message: "\(self) callback:\(callback)") // provide breadcrumbs
        onAppearCallback = callback
    }
    
    public func setOnDisappear(callback: JSValue) {
        THGHybridWebLogger.sharedLogger.log(.Debug, message: "\(self) callback:\(callback)") // provide breadcrumbs
        onDisappearCallback = callback
    }
}
