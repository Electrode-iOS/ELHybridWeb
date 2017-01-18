//
//  WebViewControllerTests.swift
//  ELHybridWeb
//
//  Created by Angelo Di Paolo on 5/12/15.
//  Copyright (c) 2015 WalmartLabs. All rights reserved.
//

import UIKit
import XCTest
@testable import ELHybridWeb

class WebViewControllerTests: XCTestCase {
    
    func testGetWebViewJavaScriptContext() {
        let webView = UIWebView(frame: CGRect.zero)
        let context = webView.javaScriptContext
        XCTAssert(context != nil)
    }
    
    func testHybridAPIProperty() {
        let webViewController = WebViewController()
        webViewController.addBridgeAPIObject()
        XCTAssertNotNil(webViewController.hybridAPI)
    }
    
    func testDialogExport() {
        let webController = WebViewController()
        webController.addBridgeAPIObject()
        
        let result = webController.bridgeContext.evaluateScript("NativeBridge.dialog")!
        XCTAssert(result.isObject)
        XCTAssert(result.toObject() is NSDictionary)
    }
    
    func testShareExport() {
        let webController = WebViewController()
        webController.addBridgeAPIObject()
        
        let result = webController.bridgeContext.evaluateScript("NativeBridge.share")!
        XCTAssert(result.isObject)
        XCTAssert(result.toObject() is NSDictionary)
    }
    
    func testNavigationExport() {
        let webController = WebViewController()
        webController.addBridgeAPIObject()
        
        let result = webController.bridgeContext.evaluateScript("NativeBridge.navigation")!
        XCTAssert(result.isObject)
        XCTAssert(result.toObject() is Navigation)
    }
    
    func testNavigationAnimateForwardExport() {
        let webController = WebViewController()
        webController.addBridgeAPIObject()
        
        let result = webController.bridgeContext.evaluateScript("NativeBridge.navigation.animateForward")!
        XCTAssert(result.isObject)
        XCTAssert(result.toObject() is NSDictionary)
    }
    
    func testNavigationSetOnBackExport() {
        let webController = WebViewController()
        webController.addBridgeAPIObject()
        
        let result = webController.bridgeContext.evaluateScript("NativeBridge.navigation.setOnBack")!
        XCTAssert(result.isObject)
        XCTAssert(result.toObject() is NSDictionary)
    }
    
    func testNavigationBarExport() {
        let webController = WebViewController()
        webController.addBridgeAPIObject()
        
        let result = webController.bridgeContext.evaluateScript("NativeBridge.navigationBar")!
        XCTAssert(result.isObject)
        XCTAssert(result.toObject() is NavigationBar)
    }
    
    func testTabBarExport() {
        let webController = WebViewController()
        webController.addBridgeAPIObject()
        
        let result = webController.bridgeContext.evaluateScript("NativeBridge.tabBar")!
        XCTAssert(result.isObject)
        XCTAssert(result.toObject() is TabBar)
    }
    
    func testViewExport() {
        let webController = WebViewController()
        webController.addBridgeAPIObject()
        
        let result = webController.bridgeContext.evaluateScript("NativeBridge.view")!
        XCTAssert(result.isObject)
        XCTAssert(result.toObject() is ViewAPI)
    }
}

// MARK: - Test integration with View API

extension WebViewControllerTests {
    
    func testViewShow() {
        let webController = WebViewController()
        webController.addBridgeAPIObject()
        webController.webView.isHidden = true
        
        let showCompleteExpectation = expectation(description: "web view show completion callback ran")
        webController.hybridAPI?.view.onShowCallback = {
            showCompleteExpectation.fulfill()
        }
        
        webController.bridgeContext.evaluateScript("NativeBridge.view.show()")
        
        waitForExpectations(timeout: 3) { error in
            XCTAssertFalse(webController.webView.isHidden)
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
        tabBarController.tabBar.isHidden = true
        
        webController.bridgeContext.evaluateScript("NativeBridge.tabBar.show()")
        XCTAssertFalse(tabBarController.tabBar.isHidden)
    }
    
    func testTabBarHide() {
        let webController = WebViewController()
        webController.addBridgeAPIObject()
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [webController]
        
        webController.bridgeContext.evaluateScript("NativeBridge.tabBar.hide()")
        XCTAssertTrue(tabBarController.tabBar.isHidden)
    }
}

// MARK: - External Navigation

extension WebViewControllerTests {
    
    func testPresentExternalURLWithOptions() {
        let webController = WebViewController()
        webController.addBridgeAPIObject()
        
        let options = ExternalNavigationOptions.testOptions()!
        let externalWebViewController = webController.presentExternalURL(options: options)
        
        XCTAssertEqual(externalWebViewController.appearedFrom, WebViewController.AppearenceCause.external, "appearedFrom should be .External")
        XCTAssertNotNil(externalWebViewController.url)
        XCTAssertEqual(externalWebViewController.url!, options.url, "Should equal the original URL option value")
        XCTAssertEqual(externalWebViewController.externalReturnURL!, options.returnURL!, "Should equal the original return URL option value")
        XCTAssertNotEqual(webController.webView, externalWebViewController.webView, "Web views should be different instances")
    }
    
    func testPresentExternalURLWithOptionsNavigationBar() {
        let webController = WebViewController()
        webController.addBridgeAPIObject()
        
        let options = ExternalNavigationOptions.testOptions()!
        let externalWebViewController = webController.presentExternalURL(options: options)
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension WebViewControllerTests {
    
    func testSubclassInitialization() {
        let webViewController = TestWebViewController() // this should not even compile if initializers are defined improperly
        XCTAssertNotNil(webViewController)
    }
}
