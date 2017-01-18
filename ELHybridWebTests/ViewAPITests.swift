//
//  ViewAPITests.swift
//  ELHybridWeb
//
//  Created by Angelo Di Paolo on 8/11/15.
//  Copyright (c) 2015 WalmartLabs. All rights reserved.
//

import UIKit
import XCTest
@testable import ELHybridWeb
import JavaScriptCore

class ViewAPITests: XCTestCase {
    func testParentViewControllerChange() {
        let webController = WebViewController()
        let api = HybridAPI(parentViewController: webController)
        let newWebViewController = WebViewController()
        api.parentViewController = newWebViewController
        
        XCTAssertNotNil(api.view.parentViewController)
        XCTAssertEqual(api.view.parentViewController!, newWebViewController)
    }
    
    func testExportName() {
        let api = HybridAPI(parentViewController: WebViewController())
        let context = JSContext(virtualMachine: JSVirtualMachine())!
        context.setObject(api, forKeyedSubscript: HybridAPI.exportName as NSString)
        
        let viewObject: Any = context.evaluateScript("NativeBridge.view").toObject()
        XCTAssert(viewObject is ViewAPI)
    }
    
    func testShow() {
        let webController = WebViewController()
        let api = HybridAPI(parentViewController: webController)
        let context = JSContext(virtualMachine: JSVirtualMachine())!
        context.setObject(api, forKeyedSubscript: HybridAPI.exportName as NSString)
        
        let showCompleteExpectation = expectation(description: "web view show completion callback ran")
        api.view.onShowCallback = {
            showCompleteExpectation.fulfill()
        }
        
        webController.webView.isHidden = true
        api.view.show()
        
        waitForExpectations(timeout: 3.0) { error in
            XCTAssertFalse(webController.webView.isHidden)
        }
    }
    
    func testSetOnAppearExport() {
        let webController = WebViewController()
        webController.addBridgeAPIObject()
        
        let result = webController.bridgeContext.evaluateScript("NativeBridge.view.setOnAppear")!
        XCTAssert(result.isObject)
        XCTAssert(result.toObject() is NSDictionary)
    }
    
    func testSetOnDisappearExport() {
        let webController = WebViewController()
        webController.addBridgeAPIObject()
        
        let result = webController.bridgeContext.evaluateScript("NativeBridge.view.setOnDisappear")!
        XCTAssert(result.isObject)
        XCTAssert(result.toObject() is NSDictionary)
    }
}
