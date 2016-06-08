//
//  WebViewControllerDelegateTests.swift
//  ELHybridWeb
//
//  Created by Angelo Di Paolo on 5/20/15.
//  Copyright (c) 2015 WalmartLabs. All rights reserved.
//

import UIKit
import XCTest
import ELHybridWeb
import ELJSBridge

class WebViewControllerDelegateTests: XCTestCase, WebViewControllerDelegate {
    
    var didStartLoadExpectation: XCTestExpectation?
    var didFinishLoadExpectation: XCTestExpectation?
    var shouldStartLoadExpectation: XCTestExpectation?
    var didFailLoadExpectation: XCTestExpectation?
    
    func testDelegateDidStartLoad() {
        let vc = WebViewController()
        vc.delegate = self
        
        didStartLoadExpectation = expectationWithDescription("did start load")
        vc.webViewDidStartLoad(UIWebView())
        
        waitForExpectationsWithTimeout(4.0, handler: nil)
    }
    
    func testDelegateDidFinishLoad() {
        let vc = WebViewController()
        vc.delegate = self
        
        didFinishLoadExpectation = expectationWithDescription("did finish load")
        vc.webViewDidFinishLoad(UIWebView())
        
        waitForExpectationsWithTimeout(4.0, handler: nil)
    }
    
    func testDelegateShouldStartLoad() {
        let request = NSURLRequest(URL: NSURL(string: "")!)
        let vc = WebViewController()
        vc.delegate = self
        
        shouldStartLoadExpectation = expectationWithDescription("should start load")
        vc.webView(UIWebView(), shouldStartLoadWithRequest: request, navigationType: .Reload)
        
        waitForExpectationsWithTimeout(4.0, handler: nil)

    }
    
    // MARK: WebViewControllerDelegate
    
    func webViewControllerDidStartLoad(webViewController: WebViewController) {
        didStartLoadExpectation?.fulfill()
    }
    
    func webViewControllerDidFinishLoad(webViewController: WebViewController) {
        didFinishLoadExpectation?.fulfill()
    }
    
    func webViewController(webViewController: WebViewController, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        shouldStartLoadExpectation?.fulfill()
        return true
    }
    
    func webViewController(webViewController: WebViewController, didFailLoadWithError error: NSError?) {
        didFailLoadExpectation?.fulfill()
    }
}
