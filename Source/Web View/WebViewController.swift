//
//  WebViewController.swift
//  THGHybridWeb
//
//  Created by Angelo Di Paolo on 4/16/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import Foundation
import JavaScriptCore
import UIKit
#if NOFRAMEWORKS
#else
import THGBridge
#endif

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
    
    /**
     Sent when the web view creates the JS context for the frame.
     :param: webViewController The web view controller that failed to load the frame.
     :param: context The newly created JavaScript context.
    */
    optional func webViewControllerDidCreateJavaScriptContext(webViewController: WebViewController, context: JSContext)
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
    
    enum AppearenceCause {
        case Unknown, WebPush, WebPop, WebModal, WebDismiss
    }
    
    /// The URL that was loaded with `loadURL()`
    private(set) public var url: NSURL?
    
    /// The web view used to load and render the web content.
    private(set) public lazy var webView: UIWebView = {
        let webView =  UIWebView(frame: CGRectZero)
        webView.delegate = self
        webViews.addObject(webView)
        return webView
    }()
    
    /// JavaScript bridge for the web view's JSContext
    private(set) public var bridge = Bridge()
    private var storedScreenshotGUID: String? = nil
    private var goBackInWebViewOnAppear = false
    private var firstLoadCycleCompleted = true
    private var disappearedBy = AppearenceCause.Unknown
    private var storedAppearence = AppearenceCause.WebPush
    private var appearedFrom: AppearenceCause {
        get {
            switch disappearedBy {
            case .WebPush: return .WebPop
            case .WebModal: return .WebDismiss
            default: return storedAppearence
            }
        }
        set {
            storedAppearence = newValue
        }
    }

    private lazy var placeholderImageView: UIImageView = {
        return UIImageView(frame: self.view.bounds)
    }()
    private var errorView: UIView?
    private var errorLabel: UILabel?
    private var reloadButton: UIButton?
    public weak var bridgeObject: HybridAPI?
    
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
    public required init(webView: UIWebView, bridge: Bridge) {
        super.init(nibName: nil, bundle: nil)
        
        self.bridge = bridge
        self.webView = webView
        self.webView.delegate = self
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        if webView.delegate === self {
            webView.delegate = nil
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        edgesForExtendedLayout = .None
        view.addSubview(placeholderImageView)
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        bridgeObject?.parentViewController = self
        
        switch appearedFrom {
            
        case .WebPush, .WebModal, .WebPop, .WebDismiss:
            if goBackInWebViewOnAppear {
                goBackInWebViewOnAppear = false
                webView.goBack() // go back before remove/adding web view
            }
            
            webView.delegate = self
            webView.removeFromSuperview()
            webView.frame = view.bounds
            view.addSubview(webView)
            
            view.removeDoubleTapGestures()
            
            // if we have a screenshot stored, load it.
            if let guid = storedScreenshotGUID {
                placeholderImageView.image = UIImage.loadImageFromGUID(guid)
                placeholderImageView.frame = view.bounds
                view.bringSubviewToFront(placeholderImageView)
            }
            
        case .Unknown: break
        }
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        bridgeObject?.view.appeared()
        
        switch appearedFrom {
            
        case .WebPop, .WebDismiss:
            showWebView()
            
        case .WebPush, .WebModal, .Unknown: break
        }
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        switch disappearedBy {
            
        case .WebPop, .WebDismiss, .WebPush, .WebModal:
            // only store screen shot when disappearing by web transition
            placeholderImageView.frame = webView.frame // must align frames for image capture
            let image = webView.captureImage()
            placeholderImageView.image = image
            storedScreenshotGUID = image.saveImageToGUID()
            view.bringSubviewToFront(placeholderImageView)
            
            webView.hidden = true
            
        case .Unknown: break

        }

        bridgeObject?.view.disappeared() // needs to be called in viewWillDisappear not Did
    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        switch disappearedBy {
            
        case .WebPop, .WebDismiss, .WebPush, .WebModal:
            // we're gone.  dump the screenshot, we'll load it later if we need to.
            placeholderImageView.image = nil
            
        case .Unknown:
            // we don't know how it will appear if we don't know how it disappeared
            appearedFrom = .Unknown
        }
    }
    
    public final func showWebView() {
        webView.hidden = false
        placeholderImageView.image = nil
        view.sendSubviewToBack(placeholderImageView)
    }
}

// MARK: - Request Loading

extension WebViewController {
    
    /**
     Load the web view with the provided URL.
     :param: url The URL used to load the web view.
    */
    final public func loadURL(url: NSURL) {
        webView.stopLoading()
        bridgeObject = nil
        firstLoadCycleCompleted = false

        self.url = url
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
        delegate?.webViewControllerDidFinishLoad?(self)
        
        if self.errorView != nil {
            self.removeErrorDisplay()
        }
    }
    
    final public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if pushesWebViewControllerForNavigationType(navigationType) {
            pushWebViewController()
        }
        
        return delegate?.webViewController?(self, shouldStartLoadWithRequest: request, navigationType: navigationType) ?? true
    }
    
    final public func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        
        if error.code != NSURLErrorCancelled {
            if showErrorDisplay {
                renderFeatureErrorDisplayWithError(error, featureName: featureNameForError(error))
            }
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
    
    private func didCreateJavaScriptContext(context: JSContext) {
        configureBridgeContext(context)
        delegate?.webViewControllerDidCreateJavaScriptContext?(self, context: context)
        configureContext(context)
        
        if let hybridAPI = bridgeObject {
            bridge.contextValueForName("nativeBridgeReady").callWithData(hybridAPI)
        }
    }
    
    /**
     Explictly set the bridge's JavaScript context.
    */
    final public func configureBridgeContext(context: JSContext) {
        bridge.context = context
    }
    
    public func configureContext(context: JSContext) {
        if let bridgeObject = bridgeObject {
            bridge.context.setObject(bridgeObject, forKeyedSubscript: HybridAPI.exportName)
        } else {
            let platform = HybridAPI(parentViewController: self)
            bridge.context.setObject(platform, forKeyedSubscript: HybridAPI.exportName)
            bridgeObject = platform
        }
    }
}

// MARK: - Web Controller Navigation

extension WebViewController {
    
    /**
     Push a new web view controller on the navigation stack using the existing
     web view instance. Does not affect web view history. Uses animation.
    */
    public func pushWebViewController() {
        pushWebViewController(hideBottomBar: false)
    }
    
    /**
     Push a new web view controller on the navigation stack using the existing
     web view instance. Does not affect web view history. Uses animation.
     :param: hideBottomBar Hides the bottom bar of the view controller when true.
    */
    public func pushWebViewController(#hideBottomBar: Bool) {
        goBackInWebViewOnAppear = true
        disappearedBy = .WebPush
        
        let webViewController = self.dynamicType(webView: webView, bridge: bridge)
        webViewController.bridgeObject = bridgeObject
        webViewController.appearedFrom = .WebPush
        webViewController.hidesBottomBarWhenPushed = hideBottomBar
        navigationController?.pushViewController(webViewController, animated: true)
    }
    
    /**
     Pop a web view controller off of the navigation. Does not affect
     web view history. Uses animation.
    */
    public func popWebViewController() {
        if let navController = self.navigationController
            where navController.viewControllers.count > 1 {
            (navController.viewControllers[navController.viewControllers.count - 1] as? WebViewController)?.goBackInWebViewOnAppear = false
            navController.popViewControllerAnimated(true)
        }
    }
    
    /**
     Present a navigation controller containing a new web view controller as the
     root view controller. The existing web view instance is reused.
    */
    public func presentModalWebViewController() {
        goBackInWebViewOnAppear = false
        disappearedBy = .WebModal
        
        let webViewController = self.dynamicType(webView: webView, bridge: bridge)
        webViewController.bridgeObject = bridgeObject
        webViewController.appearedFrom = .WebModal
        
        let navigationController = UINavigationController(rootViewController: webViewController)
        
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

// MARK: - JSContext Event

private var webViews = NSHashTable.weakObjectsHashTable()

private struct Statics {
    static var webViewOnceToken: dispatch_once_t = 0
}

extension NSObject {
    func webView(webView: AnyObject, didCreateJavaScriptContext context: JSContext, forFrame frame: AnyObject) {
        if let webFrameClass = NSClassFromString("WebFrame") {
            if !(frame.dynamicType === webFrameClass) {
                return
            }
        }
        
        if let allWebViews = webViews.allObjects as? [UIWebView] {
            for webView in allWebViews {
                webView.didCreateJavaScriptContext(context)
            }
        }
    }
}

extension UIWebView {
    func didCreateJavaScriptContext(context: JSContext) {
        (delegate as? WebViewController)?.didCreateJavaScriptContext(context)
    }
}
