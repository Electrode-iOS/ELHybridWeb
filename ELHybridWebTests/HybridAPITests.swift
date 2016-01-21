//
//  HybridAPITests.swift
//  ELHybridWeb
//
//  Created by Angelo Di Paolo on 5/5/15.
//  Copyright (c) 2015 WalmartLabs. All rights reserved.
//

import UIKit
import XCTest
import ELHybridWeb
import ELJSBridge

class HybridAPITests: XCTestCase {
    
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
    
    func testExportName() {
        XCTAssertEqual(HybridAPI.exportName, "NativeBridge")
    }
}
