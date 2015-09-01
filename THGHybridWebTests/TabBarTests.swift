//
//  TabBarTests.swift
//  THGHybridWeb
//
//  Created by Angelo Di Paolo on 8/12/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import UIKit
import XCTest
import JavaScriptCore
import THGHybridWeb

class TabBarTests: XCTestCase {

    func testParentViewControllerChange() {
        let webController = WebViewController()
        let api = HybridAPI(parentViewController: webController)
        let newWebViewController = WebViewController()
        api.parentViewController = newWebViewController
        
        XCTAssertNotNil(api.tabBar.parentViewController)
        XCTAssertEqual(api.tabBar.parentViewController!, newWebViewController)
    }
    
    func testExportName() {
        let api = HybridAPI(parentViewController: WebViewController())
        let context = JSContext(virtualMachine: JSVirtualMachine())
        context.setObject(api, forKeyedSubscript: HybridAPI.exportName)
        
        let tabBarObject: AnyObject = context.evaluateScript("NativeBridge.tabBar").toObject()
        XCTAssert(tabBarObject is TabBar)
    }
    
    func testShow() {
        let webController = WebViewController()
        let api = HybridAPI(parentViewController: webController)
        let context = JSContext(virtualMachine: JSVirtualMachine())
        context.setObject(api, forKeyedSubscript: HybridAPI.exportName)
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [webController]
        tabBarController.tabBar.hidden = true
        
        XCTAssertTrue(tabBarController.tabBar.hidden)
        api.tabBar.show()
        XCTAssertFalse(tabBarController.tabBar.hidden)
    }
    
    func testHide() {
        let webController = WebViewController()
        let api = HybridAPI(parentViewController: webController)
        let context = JSContext(virtualMachine: JSVirtualMachine())
        context.setObject(api, forKeyedSubscript: HybridAPI.exportName)
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [webController]
        
        XCTAssertFalse(tabBarController.tabBar.hidden)
        api.tabBar.hide()
        XCTAssertTrue(tabBarController.tabBar.hidden)
    }
}
