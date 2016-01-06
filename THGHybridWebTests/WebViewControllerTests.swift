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
@testable import THGHybridWeb

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
        XCTAssert(result.isObject)
        XCTAssert(result.toObject() is NSDictionary)
    }
    
    func testShareExport() {
        let webController = WebViewController()
        webController.addBridgeAPIObject()
        
        let result = webController.bridge.context.evaluateScript("NativeBridge.share")
        XCTAssert(result.isObject)
        XCTAssert(result.toObject() is NSDictionary)
    }
    
    func testNavigationExport() {
        let webController = WebViewController()
        webController.addBridgeAPIObject()
        
        let result = webController.bridge.context.evaluateScript("NativeBridge.navigation")
        XCTAssert(result.isObject)
        XCTAssert(result.toObject() is Navigation)
    }
    
    func testNavigationBarExport() {
        let webController = WebViewController()
        webController.addBridgeAPIObject()
        
        let result = webController.bridge.context.evaluateScript("NativeBridge.navigationBar")
        XCTAssert(result.isObject)
        XCTAssert(result.toObject() is NavigationBar)
    }
    
    func testTabBarExport() {
        let webController = WebViewController()
        webController.addBridgeAPIObject()
        
        let result = webController.bridge.context.evaluateScript("NativeBridge.tabBar")
        XCTAssert(result.isObject)
        XCTAssert(result.toObject() is TabBar)
    }
    
    func testViewExport() {
        let webController = WebViewController()
        webController.addBridgeAPIObject()
        
        let result = webController.bridge.context.evaluateScript("NativeBridge.view")
        XCTAssert(result.isObject)
        XCTAssert(result.toObject() is ViewAPI)
    }
}

// MARK: - Test integration with View API

extension WebViewControllerTests {
    
    func testViewShow() {
        let webController = WebViewController()
        webController.addBridgeAPIObject()
        webController.webView.hidden = true
        
        let showCompleteExpectation = expectationWithDescription("web view show completion callback ran")
        webController.hybridAPI?.view.onShowCallback = {
            showCompleteExpectation.fulfill()
        }
        
        webController.bridge.context.evaluateScript("NativeBridge.view.show()")
        
        waitForExpectationsWithTimeout(3) { error in
            XCTAssertFalse(webController.webView.hidden)
        }
    }
}

// MARK: - Test integration with Tab Bar API

extension WebViewControllerTests {

    func testTabBarShow() {
        let webController = WebViewController()
        webController.addBridgeAPIObject()
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [webController]
        tabBarController.tabBar.hidden = true
        
        webController.bridge.context.evaluateScript("NativeBridge.tabBar.show()")
        XCTAssertFalse(tabBarController.tabBar.hidden)
    }
    
    func testTabBarHide() {
        let webController = WebViewController()
        webController.addBridgeAPIObject()
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [webController]
        
        webController.bridge.context.evaluateScript("NativeBridge.tabBar.hide()")
        XCTAssertTrue(tabBarController.tabBar.hidden)
    }
}

// MARK: - External Navigation

extension WebViewControllerTests {
    
    func testPresentExternalURLWithOptions() {
        let webController = WebViewController()
        webController.addBridgeAPIObject()
        
        let options = ExternalNavigationOptions.testOptions()!
        let externalWebViewController = webController.presentExternalURLWithOptions(options)
        
        XCTAssertEqual(externalWebViewController.appearedFrom, WebViewController.AppearenceCause.External, "appearedFrom should be .External")
        XCTAssertNotNil(externalWebViewController.url)
        XCTAssertEqual(externalWebViewController.url!, options.url, "Should equal the original URL option value")
        XCTAssertEqual(externalWebViewController.externalReturnURL!, options.returnURL!, "Should equal the original return URL option value")
        XCTAssertNotEqual(webController.webView, externalWebViewController.webView, "Web views should be different instances")
    }
    
    func testPresentExternalURLWithOptionsNavigationBar() {
        let webController = WebViewController()
        webController.addBridgeAPIObject()
        
        let options = ExternalNavigationOptions.testOptions()!
        let externalWebViewController = webController.presentExternalURLWithOptions(options)
        
        let backButton = externalWebViewController.navigationItem.leftBarButtonItem
        XCTAssertNotNil(backButton, "Back bar button should not be nil")
        XCTAssertEqual(backButton!.title!, "Back")
        
        let doneButton = externalWebViewController.navigationItem.rightBarButtonItem
        XCTAssertNotNil(doneButton, "Done bar button should not be nil")
        XCTAssertEqual(doneButton!.title!, "Done")
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
