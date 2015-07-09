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
        webController.addHybridAPI()

        let title = "What is your name?"
        let options = "{title: '\(title)'}"
        let updateScript = "\(HybridAPI.exportName).updatePageState(\(options))"
        webController.bridge.context.evaluateScript(updateScript)
        
        XCTAssertNotNil(webController.bridge.context.exception)
        XCTAssertNotNil(webController.title)
        XCTAssertEqual(title, webController.title!)
    }
    
    func testAddHybridAPI() {
        let webController = WebViewController()
        webController.addHybridAPI()
        
        let platform: AnyObject = webController.bridge.contextValueForName(HybridAPI.exportName).toObject()
        
        XCTAssert(platform is HybridAPI)
    }
    
    func testHybridAPIProperty() {
        let bridge = Bridge()
        let hybridAPI = HybridAPI(parentViewController: WebViewController())
        bridge.addExport(hybridAPI, name: HybridAPI.exportName)
        
        XCTAssertNotNil(bridge.hybridAPI)
        XCTAssertEqual(bridge.hybridAPI!, hybridAPI)
    }
    
    func testDialogExport() {
        let webController = WebViewController()
        webController.addHybridAPI()
        
        let result = webController.bridge.context.evaluateScript("NativeBridge.dialog")
        XCTAssert(result.isObject)
        XCTAssert(result.toObject() is NSDictionary)
    }
    
    func testShareExport() {
        let webController = WebViewController()
        webController.addHybridAPI()
        
        let result = webController.bridge.context.evaluateScript("NativeBridge.share")
        
        XCTAssert(result.isObject)
        XCTAssert(result.toObject() is NSDictionary)
    }
    
    func testNavigationExport() {
        let webController = WebViewController()
        webController.addHybridAPI()
        
        let result = webController.bridge.context.evaluateScript("NativeBridge.navigation")
        
        XCTAssert(result.isObject)
        XCTAssert(result.toObject() is Navigation)
    }
    
    func testDidSetParentViewControllers() {
        let webController = WebViewController()
        webController.addHybridAPI()
        let newWebController = WebViewController()
        let bridge = webController.bridge
        
        bridge.hybridAPI?.parentViewController = newWebController
        let navigation = bridge.context.evaluateScript("NativeBridge.navigation").toObject() as! Navigation
        
        XCTAssertEqual(navigation.parentViewController!, newWebController)
    }
    
    func testExportName() {
        XCTAssertEqual(HybridAPI.exportName, "NativeBridge")
    }
}
