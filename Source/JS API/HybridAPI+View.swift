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
    fileprivate var onDisappearCallback: JSValue?
    internal var onShowCallback: (() -> Void)?
    
    public func appeared() {
        log(.Debug, "\(self) onAppearCallback:\(onAppearCallback)") // provide breadcrumbs
        onAppearCallback?.safelyCall(withArguments: nil)
    }
    
    public func disappeared() {
        log(.Debug, "\(self) onDisappearCallback:\(onDisappearCallback)") // provide breadcrumbs
        onDisappearCallback?.safelyCall(withArguments: nil)
    }
}

extension ViewAPI: ViewJSExport {
    /// Show the web view
    public func show() {
        DispatchQueue.main.async {
            self.webViewController?.showWebView()
            self.onShowCallback?()
        }
    }
    
    public func setOnAppear(callback: JSValue) {
        log(.Debug, "\(self) callback:\(callback)") // provide breadcrumbs
        onAppearCallback = callback
    }
    
    public func setOnDisappear(callback: JSValue) {
        log(.Debug, "\(self) callback:\(callback)") // provide breadcrumbs
        onDisappearCallback = callback
    }
}
