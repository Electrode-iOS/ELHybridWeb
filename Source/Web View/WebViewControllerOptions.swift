//
//  WebViewControllerOptions.swift
//  walmart
//
//  Created by Angelo Di Paolo on 8/6/15.
//  Copyright (c) 2015 Walmart. All rights reserved.
//

import JavaScriptCore

public struct WebViewControllerOptions {
    private (set) public var title: String?
    private (set) public var tabBarHidden = false
    private (set) public var onAppearCallback: JSValue?
    private (set) public var navigationBarButtonCallback: JSValue?
    private (set) public var navigationBarButtons: JSValue?

    public init(javaScriptValue: JSValue) {
        // TODO: make this a `guard` statement after migrating to Swift 2
        if let optionsValue = javaScriptValue.asValidValue {
            self.title = optionsValue.valueForProperty("title").asString
            self.tabBarHidden = optionsValue.valueForProperty("tabBarHidden").toBool() ?? false
            self.onAppearCallback = optionsValue.valueForProperty("onAppear")
            self.navigationBarButtonCallback = optionsValue.valueForProperty("onNavigationBarButtonTap").asValidValue
            self.navigationBarButtons = optionsValue.valueForProperty("navigationBarButtons").asValidValue
        }
    }
}
