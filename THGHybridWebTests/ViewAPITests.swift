//
//  ViewAPITests.swift
//  THGHybridWeb
//
//  Created by Angelo Di Paolo on 8/11/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import UIKit
import XCTest
import THGHybridWeb
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
        
        webController.webView.hidden = true
        api.view.show()
        
        XCTAssertFalse(webController.webView.hidden)
    }
    
    // TODO: safelyCallWithArguments is breaking this test
//    func testOnAppear() {
//        let expectation = expectationWithDescription("On appear called")
//        let webController = WebViewController()
//        let api = HybridAPI(parentViewController: webController)
//        
//        let callbackName = "_onAppear"
//        let callback: @objc_block () -> Void = {
//            expectation.fulfill()
//        }
//        let unsafeCastedCallback: AnyObject = unsafeBitCast(callback, AnyObject.self)
//        let context = JSContext(virtualMachine: JSVirtualMachine())
//
//        context.setObject(api, forKeyedSubscript: HybridAPI.exportName)
//        context.setObject(unsafeCastedCallback, forKeyedSubscript: callbackName)
//        let callbackValue = context.objectForKeyedSubscript(callbackName)
//        api.view.setOnAppear(callbackValue)
//        api.view.appeared()
//        
//        waitForExpectationsWithTimeout(2.0, handler: nil)
//    }
}
