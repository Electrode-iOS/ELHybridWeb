//
//  WebViewControllerOptionsTests.swift
//  ELHybridWeb
//
//  Created by Angelo Di Paolo on 9/1/15.
//  Copyright (c) 2015 WalmartLabs. All rights reserved.
//

import UIKit
import XCTest
import JavaScriptCore
import ELHybridWeb

class WebViewControllerOptionsTests: XCTestCase {
    
    func testInitialization() {
        let context = JSContext(virtualMachine: JSVirtualMachine())
        let options = JSValue(newObjectInContext: context)
        
        context.evaluateScript("var onAppear = function() {};")
        let onAppearValue = context.objectForKeyedSubscript("onAppear")
        options.setValue(onAppearValue, forProperty: "onAppear")
        
        context.evaluateScript("var onNavigationBarButtonTap = function() {};")
        let onNavigationBarButtonTapValue = context.objectForKeyedSubscript("onNavigationBarButtonTap")
        options.setValue(onNavigationBarButtonTapValue, forProperty: "onNavigationBarButtonTap")
        
        context.evaluateScript("var navigationBarButtons = {};")
        let navigationBarButtons = context.objectForKeyedSubscript("navigationBarButtons")
        options.setValue(navigationBarButtons, forProperty: "navigationBarButtons")
        
        options.setValue("Hello", forProperty: "title")
        options.setValue(true, forProperty: "tabBarHidden")
        
        let webViewControllerOptions = WebViewControllerOptions(javaScriptValue: options)
        
        XCTAssertNotNil(webViewControllerOptions.title)
        XCTAssertEqual(webViewControllerOptions.title!, "Hello")
        XCTAssertTrue(webViewControllerOptions.tabBarHidden)
        XCTAssertEqual(webViewControllerOptions.onAppearCallback!, onAppearValue)
        XCTAssertEqual(webViewControllerOptions.navigationBarButtonCallback!, onNavigationBarButtonTapValue)
        XCTAssertEqual(webViewControllerOptions.navigationBarButtons!, navigationBarButtons)
    }
    
    func testInitializationWithUndefinedOptions() {
        let context = JSContext(virtualMachine: JSVirtualMachine())
        let webViewControllerOptions = WebViewControllerOptions(javaScriptValue: JSValue(undefinedInContext: context))
        
        XCTAssertNil(webViewControllerOptions.onAppearCallback)
        XCTAssertNil(webViewControllerOptions.navigationBarButtonCallback)
        XCTAssertNil(webViewControllerOptions.navigationBarButtons)
        XCTAssertNil(webViewControllerOptions.title)
        XCTAssertFalse(webViewControllerOptions.tabBarHidden)
    }
}
