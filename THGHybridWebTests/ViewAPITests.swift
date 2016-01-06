//
//  ViewAPITests.swift
//  THGHybridWeb
//
//  Created by Angelo Di Paolo on 8/11/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import UIKit
import XCTest
@testable import THGHybridWeb
import THGBridge
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
        let context = JSContext(virtualMachine: JSVirtualMachine())
        context.setObject(api, forKeyedSubscript: HybridAPI.exportName)
        
        let viewObject: AnyObject = context.evaluateScript("NativeBridge.view").toObject()
        XCTAssert(viewObject is ViewAPI)
    }
    
    func testShow() {
        let webController = WebViewController()
        let api = HybridAPI(parentViewController: webController)
        let context = JSContext(virtualMachine: JSVirtualMachine())
        context.setObject(api, forKeyedSubscript: HybridAPI.exportName)
        
        let showCompleteExpectation = expectationWithDescription("web view show completion callback ran")
        api.view.onShowCallback = {
            showCompleteExpectation.fulfill()
        }
        
        webController.webView.hidden = true
        api.view.show()
        
        waitForExpectationsWithTimeout(3.0) { error in
            XCTAssertFalse(webController.webView.hidden)
        }
        
    }
}
