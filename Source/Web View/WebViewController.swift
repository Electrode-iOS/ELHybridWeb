//
//  WebViewController.swift
//  THGHybridWeb
//
//  Created by Angelo Di Paolo on 4/16/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import Foundation
import JavaScriptCore
import THGBridge

/**
 Defines methods that a delegate of a WebViewController object can optionally 
 implement to interact with the web view's loading cycle.
*/
@objc public protocol WebViewControllerDelegate {
    optional func webViewController(webViewController: WebViewController, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool
    optional func webViewControllerDidStartLoad(webViewController: WebViewController)
    optional func webViewControllerDidFinishLoad(webViewController: WebViewController)
    optional func webViewController(webViewController: WebViewController, didFailLoadWithError error: NSError)
}

/**
 A view controller that integrates a web view with the hybrid JavaScript API.
*/
public class WebViewController: UIViewController {
    
    private(set) public var url: NSURL?
    private(set) public lazy var webView: UIWebView = {
        let webView =  UIWebView(frame: CGRectZero)
        webView.delegate = self
        return webView
    }()
    private(set) public var bridge = Bridge()
    private var hasAppeared = false
    private var showWebViewOnAppear = false
    public weak var delegate: WebViewControllerDelegate?

    private lazy var placeholderImageView: UIImageView = {
        return UIImageView(frame: self.view.bounds)
    }()
    
    var goBackInWebViewOnAppear = false
    
    public convenience init(webView: UIWebView, bridge: Bridge) {
        self.init(nibName: nil, bundle: nil)
        self.bridge = bridge
        self.webView = webView
        self.webView.delegate = self
    }
    
    deinit {
        if webView.delegate === self {
            webView.delegate = nil
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        edgesForExtendedLayout = .None
        view.addSubview(placeholderImageView)
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        bridge.hybridAPI?.parentViewController = self
        
        if goBackInWebViewOnAppear {
            goBackInWebViewOnAppear = false
            webView.goBack() // go back before remove/adding web view
        }
        
        webView.delegate = self
        webView.removeFromSuperview()
        webView.frame = view.bounds
        view.addSubview(webView)
        
        if !webView.loading {
            showWebViewOnAppear = true
        }
        
        view.disableDoubleTap()
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        hasAppeared = true
        
        if showWebViewOnAppear {
            webView.hidden = false
        }
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        placeholderImageView.frame = webView.frame // must align frames for image capture
        placeholderImageView.image = webView.captureImage()
        webView.hidden = true
    }
}

// MARK: - Request Loading

extension WebViewController {
    
    public func loadURL(url: NSURL) {
        let request = NSURLRequest(URL: url)
        webView.loadRequest(request)
    }
}

// MARK: - UIWebViewDelegate

extension WebViewController: UIWebViewDelegate {
    
    public func webViewDidStartLoad(webView: UIWebView) {
        delegate?.webViewControllerDidStartLoad?(self)
    }
    
    public func webViewDidFinishLoad(webView: UIWebView) {
        
        func attemptToShowWebView() {
            if hasAppeared {
                webView.hidden = false
            } else {
                // wait for viewDidAppear to show web view
                showWebViewOnAppear = true
            }
        }

        if !webView.loading {
            updateBridgeContext() // todo: listen for context changes
            attemptToShowWebView()
        }
        
        delegate?.webViewControllerDidFinishLoad?(self)
    }
    
    public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if pushesWebViewControllerForNavigationType(navigationType) {
            pushWebViewController()
        }
        
        return delegate?.webViewController?(self, shouldStartLoadWithRequest: request, navigationType: navigationType) ?? true
    }
    
    public func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        println("WebViewController Error: \(error)")
        delegate?.webViewController?(self, didFailLoadWithError: error)
    }
}

// MARK: - JavaScript Context

extension WebViewController {
    
    public func updateBridgeContext() {
        if let context = webView.javaScriptContext {
            configureBridgeContext(context)
        } else {
            println("Failed to retrieve JavaScript context from web view.")
        }
    }
    
    public func configureBridgeContext(context: JSContext) {
        bridge.context = context
        
        if let hybridAPI = bridge.hybridAPI {
            bridge.contextValueForName("nativeBridgeReady").callWithData(hybridAPI)
        }
    }
}

// MARK: - Web Controller Navigation

extension WebViewController {

    /**
     Call to push a new web view controller on the navigation stack using the
     existing web view instance.
    */
    public func pushWebViewController() {
        goBackInWebViewOnAppear = true
        
        let webViewController = WebViewController(webView: webView, bridge: bridge)
        navigationController?.pushViewController(webViewController, animated: true)
    }
    
    /**
     Return `true` to have the web view controller push a new web view controller
     on the stack for a given navigation type of a request.
    */
    public func pushesWebViewControllerForNavigationType(navigationType: UIWebViewNavigationType) -> Bool {
        return false
    }
}

// MARK: - UIView Utils

extension UIView {
    
    func captureImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, opaque, 0.0)
        layer.renderInContext(UIGraphicsGetCurrentContext())
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func disableDoubleTap() {
        for view in self.subviews {
            view.disableDoubleTap()
        }
        
        if let gestureRecognizers = gestureRecognizers {
            for gesture in gestureRecognizers {
                if let gesture = gesture as? UITapGestureRecognizer
                    where gesture.numberOfTapsRequired == 2 {
                    removeGestureRecognizer(gesture)
                }
            }
        }
    }
}
