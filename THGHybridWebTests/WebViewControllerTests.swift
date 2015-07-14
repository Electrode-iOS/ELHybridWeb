//
//  WebViewControllerTests.swift
//  THGHybridWeb
//
//  Created by Angelo Di Paolo on 5/12/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import UIKit
import XCTest
import THGHybridWeb

class WebViewControllerTests: XCTestCase {

    func testGetWebViewJavaScriptContext() {
        let webView = UIWebView(frame: CGRectZero)
        let context = webView.javaScriptContext
        XCTAssert(context != nil)
    }
}

// MARK: - Subclassing

class TestWebViewController: WebViewController {
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension WebViewControllerTests {
    
    func testSubclassInitialization() {
        let webViewController = TestWebViewController() // this should not even compile if initializers are defined improperly
        XCTAssertNotNil(webViewController)
    }
}
