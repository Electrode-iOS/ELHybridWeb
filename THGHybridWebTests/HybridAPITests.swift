//
//  HybridAPITests.swift
//  THGHybridWeb
//
//  Created by Angelo Di Paolo on 5/5/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import UIKit
import XCTest
import THGHybridWeb
import THGBridge

class HybridAPITests: XCTestCase {

    func testUpdateState() {
        let webController = WebViewController()
        webController.addBridgeAPIObject()

        let title = "What is your name?"
        let options = "{title: '\(title)'}"
        let updateScript = "\(HybridAPI.exportName).updatePageState(\(options))"
        webController.bridge.context.evaluateScript(updateScript)
        
        XCTAssertNotNil(webController.bridge.context.exception)
        XCTAssertNotNil(webController.title)
        XCTAssertEqual(title, webController.title!)
    }
    
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
