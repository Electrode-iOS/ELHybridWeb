//
//  TabBarTests.swift
//  ELHybridWeb
//
//  Created by Angelo Di Paolo on 8/12/15.
//  Copyright (c) 2015 WalmartLabs. All rights reserved.
//

import UIKit
import XCTest
import JavaScriptCore
import ELHybridWeb

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
        let context = JSContext(virtualMachine: JSVirtualMachine())!
        context.setObject(api, forKeyedSubscript: HybridAPI.exportName as NSString)
        
        let tabBarObject: Any = context.evaluateScript("NativeBridge.tabBar").toObject()
        XCTAssert(tabBarObject is TabBar)
    }
    
    func testShow() {
        let webController = WebViewController()
        let api = HybridAPI(parentViewController: webController)
        let context = JSContext(virtualMachine: JSVirtualMachine())!
        context.setObject(api, forKeyedSubscript: HybridAPI.exportName as NSString)
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [webController]
        tabBarController.tabBar.isHidden = true
        
        XCTAssertTrue(tabBarController.tabBar.isHidden)
        api.tabBar.show()
        XCTAssertFalse(tabBarController.tabBar.isHidden)
    }
    
    func testHide() {
        let webController = WebViewController()
        let api = HybridAPI(parentViewController: webController)
        let context = JSContext(virtualMachine: JSVirtualMachine())!
        context.setObject(api, forKeyedSubscript: HybridAPI.exportName as NSString)
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [webController]
        
        XCTAssertFalse(tabBarController.tabBar.isHidden)
        api.tabBar.hide()
        XCTAssertTrue(tabBarController.tabBar.isHidden)
    }
}
