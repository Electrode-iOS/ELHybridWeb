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

class HybridAPITests: XCTestCase {
    
    func testDialogExport() {
        let webController = WebViewController()
        webController.addBridgeAPIObject()
        
        let result = webController.bridgeContext.evaluateScript("NativeBridge.dialog")!
        
        
        XCTAssert(result.isObject)
        XCTAssert(result.toObject() is Dictionary)
    }
    
    func testShareExport() {
        let webController = WebViewController()
        webController.addBridgeAPIObject()
        
        let result = webController.bridgeContext.evaluateScript("NativeBridge.share")!
        
        XCTAssert(result.isObject)
        XCTAssert(result.toObject() is Dictionary)
    }
    
    func testNavigationExport() {
        let webController = WebViewController()
        webController.addBridgeAPIObject()
        
        let result = webController.bridgeContext.evaluateScript("NativeBridge.navigation")!
        
        XCTAssert(result.isObject)
        XCTAssert(result.toObject() is Navigation)
    }
    
    func testExportName() {
        XCTAssertEqual(HybridAPI.exportName, "NativeBridge")
    }
}
