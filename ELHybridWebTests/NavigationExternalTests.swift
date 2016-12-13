//
//  NavigationExternalTests.swift
//  ELHybridWeb
//
//  Created by Angelo Di Paolo on 8/24/15.
//  Copyright (c) 2015 WalmartLabs. All rights reserved.
//

import UIKit
import XCTest
import ELHybridWeb

class NavigationExternalTests: XCTestCase {
    static let optionJSON = [
        "title": "External Title",
        "url": "http://httpbin.org/",
        "returnURL": "http://httpbin.org/get"
    ]
    
    func testInitialization() {
        let options = ExternalNavigationOptions(options: NavigationExternalTests.optionJSON)
        
        XCTAssertTrue(options != nil)
        
        let originalURL = URL(string: NavigationExternalTests.optionJSON["url"]!)
        XCTAssertEqual(options!.url, originalURL!)
        
        let returnURL = URL(string: NavigationExternalTests.optionJSON["returnURL"]!)
        XCTAssertEqual(options!.returnURL!, returnURL!)
    }
    
    func testFailedInitialization() {
        let options = ExternalNavigationOptions(options: ["UrL" : "foo"])
        XCTAssertTrue(options == nil)

    }
}

extension ExternalNavigationOptions {
    
    static func testOptions() -> ExternalNavigationOptions? {
        return ExternalNavigationOptions(options: NavigationExternalTests.optionJSON)
    }
}
