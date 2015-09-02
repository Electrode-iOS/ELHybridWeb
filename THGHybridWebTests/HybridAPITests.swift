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
    
    func testAddHybridAPI() {
        let webController = WebViewController()
        webController.addBridgeAPIObject()
        
        let platform: AnyObject = webController.bridge.contextValueForName(HybridAPI.exportName).toObject()
        
        XCTAssert(platform is HybridAPI)
    }
    
    func testExportName() {
        XCTAssertEqual(HybridAPI.exportName, "NativeBridge")
    }
}
