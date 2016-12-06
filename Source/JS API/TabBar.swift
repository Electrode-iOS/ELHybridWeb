//
//  TabBar.swift
//  ELHybridWeb
//
//  Created by Angelo Di Paolo on 7/27/15.
//  Copyright (c) 2015 WalmartLabs. All rights reserved.
//

import JavaScriptCore

@objc protocol TabBarJSExport: JSExport {
    func hide()
    func show()
}

@objc public class TabBar: ViewControllerChild, TabBarJSExport {
    public func hide() {
        parentViewController?.tabBarController?.tabBar.isHidden = true
    }
    
    public func show() {
        parentViewController?.tabBarController?.tabBar.isHidden = false
    }
}
