//
//  TabBar.swift
//  THGHybridWeb
//
//  Created by Angelo Di Paolo on 7/27/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import JavaScriptCore

@objc protocol TabBarJSExport: JSExport {
    func hide()
    func show()
}

@objc public class TabBar: ViewControllerChild, TabBarJSExport {
    
    public func hide() {
        parentViewController?.tabBarController?.tabBar.hidden = true
    }
    
    public func show() {
        parentViewController?.tabBarController?.tabBar.hidden = false
    }
}
