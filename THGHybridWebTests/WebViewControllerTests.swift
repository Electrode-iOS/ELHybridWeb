//
//  WebViewControllerTests.swift
//  THGHybridWeb
//
//  Created by Angelo Di Paolo on 5/12/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import UIKit
import XCTest
import THGBridge
import THGHybridWeb

class WebViewControllerTests: XCTestCase {
    
    func testGetWebViewJavaScriptContext() {
        let webView = UIWebView(frame: CGRectZero)
        let context = webView.javaScriptContext
        XCTAssert(context != nil)
    }
    
    func testHybridAPIProperty() {
        let webViewController = WebViewController()
        webViewController.addBridgeAPIObject()
        XCTAssertNotNil(webViewController.hybridAPI)
    }
}

// MARK: - Exports

extension WebViewControllerTests {
    
    func testDialogExport() {
        let webController = WebViewController()
        webController.addBridgeAPIObject()
        
        let result = webController.bridge.context.evaluateScript("NativeBridge.dialog")
        XCTAssert(result.isObject())
        XCTAssert(result.toObject() is NSDictionary)
    }
    
    func testShareExport() {
        let webController = WebViewController()
        webController.addBridgeAPIObject()
        
        let result = webController.bridge.context.evaluateScript("NativeBridge.share")
        XCTAssert(result.isObject())
        XCTAssert(result.toObject() is NSDictionary)
    }
    
    func testNavigationExport() {
        let webController = WebViewController()
        webController.addBridgeAPIObject()
        
        let result = webController.bridge.context.evaluateScript("NativeBridge.navigation")
        XCTAssert(result.isObject())
        XCTAssert(result.toObject() is Navigation)
    }
}

// MARK: - Subclassing

class TestWebViewController: WebViewController {
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension WebViewControllerTests {
    
    func testSubclassInitialization() {
        let webViewController = TestWebViewController() // this should not even compile if initializers are defined improperly
        XCTAssertNotNil(webViewController)
    }
}
