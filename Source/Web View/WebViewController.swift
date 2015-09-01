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
        case Unknown, WebPush, WebPop, WebModal, WebDismiss, External
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
    private var firstLoadCycleCompleted = true
    private (set) var disappearedBy = AppearenceCause.Unknown
    private var storedAppearence = AppearenceCause.WebPush
    private (set) var appearedFrom: AppearenceCause {
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
    var errorView: UIView?
    var errorLabel: UILabel?
    var reloadButton: UIButton?
    public weak var hybridAPI: HybridAPI?
    private (set) weak var externalPresentingWebViewController: WebViewController?
    private var externalReturnURL: NSURL?
    
    /// Handles web view controller events.
    public weak var delegate: WebViewControllerDelegate?
    
    /// Set `false` to disable error message UI.
    public var showErrorDisplay = true

    public var userAgent: String?

    lazy var urlSession: NSURLSession = {
            let configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
            if let agent = self.userAgent {
                configuration.HTTPAdditionalHeaders = [
                    "User-Agent": agent
                ]
            }
            let session = NSURLSession(configuration: configuration)
            return session
    }()

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
                
        switch appearedFrom {
            
        case .WebPush, .WebModal, .WebPop, .WebDismiss, .External:
            webView.delegate = self
            webView.removeFromSuperview()
            webView.frame = view.bounds
            view.addSubview(webView)
            
            view.removeDoubleTapGestures()
            
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
            let image = webView.captureImage()
            placeholderImageView.image = image
            storedScreenshotGUID = image.saveImageToGUID()
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
        hybridAPI = nil
        firstLoadCycleCompleted = false

        self.url = url
        let request = requestWithURL(url)

        let dataTask: NSURLSessionDataTask = self.urlSession.dataTaskWithRequest(request) { (data, response, error) -> Void in
            if let urlResponse = response as? NSHTTPURLResponse {
                if (urlResponse.statusCode >= 400) || (error != nil) {
                    // handle error condition
                    var httpError = error
                    if httpError == nil {
                        httpError = NSError(domain: "WebViewController", code: urlResponse.statusCode, userInfo: ["response" : urlResponse, NSLocalizedDescriptionKey : "HTTP Response Status \(urlResponse.statusCode)"])
                    }
                    if self.showErrorDisplay {
                        self.renderFeatureErrorDisplayWithError(httpError, featureName: self.featureNameForError(httpError))
                    }
                }
                else {
                    self.webView.loadData(data, MIMEType: response.MIMEType, textEncodingName: response.textEncodingName, baseURL: response.URL)
                }
            }
            else {
                if self.showErrorDisplay {
                    var httpError = error
                    if httpError == nil {
                        httpError = NSError(domain: "WebViewController", code: -1, userInfo: [NSLocalizedDescriptionKey : "Invalid NSHTTPURLResponse"])
                    }
                    self.renderFeatureErrorDisplayWithError(httpError, featureName: self.featureNameForError(httpError))
                }
            }
        }
        dataTask.resume()
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
        
        if let hybridAPI = hybridAPI {
            var readyCallback = bridge.contextValueForName("nativeBridgeReady")
            
            if !readyCallback.isUndefined() {
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

extension WebViewController {
    
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
    
    public func newWebViewControllerWithOptions(options: WebViewControllerOptions?) -> WebViewController {
        let webViewController = self.dynamicType(webView: webView, bridge: bridge)
        webViewController.addBridgeAPIObject()
        webViewController.hybridAPI?.navigationBar.title = options?.title
        webViewController.hidesBottomBarWhenPushed = options?.tabBarHidden ?? false
        webViewController.hybridAPI?.view.onAppearCallback = options?.onAppearCallback?.asValidValue
        
        if let navigationBarButtons = options?.navigationBarButtons {
            webViewController.hybridAPI?.navigationBar.configureButtons(options?.navigationBarButtons, callback: options?.navigationBarButtonCallback)
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
    
    final func presentExternalURLWithOptions(options: PresentExternalOptions) {
        let externalWebViewController = self.dynamicType()
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
        var label = UILabel(frame: CGRectMake(0, y, CGRectGetWidth(view.bounds), height))
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.Center
        label.backgroundColor = view.backgroundColor
        label.font = UIFont.boldSystemFontOfSize(12)
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
        map(url) {self.loadURL($0)}
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
        if let webFrameClass: AnyClass = NSClassFromString("WebFrame")
            where !(frame.dynamicType === webFrameClass) {
                return
        }
        
        let notifyWebviews = { () -> Void in
            if let allWebViews = webViews.allObjects as? [UIWebView] {
                for webView in allWebViews {
                    let cookie = "__thgWebviewCookie\(webView.hash)"
                    webView.stringByEvaluatingJavaScriptFromString("var \(cookie) = '\(cookie)'")
                    
                    if context.objectForKeyedSubscript(cookie).toString() == cookie {
                        webView.didCreateJavaScriptContext(context)
                    }
                }
            }
        }
        
        if NSThread.isMainThread() {
            notifyWebviews()
        } else {
            dispatch_async(dispatch_get_main_queue(), notifyWebviews)
        }
    }
}

// TODO: Remove this later!! - BKS
public var hackContext: JSContext? = nil

extension UIWebView {
    
    func didCreateJavaScriptContext(context: JSContext) {
        hackContext = context
        (delegate as? WebViewController)?.didCreateJavaScriptContext(context)
    }
}

extension NSURL {
    /// Get the absolute URL string value without the query string.
    var absoluteStringWithoutQuery: String? {
        let components = NSURLComponents(URL: self, resolvingAgainstBaseURL: false)
        components?.query = nil
        return components?.string
    }
}
