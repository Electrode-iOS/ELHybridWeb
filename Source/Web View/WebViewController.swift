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
     :param: webViewController The web view controller loading the web view frame.
     :param: request The request that will load the frame.
     :param: navigationType The type of user action that started the load.
     :returns: Return true to
    */
    optional func webViewController(webViewController: WebViewController, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool
    
    /**
     Sent before the web view begins loading a frame.
     :param: webViewController The web view controller that has begun loading the frame.
    */
    optional func webViewControllerDidStartLoad(webViewController: WebViewController)
    
    /**
     Sent after the web view as finished loading a frame.
     :param: webViewController The web view controller that has completed loading the frame.
    */
    optional func webViewControllerDidFinishLoad(webViewController: WebViewController)
    
    /**
     Sent if the web view fails to load a frame.
     :param: webViewController The web view controller that failed to load the frame.
     :param: error The error that occured during loading.
    */
    optional func webViewController(webViewController: WebViewController, didFailLoadWithError error: NSError)
}

/**
 A view controller that integrates a web view with the hybrid JavaScript API.
 
 # Usage
 
 Initialize a web view controller and call `loadURL()` to asynchronously load 
 the web view with a URL.

 ```
 let webController = WebViewController()
 webController.loadURL(NSURL(string: "foo")!)
 window?.rootViewController = webController
 ```

 Call `addHybridAPI()` to add the bridged JavaScript API to the web view. 
 The JavaScript API will be accessible to any web pages that are loaded in the 
 web view controller.

 ```
 let webController = WebViewController()
 webController.addHybridAPI()
 webController.loadURL(NSURL(string: "foo")!)
 window?.rootViewController = webController
 ```

 To utilize the navigation JavaScript API you must provide a navigation 
 controller for the web view controller.

 ```
 let webController = WebViewController()
 webController.addHybridAPI()
 webController.loadURL(NSURL(string: "foo")!)

 let navigationController = UINavigationController(rootViewController: webController)
 window?.rootViewController = navigationController
 ```

*/
public class WebViewController: UIViewController {
    
    /// The URL that was loaded with `loadURL()`
    private(set) public var url: NSURL?
    
    /// The web view used to load and render the web content.
    private(set) public lazy var webView: UIWebView = {
        let webView =  UIWebView(frame: CGRectZero)
        webView.delegate = self
        return webView
    }()
    
    /// JavaScript bridge for the web view's JSContext
    private(set) public var bridge = Bridge()
    private var hasAppeared = false
    private var showWebViewOnAppear = false
    private var storedScreenshotGUID: String? = nil
    private var goBackInWebViewOnAppear = false
    private var firstLoadCycleCompleted = true
    private lazy var placeholderImageView: UIImageView = {
        return UIImageView(frame: self.view.bounds)
    }()
    private var errorView: UIView?
    private var errorLabel: UILabel?
    private var reloadButton: UIButton?
    
    /// Handles web view controller events.
    public weak var delegate: WebViewControllerDelegate?
    
    /// Set `false` to disable error message UI.
    public var showErrorDisplay = true
    
    /**
     Initialize a web view controller instance with a web view and JavaScript 
      bridge. The newly initialized web view controller becomes the delegate of
      the web view.
     :param: webView The web view to use in the web view controller.
     :param: bridge The bridge instance to integrate int
    */
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
        
        if !webView.loading || firstLoadCycleCompleted {
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
        let image = webView.captureImage()
        placeholderImageView.image = image
        storedScreenshotGUID = image.saveImageToGUID()
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
    
    /**
     Load the web view with the provided URL.
     :param: url The URL used to load the web view.
    */
    final public func loadURL(url: NSURL) {
        self.url = url
        firstLoadCycleCompleted = false
        let request = NSURLRequest(URL: url)
        webView.loadRequest(request)
    }
}

// MARK: - UIWebViewDelegate

extension WebViewController: UIWebViewDelegate {
    
    final public func webViewDidStartLoad(webView: UIWebView) {
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
            firstLoadCycleCompleted = true
            updateBridgeContext() // todo: listen for context changes
            attemptToShowWebView()
        }
        
        delegate?.webViewControllerDidFinishLoad?(self)
    }
    
    final public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if pushesWebViewControllerForNavigationType(navigationType) {
            pushWebViewController()
        }
        
        return delegate?.webViewController?(self, shouldStartLoadWithRequest: request, navigationType: navigationType) ?? true
    }
    
    final public func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        
        if showErrorDisplay {
            renderFeatureErrorDisplayWithError(error, featureName: featureNameForError(error))
        }
        
        delegate?.webViewController?(self, didFailLoadWithError: error)
    }
}

// MARK: - JavaScript Context

extension WebViewController {
    
    /**
     Update the bridge's JavaScript context by attempting to retrieve a context
     from the web view.
    */
    final public func updateBridgeContext() {
        if let context = webView.javaScriptContext {
            configureBridgeContext(context)
        } else {
            println("Failed to retrieve JavaScript context from web view.")
        }
    }
    
    /**
     Explictly set the bridge's JavaScript context.
    */
    final public func configureBridgeContext(context: JSContext) {
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
     Call to present a navigation controller containing a new web view controller
     as the root view controller. The existing web view instance is reused.
    */
    public func presentModalWebViewController() {
        goBackInWebViewOnAppear = false
        
        let navigationController = UINavigationController(rootViewController: WebViewController(webView: webView, bridge: bridge))
        
        if let tabBarController = tabBarController {
            tabBarController.presentViewController(navigationController, animated: true, completion: nil)
        } else {
            presentViewController(navigationController, animated: true, completion: nil)
        }
        
    }
    
    /// Pops until there's only a single view controller left on the navigation stack.
    public func popToRootWebViewController() {
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    /**
     Return `true` to have the web view controller push a new web view controller
     on the stack for a given navigation type of a request.
    */
    public func pushesWebViewControllerForNavigationType(navigationType: UIWebViewNavigationType) -> Bool {
        return false
    }
}

// MARK: - Error UI

extension WebViewController {
    
    private func createErrorLabel() -> UILabel? {
        let height = CGFloat(50)
        let y = CGRectGetMidY(view.bounds) - (height / 2) - 100
        var label = UILabel(frame: CGRectMake(0, y, CGRectGetWidth(view.bounds), height))
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.Center
        label.backgroundColor = view.backgroundColor
        label.font = UIFont.systemFontOfSize(12, weight: 2)
        return label
    }
    
    private func createReloadButton() -> UIButton? {
        if let button = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton {
            let size = CGSizeMake(170, 38)
            let x = CGRectGetMidX(view.bounds) - (size.width / 2)
            var y = CGRectGetMidY(view.bounds) - (size.height / 2)
            
            if let label = errorLabel {
                y = CGRectGetMaxY(label.frame) + 20
            }
            
            button.setTitle(NSLocalizedString("Try again", comment: "Try again"), forState: UIControlState.Normal)
            button.frame = CGRectMake(x, y, size.width, size.height)
            button.backgroundColor = UIColor.lightGrayColor()
            button.titleLabel?.backgroundColor = UIColor.lightGrayColor()
            button.titleLabel?.textColor = UIColor.whiteColor()
            
            return button
        }
        
        return nil
    }
}

// MARK: - Error Display Events

extension WebViewController {
    
    /// Override to completely customize error display. Must also override `removeErrorDisplay`
     public func renderErrorDisplayWithError(error: NSError, message: String) {
        let errorView = UIView(frame: view.bounds)
        view.addSubview(errorView)
        self.errorView = errorView
        
        self.errorLabel = createErrorLabel()
        self.reloadButton = createReloadButton()
        
        if let errorLabel = errorLabel {
            errorLabel.text = NSLocalizedString(message, comment: "Web View Load Error")
            errorView.addSubview(errorLabel)
        }
        
        if let button = reloadButton {
            button.addTarget(self, action: "reloadButtonTapped:", forControlEvents: .TouchUpInside)
            errorView.addSubview(button)
        }
    }
    
    /// Override to handle custom error display removal.
    public func removeErrorDisplay() {
        errorView?.removeFromSuperview()
        errorView = nil
    }
   
    /// Override to customize the feature name that appears in the error display.
    public func featureNameForError(error: NSError) -> String {
        return "This feature"
    }
    
    /// Override to customize the error message text.
    public func renderFeatureErrorDisplayWithError(error: NSError, featureName: String) {
        let message = "Sorry!\n \(featureName) isn't working right now."
        renderErrorDisplayWithError(error, message: message)
    }
    
    /// Removes the error display and attempts to reload the web view.
    public func reloadButtonTapped(sender: AnyObject) {
        removeErrorDisplay()
        map(url) {self.loadURL($0)}
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
            let data = UIImageJPEGRepresentation(self, 1.0)
            if let data = data {
                let fileManager = NSFileManager.defaultManager()
                
                let fullPath = NSTemporaryDirectory().stringByAppendingPathComponent(guid)
                fileManager.createFileAtPath(fullPath, contents: data, attributes: nil)
            }
        }
        
        return guid
    }
    
    class func loadImageFromGUID(guid: String?) -> UIImage? {
        if let guid = guid {
            let fileManager = NSFileManager.defaultManager()
            let fullPath = NSTemporaryDirectory().stringByAppendingPathComponent(guid)
            let image = UIImage(contentsOfFile: fullPath)
            return image
        }
        return nil
    }
}
