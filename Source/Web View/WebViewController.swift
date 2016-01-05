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
    /**
     Sent before the web view begins loading a frame.
     - parameter webViewController: The web view controller loading the web view frame.
     - parameter request: The request that will load the frame.
     - parameter navigationType: The type of user action that started the load.
     - returns: Return true to
    */
    optional func webViewController(webViewController: WebViewController, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool
    
    /**
     Sent before the web view begins loading a frame.
     - parameter webViewController: The web view controller that has begun loading the frame.
    */
    optional func webViewControllerDidStartLoad(webViewController: WebViewController)
    
    /**
     Sent after the web view as finished loading a frame.
     - parameter webViewController: The web view controller that has completed loading the frame.
    */
    optional func webViewControllerDidFinishLoad(webViewController: WebViewController)
    
    /**
     Sent if the web view fails to load a frame.
     - parameter webViewController: The web view controller that failed to load the frame.
     - parameter error: The error that occured during loading.
    */
    optional func webViewController(webViewController: WebViewController, didFailLoadWithError error: NSError?)
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
    private var storedScreenshotGUID: String? = nil
    private var goBackInWebViewOnAppear = false
    private lazy var placeholderImageView: UIImageView = {
        return UIImageView(frame: self.view.bounds)
    }()
    
    public weak var delegate: WebViewControllerDelegate?
    
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
        
        view.removeDoubleTapGestures()

        // if we have a screenshot stored, load it.
        if let guid = storedScreenshotGUID {
            placeholderImageView.image = UIImage.loadImageFromGUID(guid)
            placeholderImageView.frame = view.bounds
            view.bringSubviewToFront(placeholderImageView)
        }
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        hasAppeared = true
        
        if showWebViewOnAppear {
            showWebView()
        }
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // we're going away, store the screen shot
        placeholderImageView.frame = webView.frame // must align frames for image capture
        
        if let screenshotImage = webView.captureImage() {
            placeholderImageView.image = screenshotImage
            storedScreenshotGUID = screenshotImage.saveImageToGUID()
        }
        
        view.bringSubviewToFront(placeholderImageView)
        webView.hidden = true
    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // we're gone.  dump the screenshot, we'll load it later if we need to.
        placeholderImageView.image = nil
    }
    
    private func showWebView() {
        // maybe delay this just a tad since loading is unpredictable??  I dunno.
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.webView.hidden = false
            self.placeholderImageView.image = nil
            self.view.sendSubviewToBack(self.placeholderImageView)
        }
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
                showWebView()
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
    
    public func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        print("WebViewController Error: \(error)")
        delegate?.webViewController?(self, didFailLoadWithError: error)
    }
}

// MARK: - JavaScript Context

extension WebViewController {
    
    public func updateBridgeContext() {
        if let context = webView.javaScriptContext {
            configureBridgeContext(context)
        } else {
            print("Failed to retrieve JavaScript context from web view.")
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
    
    func captureImage() -> UIImage? {
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        UIGraphicsBeginImageContextWithOptions(bounds.size, opaque, 0.0)
        layer.renderInContext(context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func removeDoubleTapGestures() {
        for view in self.subviews {
            view.removeDoubleTapGestures()
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

// MARK: - UIImage utils

extension UIImage {
    
    // saves image to temp directory and returns a GUID so you can fetch it later.
    func saveImageToGUID() -> String? {
        let guid = String.GUID()
        
        // do this shit in the background.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            if let imageData = UIImageJPEGRepresentation(self, 1.0),
                let filePath = UIImage.absoluteFilePath(guid: guid) {
                    NSFileManager.defaultManager().createFileAtPath(filePath, contents: imageData, attributes: nil)
            }
        }
        
        return guid
    }
    
    class func loadImageFromGUID(guid: String) -> UIImage? {
        guard let filePath = UIImage.absoluteFilePath(guid: guid) else { return nil }
        return UIImage(contentsOfFile: filePath)
    }
    
    private class func absoluteFilePath(guid guid: String) -> String? {
        return NSURL(string: NSTemporaryDirectory())?.URLByAppendingPathComponent(guid).absoluteString
    }
}
