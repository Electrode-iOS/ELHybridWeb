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
        
        if let url = NSURL(string: "https://httpbin.org/") {
            didStartLoadExpectation = expectationWithDescription("did start load")
            
            vc.loadURL(url)
            
            waitForExpectationsWithTimeout(4.0, handler: nil)
        }
    }
    
    func testDelegateDidFinishLoad() {
        let vc = WebViewController()
        vc.delegate = self
        
        if let url = NSURL(string: "https://httpbin.org/") {
            didFinishLoadExpectation = expectationWithDescription("did finish load")
            
            vc.loadURL(url)
            waitForExpectationsWithTimeout(4.0, handler: nil)
        }
    }
    
    func testDelegateShouldStartLoad() {
        let vc = WebViewController()
        vc.delegate = self
        
        if let url = NSURL(string: "https://httpbin.org/") {
            shouldStartLoadExpectation = expectationWithDescription("should start load")
            
            vc.loadURL(url)
            waitForExpectationsWithTimeout(4.0, handler: nil)
        }
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
