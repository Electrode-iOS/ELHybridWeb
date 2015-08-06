//
//  WebViewControllerOptions.swift
//  walmart
//
//  Created by Angelo Di Paolo on 8/6/15.
//  Copyright (c) 2015 Walmart. All rights reserved.
//

import JavaScriptCore

public struct WebViewControllerOptions {
    private (set) var title: String?
    private (set) var tabBarHidden = false
    
    public init(javaScriptValue: JSValue) {
        self.title = javaScriptValue.valueForProperty("title").asString
        self.tabBarHidden = javaScriptValue.valueForProperty("tabBarHidden").toBool() ?? false
    }
}
