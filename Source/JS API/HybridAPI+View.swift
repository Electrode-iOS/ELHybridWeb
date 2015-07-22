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
}

@objc public class ViewAPI: ViewControllerChild, ViewJSExport {
    
    weak var webViewController: WebViewController? {
        return parentViewController as? WebViewController
    }
    
    func show() {
        webViewController?.showWebView()
    }
}
