//
//  WebViewController.swift
//  ELHybridWeb
//
//  Created by Angelo Di Paolo on 4/16/15.
//  Copyright (c) 2015 WalmartLabs. All rights reserved.
//

import Foundation
import JavaScriptCore
import UIKit
#if NOFRAMEWORKS
#else
import ELJSBridge
#endif

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

    /**
     Sent when the web view creates the JS context for the frame.
     parameter webViewController: The web view controller that failed to load the frame.
     parameter context: The newly created JavaScript context.
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

 Call `addBridgeAPIObject()` to add the bridged JavaScript API to the web view.
 The JavaScript API will be accessible to any web pages that are loaded in the 
 web view controller.

 ```
 let webController = WebViewController()
 webController.addBridgeAPIObject()
 webController.loadURL(NSURL(string: "foo")!)
 window?.rootViewController = webController
 ```

 To utilize the navigation JavaScript API you must provide a navigation 
 controller for the web view controller.

 ```
 let webController = WebViewController()
 webController.addBridgeAPIObject()
 webController.loadURL(NSURL(string: "foo")!)

 let navigationController = UINavigationController(rootViewController: webController)
 window?.rootViewController = navigationController
 ```
*/
public class WebViewController: UIViewController {
    
    public enum AppearenceCause {
        case Unknown, WebPush, WebPop, WebModal, WebDismiss, External
    }
    
    /// The URL that was loaded with `loadURL()`
    private(set) public var url: NSURL?
    
    /// The web view used to load and render the web content.
    private(set) public lazy var webView: UIWebView = {
        let webView =  UIWebView(frame: CGRectZero)
        webView.delegate = self
        WebViewManager.addBridgedWebView(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    /// JavaScript bridge for the web view's JSContext
    private(set) public var bridge = Bridge()
    private var storedScreenshotGUID: String? = nil
    private var firstLoadCycleCompleted = true
    private (set) var disappearedBy = AppearenceCause.Unknown
    private var storedAppearence = AppearenceCause.WebPush
    // TODO: make appearedFrom internal in Swift 2 with @testable
    private (set) public var appearedFrom: AppearenceCause {
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
    public var errorView: UIView?
    public var errorLabel: UILabel?
    public var reloadButton: UIButton?
    public weak var hybridAPI: HybridAPI?
    private (set) weak var externalPresentingWebViewController: WebViewController?
    private(set) public var externalReturnURL: NSURL?
    
    /// Handles web view controller events.
    public weak var delegate: WebViewControllerDelegate?
    
    /// Set `false` to disable error message UI.
    public var showErrorDisplay = true

    /// An optional custom user agent string to be used in the header when loading the URL.
    public var userAgent: String?

    /// Host for NSURLSessionDelegate challenge
    public var challengeHost: String?

    lazy public var urlSession: NSURLSession = {
            let configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
            if let agent = self.userAgent {
                configuration.HTTPAdditionalHeaders = [
                    "User-Agent": agent
                ]
            }
            let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
            return session
    }()

    /// A NSURLSessionDataTask object used to load the URLs
    public var dataTask: NSURLSessionDataTask?

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

    public required init?(coder aDecoder: NSCoder) {
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
                
        switch appearedFrom {
            
        case .WebPush, .WebModal, .WebPop, .WebDismiss, .External:
            webView.delegate = self
            webView.removeFromSuperview() // remove webView from previous view controller's view
            webView.frame = view.bounds
            view.addSubview(webView) // add webView to this view controller's view
            // Pin web view top and bottom to top and bottom of view
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[webView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["webView" : webView]))
            // Pin web view sides to sides of view
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[webView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["webView" : webView]))
            view.removeDoubleTapGestures()
            if let storedScreenshotGUID = storedScreenshotGUID {
                placeholderImageView.image = UIImage.loadImageFromGUID(storedScreenshotGUID)
                view.bringSubviewToFront(placeholderImageView)
            }
        case .Unknown: break
        }
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        hybridAPI?.view.appeared()
        
        switch appearedFrom {
        
        case .WebPop, .WebDismiss: addBridgeAPIObject()
            
        case .WebPush, .WebModal, .External, .Unknown: break
        }
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        switch disappearedBy {
            
        case .WebPop, .WebDismiss, .WebPush, .WebModal:
            // only store screen shot when disappearing by web transition
            placeholderImageView.frame = webView.frame // must align frames for image capture
            
            if let screenshotImage = webView.captureImage() {
                placeholderImageView.image = screenshotImage
                storedScreenshotGUID = screenshotImage.saveImageToGUID()
            }

            view.bringSubviewToFront(placeholderImageView)
            
            webView.hidden = true
            
        case .Unknown:
            if isMovingFromParentViewController() {
                webView.hidden = true
            }
        case .External: break
        }

        if disappearedBy != .WebPop && isMovingFromParentViewController() {
            hybridAPI?.navigation.back()
        }

        hybridAPI?.view.disappeared() // needs to be called in viewWillDisappear not Did

        switch disappearedBy {
        // clear out parent reference to prevent the popping view's onAppear from
        // showing the web view too early
        case .WebPop, .Unknown where isMovingFromParentViewController():
            hybridAPI?.parentViewController = nil
        default: break
        }
    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        switch disappearedBy {
            
        case .WebPop, .WebDismiss, .WebPush, .WebModal, .External:
            // we're gone.  dump the screenshot, we'll load it later if we need to.
            placeholderImageView.image = nil
            
        case .Unknown:
            // we don't know how it will appear if we don't know how it disappeared
            appearedFrom = .Unknown
        }
    }
    
    public final func showWebView() {
        self.webView.hidden = false
        self.placeholderImageView.image = nil
        self.view.sendSubviewToBack(self.placeholderImageView)
    }
}

// MARK: - Request Loading

extension WebViewController {
    
    /**
     Load the web view with the provided URL.
     :param: url The URL used to load the web view.
    */
    final public func loadURL(url: NSURL) {
        self.dataTask?.cancel() // cancel any running task
        hybridAPI = nil
        firstLoadCycleCompleted = false

        self.url = url
        let request = requestWithURL(url)

        self.dataTask = self.urlSession.dataTaskWithRequest(request) { (data, response, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let httpError = error {
                    // render error display
                    if self.showErrorDisplay {
                        self.renderFeatureErrorDisplayWithError(httpError, featureName: self.featureNameForError(httpError))
                    }
                } else if let urlResponse = response as? NSHTTPURLResponse {
                    if urlResponse.statusCode >= 400 {
                        // render error display
                        if self.showErrorDisplay {
                            let httpError = NSError(domain: "WebViewController", code: urlResponse.statusCode, userInfo: ["response" : urlResponse, NSLocalizedDescriptionKey : "HTTP Response Status \(urlResponse.statusCode)"])
                            self.renderFeatureErrorDisplayWithError(httpError, featureName: self.featureNameForError(httpError))
                        }
                    } else if let data = data,
                        MIMEType = urlResponse.MIMEType,
                        textEncodingName = urlResponse.textEncodingName,
                        url = urlResponse.URL {
                        self.webView.loadData(data, MIMEType: MIMEType, textEncodingName: textEncodingName, baseURL: url)
                    }
                }
            })
        }
        self.dataTask?.resume()
    }
    
    /**
     Create a request with the provided URL.
     :param: url The URL for the request.
    */
    public func requestWithURL(url: NSURL) -> NSURLRequest {
        return NSURLRequest(URL: url)
    }
    
    private func didInterceptRequest(request: NSURLRequest) -> Bool {
        if appearedFrom == .External {
            // intercept requests that match external return URL
            if let url = request.URL where shouldInterceptExternalURL(url) {
                returnFromExternalWithReturnURL(url)
                return true
            }
        }
        
        return false
    }

}

// MARK: - NSURLSessionDelegate

extension WebViewController: NSURLSessionDelegate {
    
    public func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let host = challengeHost,
                let serverTrust = challenge.protectionSpace.serverTrust
                where challenge.protectionSpace.host == host {
                    let credential = NSURLCredential(forTrust: serverTrust)
                    completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, credential)
            } else {
                completionHandler(NSURLSessionAuthChallengeDisposition.PerformDefaultHandling, nil)
            }
        }
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
        
        if didInterceptRequest(request) {
            return false
        } else {
            return delegate?.webViewController?(self, shouldStartLoadWithRequest: request, navigationType: navigationType) ?? true
        }
    }
    
    final public func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        if let error = error where error.code != NSURLErrorCancelled && showErrorDisplay {
            renderFeatureErrorDisplayWithError(error, featureName: featureNameForError(error))
        }

        delegate?.webViewController?(self, didFailLoadWithError: error)
    }
}

// MARK: - JavaScript Context

extension WebViewController: WebViewBridging {
    
    /**
     Update the bridge's JavaScript context by attempting to retrieve a context
     from the web view.
    */
    final public func updateBridgeContext() {
        if let context = webView.javaScriptContext {
            configureBridgeContext(context)
        } else {
            print("Failed to retrieve JavaScript context from web view.")
        }
    }
    
    public func didCreateJavaScriptContext(context: JSContext) {
        configureBridgeContext(context)
        delegate?.webViewControllerDidCreateJavaScriptContext?(self, context: context)
        configureContext(context)
        
        if let hybridAPI = hybridAPI {
            let readyCallback = bridge.contextValueForName("nativeBridgeReady")
            
            if !readyCallback.isUndefined {
                readyCallback.callWithData(hybridAPI)
            }
        }
    }
    
    /**
     Explictly set the bridge's JavaScript context.
    */
    final public func configureBridgeContext(context: JSContext) {
        bridge.context = context
    }
    
    public func configureContext(context: JSContext) {
        addBridgeAPIObject()
    }
}

// MARK: - Web Controller Navigation

public extension WebViewController {
    
    /**
     Push a new web view controller on the navigation stack using the existing
     web view instance. Does not affect web view history. Uses animation.
    */
    public func pushWebViewController() {
        pushWebViewControllerWithOptions(nil)
    }
    
    /**
     Push a new web view controller on the navigation stack using the existing
     web view instance. Does not affect web view history. Uses animation.
     :param: hideBottomBar Hides the bottom bar of the view controller when true.
    */
    public func pushWebViewControllerWithOptions(options: WebViewControllerOptions?) {
        disappearedBy = .WebPush
        
        let webViewController = newWebViewControllerWithOptions(options)
        webViewController.appearedFrom = .WebPush
        
        navigationController?.pushViewController(webViewController, animated: true)
    }
    
    /**
     Pop a web view controller off of the navigation. Does not affect
     web view history. Uses animation.
    */
    public func popWebViewController() {
        disappearedBy = .WebPop

        if let navController = self.navigationController
            where navController.viewControllers.count > 1 {
                navController.popViewControllerAnimated(true)
        }
    }
    
    /**
     Present a navigation controller containing a new web view controller as the
     root view controller. The existing web view instance is reused.
    */
    public func presentModalWebViewController(options: WebViewControllerOptions?) {
        disappearedBy = .WebModal
        
        let webViewController = newWebViewControllerWithOptions(options)
        webViewController.appearedFrom = .WebModal
        
        let navigationController = UINavigationController(rootViewController: webViewController)
        
        if let tabBarController = tabBarController {
            tabBarController.presentViewController(navigationController, animated: true, completion: nil)
        } else {
            presentViewController(navigationController, animated: true, completion: nil)
        }
    }
    
    /// Pops until there's only a single view controller left on the navigation stack.
    public func popToRootWebViewController(animated: Bool) {
        disappearedBy = .WebPop
        navigationController?.popToRootViewControllerAnimated(animated)
    }
    
    /**
     Return `true` to have the web view controller push a new web view controller
     on the stack for a given navigation type of a request.
    */
    public func pushesWebViewControllerForNavigationType(navigationType: UIWebViewNavigationType) -> Bool {
        return false
    }
    
    public func newWebViewControllerWithOptions(options: WebViewControllerOptions?) -> WebViewController {
        let webViewController = self.dynamicType.init(webView: webView, bridge: bridge)
        webViewController.addBridgeAPIObject()
        webViewController.hybridAPI?.navigationBar.title = options?.title
        webViewController.hidesBottomBarWhenPushed = options?.tabBarHidden ?? false
        webViewController.hybridAPI?.view.onAppearCallback = options?.onAppearCallback?.asValidValue
        
        if let navigationBarButtons = options?.navigationBarButtons {
            webViewController.hybridAPI?.navigationBar.configureButtons(navigationBarButtons, callback: options?.navigationBarButtonCallback)
        }
        
        return webViewController
    }
}

// MARK: - External Navigation

extension WebViewController {
    
    final var shouldDismissExternalURLModal: Bool {
        return !webView.canGoBack
    }
    
    final func shouldInterceptExternalURL(url: NSURL) -> Bool {
        if let requestedURLString = url.absoluteStringWithoutQuery,
            let returnURLString = externalReturnURL?.absoluteStringWithoutQuery
            where requestedURLString.rangeOfString(returnURLString) != nil {
                return true
        }
        
        return false
    }
    
    // TODO: make internal after migrating to Swift 2 and @testable
    final public func presentExternalURLWithOptions(options: ExternalNavigationOptions) -> WebViewController{
        let externalWebViewController = self.dynamicType.init()
        externalWebViewController.externalPresentingWebViewController = self
        externalWebViewController.addBridgeAPIObject()
        externalWebViewController.loadURL(options.url)
        externalWebViewController.appearedFrom = .External
        externalWebViewController.externalReturnURL = options.returnURL
        externalWebViewController.title = options.title
        
        let backText = NSLocalizedString("Back", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: "")
        externalWebViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: backText, style: .Plain, target: externalWebViewController, action: "externalBackButtonTapped")
        
        let doneText = NSLocalizedString("Done", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: "")
        externalWebViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: doneText, style: .Done, target: externalWebViewController, action: "dismissExternalURL")
        
        let navigationController = UINavigationController(rootViewController: externalWebViewController)
        presentViewController(navigationController, animated: true, completion: nil)
        return externalWebViewController
    }
    
    final func externalBackButtonTapped() {
        if shouldDismissExternalURLModal {
            externalPresentingWebViewController?.showWebView()
            dismissExternalURL()
        }
        
        webView.goBack()
    }
    
    final func returnFromExternalWithReturnURL(url: NSURL) {
        externalPresentingWebViewController?.loadURL(url)
        dismissExternalURL()
    }
    
    final func dismissExternalURL() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - Error UI

extension WebViewController {
    
    private func createErrorLabel() -> UILabel? {
        let height = CGFloat(50)
        let y = CGRectGetMidY(view.bounds) - (height / 2) - 100
        let label = UILabel(frame: CGRectMake(0, y, CGRectGetWidth(view.bounds), height))
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.Center
        label.backgroundColor = view.backgroundColor
        label.font = UIFont.boldSystemFontOfSize(12)
        return label
    }
    
    private func createReloadButton() -> UIButton? {
        let button = UIButton(type: .Custom)
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
        showWebView()
    }
   
    /// Override to customize the feature name that appears in the error display.
    public func featureNameForError(error: NSError) -> String {
        return "This feature"
    }
    
    /// Override to customize the error message text.
    public func renderFeatureErrorDisplayWithError(error: NSError, featureName: String) {
        let message = "Sorry!\n \(featureName) isn't working right now."
        webView.hidden = true
        renderErrorDisplayWithError(error, message: message)
    }
    
    /// Removes the error display and attempts to reload the web view.
    public func reloadButtonTapped(sender: AnyObject) {
        guard let url = url else { return }
        loadURL(url)
    }
}

// MARK: - Bridge API

extension WebViewController {
    
    public func addBridgeAPIObject() {
        if let bridgeObject = hybridAPI {
            bridge.context.setObject(bridgeObject, forKeyedSubscript: HybridAPI.exportName)
        } else {
            let platform = HybridAPI(parentViewController: self)
            bridge.context.setObject(platform, forKeyedSubscript: HybridAPI.exportName)
            hybridAPI = platform
        }
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

// MARK: - JSContext Event

private struct Statics {
    static var webViewOnceToken: dispatch_once_t = 0
}

@objc(WebViewBridging)
public protocol WebViewBridging {
    func didCreateJavaScriptContext(context: JSContext)
}

private var globalWebViews = NSHashTable.weakObjectsHashTable()

@objc(WebViewManager)
public class WebViewManager: NSObject {
    // globalWebViews is a weak hash table.  No need to remove items.
    @objc static public func addBridgedWebView(webView: UIWebView?) {
        if let webView = webView {
            globalWebViews.addObject(webView)
        }
    }
}

public extension NSObject {
    
    private struct AssociatedKeys {
        static var uniqueIDKey = "nsobject_uniqueID"
    }
    
    @objc
    var uniqueWebViewID: String! {
        if let currentValue = objc_getAssociatedObject(self, &AssociatedKeys.uniqueIDKey) as? String {
            return currentValue
        } else {
            let newValue = NSUUID().UUIDString
            objc_setAssociatedObject(self, &AssociatedKeys.uniqueIDKey, newValue as NSString?, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return newValue
        }
    }
    
    func webView(webView: AnyObject, didCreateJavaScriptContext context: JSContext, forFrame frame: AnyObject) {
        let notifyWebviews = { () -> Void in
            if let allWebViews = globalWebViews.allObjects as? [UIWebView] {
                for webView in allWebViews {
                    let cookie = "__thgWebviewCookie\(webView.hash)"
                    let js = "var \(cookie) = '\(cookie)'"
                    webView.stringByEvaluatingJavaScriptFromString(js)
                    
                    let contextCookie = context.objectForKeyedSubscript(cookie).toString()
                    if contextCookie == cookie {
                        if let bridgingDelegate = webView.delegate as? WebViewBridging {
                            bridgingDelegate.didCreateJavaScriptContext(context)
                        }
                    }
                }
            }
        }
        
        let webFrameClass1: AnyClass! = NSClassFromString("WebFrame") // Most web-views
        let webFrameClass2: AnyClass! = NSClassFromString("NSKVONotifying_WebFrame") // Objc webviews accessed via swift
        
        if (frame.dynamicType === webFrameClass1) || (frame.dynamicType === webFrameClass2) {
            if NSThread.isMainThread() {
                notifyWebviews()
            } else {
                dispatch_async(dispatch_get_main_queue(), notifyWebviews)
            }
        }
    }
}

extension NSURL {
    /// Get the absolute URL string value without the query string.
    var absoluteStringWithoutQuery: String? {
        let components = NSURLComponents(URL: self, resolvingAgainstBaseURL: false)
        components?.query = nil
        // TODO: if we ever drop iOS 7 support make this return `components?.string` instead.
        // would also be great to upgrade to Swift 2's availability API to conditionally call each supported method
        return components?.URL?.absoluteString
    }
}
