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

class WebViewControllerDelegateTests: XCTestCase, WebViewControllerDelegate {
    
    var didStartLoadExpectation: XCTestExpectation?
    var didFinishLoadExpectation: XCTestExpectation?
    var shouldStartLoadExpectation: XCTestExpectation?
    var didFailLoadExpectation: XCTestExpectation?
    
    func testDelegateDidStartLoad() {
        let vc = WebViewController()
        vc.delegate = self
        
        didStartLoadExpectation = expectation(description: "did start load")
        vc.webViewDidStartLoad(UIWebView())
        
        waitForExpectations(timeout: 4.0, handler: nil)
    }
    
    func testDelegateDidFinishLoad() {
        let vc = WebViewController()
        vc.delegate = self
        
        didFinishLoadExpectation = expectation(description: "did finish load")
        vc.webViewDidFinishLoad(UIWebView())
        
        waitForExpectations(timeout: 4.0, handler: nil)
    }
    
    func testDelegateShouldStartLoad() {
        let request = URLRequest(url: NSURL(string: "")! as URL)
        let vc = WebViewController()
        vc.delegate = self
        shouldStartLoadExpectation = expectation(description: "should start load")

        let _ = vc.webView(UIWebView(), shouldStartLoadWith: request, navigationType: .reload)
        
        waitForExpectations(timeout: 4.0, handler: nil)

    }
    
    // MARK: WebViewControllerDelegate
    
    func webViewControllerDidStartLoad(_ webViewController: WebViewController) {
        didStartLoadExpectation?.fulfill()
    }
    
    func webViewControllerDidFinishLoad(_ webViewController: WebViewController) {
        didFinishLoadExpectation?.fulfill()
    }
    
    func webViewController(_ webViewController: WebViewController, shouldStartLoadWithRequest request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        shouldStartLoadExpectation?.fulfill()
        return true
    }
    
    func webViewController(_ webViewController: WebViewController, didFailLoadWithError error: Error) {
        didFailLoadExpectation?.fulfill()
    }
}
