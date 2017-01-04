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
    @objc optional func webViewController(_ webViewController: WebViewController, shouldStartLoadWithRequest request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool
    
    /**
     Sent before the web view begins loading a frame.
     - parameter webViewController: The web view controller that has begun loading the frame.
    */
    @objc optional func webViewControllerDidStartLoad(_ webViewController: WebViewController)
    
    /**
     Sent after the web view as finished loading a frame.
     - parameter webViewController: The web view controller that has completed loading the frame.
    */
    @objc optional func webViewControllerDidFinishLoad(_ webViewController: WebViewController)
    
    /**
     Sent if the web view fails to load a frame.
     - parameter webViewController: The web view controller that failed to load the frame.
     - parameter error: The error that occured during loading.
    */
    @objc optional func webViewController(_ webViewController: WebViewController, didFailLoadWithError error: Error)

    /**
     Sent when the web view creates the JS context for the frame.
     parameter webViewController: The web view controller that failed to load the frame.
     parameter context: The newly created JavaScript context.
    */
    @objc optional func webViewControllerDidCreateJavaScriptContext(_ webViewController: WebViewController, context: JSContext)
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
open class WebViewController: UIViewController {
    
    public enum AppearenceCause {
        case unknown, webPush, webPop, webModal, webDismiss, external
    }
    
    /// The URL that was loaded with `loadURL()`
    private(set) public var url: URL?
    
    /// The web view used to load and render the web content.
    private(set) public var webView: UIWebView!
    
    fileprivate(set) public var bridgeContext: JSContext! = JSContext()
    private var storedScreenshotGUID: String? = nil
    private var firstLoadCycleCompleted = true
    fileprivate (set) var disappearedBy = AppearenceCause.unknown
    private var storedAppearence = AppearenceCause.webPush
    // TODO: make appearedFrom internal in Swift 2 with @testable
    private (set) public var appearedFrom: AppearenceCause {
        get {
            switch disappearedBy {
            case .webPush: return .webPop
            case .webModal: return .webDismiss
            default: return storedAppearence
            }
        }
        set {
            storedAppearence = newValue
        }
    }
    private var placeholderImageView: UIImageView!
    public var errorView: UIView?
    public var errorLabel: UILabel?
    public var reloadButton: UIButton?
    public weak var hybridAPI: HybridAPI?
    private (set) weak var externalPresentingWebViewController: WebViewController?
    private(set) public var externalReturnURL: URL?
    
    /// Handles web view controller events.
    public weak var delegate: WebViewControllerDelegate?
    
    /// Set `false` to disable error message UI.
    public var showErrorDisplay = true

    /// An optional custom user agent string to be used in the header when loading the URL.
    public var userAgent: String?

    /// Host for NSURLSessionDelegate challenge
    public var challengeHost: String?

    public var urlSession: URLSession!

    /// A NSURLSessionDataTask object used to load the URLs
    public var dataTask: URLSessionDataTask?

    /**
     Initialize a web view controller instance with a web view and JavaScript
      bridge. The newly initialized web view controller becomes the delegate of
      the web view.
     :param: webView The web view to use in the web view controller.
     :param: bridge The bridge instance to integrate int
    */
    public required init(webView: UIWebView, context: JSContext) {
        super.init(nibName: nil, bundle: nil)
        
        self.bridgeContext = context
        self.webView = webView
        self.webView.delegate = self
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
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
    
    func initWebView() {
        if webView == nil {
            webView = UIWebView(frame: CGRect.zero)
            webView.delegate = self
            WebViewManager.addBridgedWebView(webView: webView)
            webView.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    func initURLSession() {
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        if let agent = self.userAgent {
            configuration.httpAdditionalHeaders = [
                "User-Agent": agent
            ]
        }
        urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        edgesForExtendedLayout = []
        placeholderImageView = UIImageView(frame: self.view.bounds)
        view.addSubview(placeholderImageView)
        
        initURLSession()
        initWebView()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        switch appearedFrom {
            
        case .webPush, .webModal, .webPop, .webDismiss, .external:
            webView.delegate = self
            webView.removeFromSuperview() // remove webView from previous view controller's view
            webView.frame = view.bounds
            view.addSubview(webView) // add webView to this view controller's view
            // Pin web view top and bottom to top and bottom of view
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[webView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["webView" : webView]))
            // Pin web view sides to sides of view
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[webView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["webView" : webView]))
            view.removeDoubleTapGestures()
            if let storedScreenshotGUID = storedScreenshotGUID {
                placeholderImageView.image = UIImage.loadImageFromGUID(guid: storedScreenshotGUID)
                view.bringSubview(toFront: placeholderImageView)
            }
        case .unknown: break
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hybridAPI?.view.appeared()
        
        switch appearedFrom {
        
        case .webPop, .webDismiss: addBridgeAPIObject()
            
        case .webPush, .webModal, .external, .unknown: break
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        switch disappearedBy {
            
        case .webPop, .webDismiss, .webPush, .webModal:
            // only store screen shot when disappearing by web transition
            placeholderImageView.frame = webView.frame // must align frames for image capture
            
            if let screenshotImage = webView.captureImage() {
                placeholderImageView.image = screenshotImage
                storedScreenshotGUID = screenshotImage.saveImageToGUID()
            }

            view.bringSubview(toFront: placeholderImageView)
            
            webView.isHidden = true
            
        case .unknown:
            if isMovingFromParentViewController {
                webView.isHidden = true
            }
        case .external: break
        }

        if disappearedBy != .webPop && isMovingFromParentViewController {
            hybridAPI?.navigation.back()
        }

        hybridAPI?.view.disappeared() // needs to be called in viewWillDisappear not Did

        switch disappearedBy {
        // clear out parent reference to prevent the popping view's onAppear from
        // showing the web view too early
        case .webPop,
             .unknown where isMovingFromParentViewController:
            hybridAPI?.parentViewController = nil
        default: break
        }
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        switch disappearedBy {
            
        case .webPop, .webDismiss, .webPush, .webModal, .external:
            // we're gone.  dump the screenshot, we'll load it later if we need to.
            placeholderImageView.image = nil
            
        case .unknown:
            // we don't know how it will appear if we don't know how it disappeared
            appearedFrom = .unknown
        }
    }
    
    public final func showWebView() {
        webView.isHidden = false
        placeholderImageView.image = nil
        view.sendSubview(toBack: placeholderImageView)
    }
    
    // MARK: Request Loading
    
    /**
     Load the web view with the provided URL.
     :param: url The URL used to load the web view.
    */
    final public func load(url: URL) {
        self.dataTask?.cancel() // cancel any running task
        hybridAPI = nil
        firstLoadCycleCompleted = false

        self.url = url
        let request = self.request(url: url)

        self.dataTask = self.urlSession.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            DispatchQueue.main.async {
                if let httpError = error {
                    // render error display
                    if self.showErrorDisplay {
                        self.renderFeatureErrorDisplayWithError(error: httpError, featureName: self.featureName(forError: httpError))
                    }
                } else if let urlResponse = response as? HTTPURLResponse {
                    if urlResponse.statusCode >= 400 {
                        // render error display
                        if self.showErrorDisplay {
                            let httpError = NSError(domain: "WebViewController", code: urlResponse.statusCode, userInfo: ["response" : urlResponse, NSLocalizedDescriptionKey : "HTTP Response Status \(urlResponse.statusCode)"])
                            self.renderFeatureErrorDisplayWithError(error: httpError, featureName: self.featureName(forError: httpError))
                        }
                    } else if let data = data,
                        let MIMEType = urlResponse.mimeType,
                        let textEncodingName = urlResponse.textEncodingName,
                        let url = urlResponse.url {
                        self.webView.load(data, mimeType: MIMEType, textEncodingName: textEncodingName, baseURL: url)
                    }
                }
            }
        }
        self.dataTask?.resume()
    }
    
    /**
     Create a request with the provided URL.
     :param: url The URL for the request.
    */
    public func request(url: URL) -> URLRequest {
        return URLRequest(url: url)
    }
    
    fileprivate func didInterceptRequest(_ request: URLRequest) -> Bool {
        if appearedFrom == .external {
            // intercept requests that match external return URL
            if let url = request.url, shouldInterceptExternalURL(url: url) {
                returnFromExternal(returnURL: url)
                return true
            }
        }
        
        return false
    }
    
    // MARK: Web Controller Navigation
    
    /**
     Push a new web view controller on the navigation stack using the existing
     web view instance. Does not affect web view history. Uses animation.
     */
    public func pushWebViewController() {
        pushWebViewController(options: nil)
    }
    
    /**
     Push a new web view controller on the navigation stack using the existing
     web view instance. Does not affect web view history. Uses animation.
     :param: hideBottomBar Hides the bottom bar of the view controller when true.
     */
    public func pushWebViewController(options: WebViewControllerOptions?) {
        disappearedBy = .webPush
        
        let webViewController = newWebViewController(options: options)
        webViewController.appearedFrom = .webPush
        
        navigationController?.pushViewController(webViewController, animated: true)
    }
    
    /**
     Pop a web view controller off of the navigation. Does not affect
     web view history. Uses animation.
     */
    public func popWebViewController() {
        disappearedBy = .webPop
        
        if let navController = self.navigationController, navController.viewControllers.count > 1 {
            navController.popViewController(animated: true)
        }
    }
    
    /**
     Present a navigation controller containing a new web view controller as the
     root view controller. The existing web view instance is reused.
     */
    public func presentModalWebViewController(options: WebViewControllerOptions?) {
        disappearedBy = .webModal
        
        let webViewController = newWebViewController(options: options)
        webViewController.appearedFrom = .webModal
        
        let navigationController = UINavigationController(rootViewController: webViewController)
        
        if let tabBarController = tabBarController {
            tabBarController.present(navigationController, animated: true, completion: nil)
        } else {
            present(navigationController, animated: true, completion: nil)
        }
    }
    
    /// Pops until there's only a single view controller left on the navigation stack.
    public func popToRootWebViewController(animated: Bool) {
        disappearedBy = .webPop
        let _ = navigationController?.popToRootViewController(animated: animated)
    }
    
    /**
     Return `true` to have the web view controller push a new web view controller
     on the stack for a given navigation type of a request.
     */
    public func pushesWebViewControllerForNavigationType(navigationType: UIWebViewNavigationType) -> Bool {
        return false
    }
    
    public func newWebViewController(options: WebViewControllerOptions?) -> WebViewController {
        let webViewController = type(of: self).init(webView: webView, context: bridgeContext)
        webViewController.addBridgeAPIObject()
        webViewController.hybridAPI?.navigationBar.title = options?.title
        webViewController.hidesBottomBarWhenPushed = options?.tabBarHidden ?? false
        webViewController.hybridAPI?.view.onAppearCallback = options?.onAppearCallback?.asValidValue
        
        if let navigationBarButtons = options?.navigationBarButtons {
            webViewController.hybridAPI?.navigationBar.configureButtons(navigationBarButtons, callback: options?.navigationBarButtonCallback)
        }
        
        return webViewController
    }
    
    // MARK: External Navigation
    
    final var shouldDismissExternalURLModal: Bool {
        return !webView.canGoBack
    }
    
    final func shouldInterceptExternalURL(url: URL) -> Bool {
        if let requestedURLString = url.absoluteStringWithoutQuery,
            let returnURLString = externalReturnURL?.absoluteStringWithoutQuery, (requestedURLString as NSString).range(of: returnURLString) != nil {
            return true
        }
        
        return false
    }
    
    // TODO: make internal after migrating to Swift 2 and @testable
    @discardableResult final public func presentExternalURL(options: ExternalNavigationOptions) -> WebViewController {
        let externalWebViewController = type(of: self).init()
        externalWebViewController.externalPresentingWebViewController = self
        externalWebViewController.addBridgeAPIObject()
        externalWebViewController.load(url: options.url)
        externalWebViewController.appearedFrom = .external
        externalWebViewController.externalReturnURL = options.returnURL
        externalWebViewController.title = options.title
        
        let backText = NSLocalizedString("Back", tableName: nil, bundle: Bundle.main, value: "", comment: "")
        externalWebViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: backText, style: .plain, target: externalWebViewController, action: #selector(WebViewController.externalBackButtonTapped))
        
        let doneText = NSLocalizedString("Done", tableName: nil, bundle: Bundle.main, value: "", comment: "")
        externalWebViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: doneText, style: .done, target: externalWebViewController, action: #selector(WebViewController.dismissExternalURL))
        
        let navigationController = UINavigationController(rootViewController: externalWebViewController)
        present(navigationController, animated: true, completion: nil)
        return externalWebViewController
    }
    
    final func externalBackButtonTapped() {
        if shouldDismissExternalURLModal {
            externalPresentingWebViewController?.showWebView()
            dismissExternalURL()
        }
        
        webView.goBack()
    }
    
    final func returnFromExternal(returnURL url: URL) {
        externalPresentingWebViewController?.load(url: url)
        dismissExternalURL()
    }
    
    final func dismissExternalURL() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Error UI
    
    private func createErrorLabel() -> UILabel? {
        let height = CGFloat(50)
        let y = view.bounds.midY - (height / 2) - 100
        let label = UILabel(frame: CGRect(x: 0, y: y, width: view.bounds.width, height: height))
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.center
        label.backgroundColor = view.backgroundColor
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
    }
    
    private func createReloadButton() -> UIButton? {
        let button = UIButton(type: .custom)
        let size = CGSize(width: 170, height: 38)
        let x = view.bounds.midX - (size.width / 2)
        var y = view.bounds.midY - (size.height / 2)
        
        if let label = errorLabel {
            y = label.frame.maxY + 20
        }
        
        button.setTitle(NSLocalizedString("Try again", comment: "Try again"), for: UIControlState.normal)
        button.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
        button.backgroundColor = UIColor.lightGray
        button.titleLabel?.backgroundColor = UIColor.lightGray
        button.titleLabel?.textColor = UIColor.white
        
        return button
    }
    
    // MARK: Error Display Events
    
    /// Override to completely customize error display. Must also override `removeErrorDisplay`
    open func renderErrorDisplay(error: Error, message: String) {
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
            button.addTarget(self, action: #selector(WebViewController.reloadButtonTapped), for: .touchUpInside)
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
    open func featureName(forError error: Error) -> String {
        return "This feature"
    }
    
    /// Override to customize the error message text.
    open func renderFeatureErrorDisplayWithError(error: Error, featureName: String) {
        let message = "Sorry!\n \(featureName) isn't working right now."
        webView.isHidden = true
        renderErrorDisplay(error: error, message: message)
    }
    
    /// Removes the error display and attempts to reload the web view.
    open func reloadButtonTapped(sender: AnyObject) {
        guard let url = url else { return }
        load(url: url)
    }
    
    // MARK: Bridge API
    
    open func addBridgeAPIObject() {
        if let bridgeObject = hybridAPI {
            bridgeContext.setObject(bridgeObject, forKeyedSubscript: HybridAPI.exportName as NSString)
        } else {
            let platform = HybridAPI(parentViewController: self)
            bridgeContext.setObject(platform, forKeyedSubscript: HybridAPI.exportName as NSString)
            hybridAPI = platform
        }
    }
}


// MARK: - NSURLSessionDelegate

extension WebViewController: URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let host = challengeHost,
                let serverTrust = challenge.protectionSpace.serverTrust, challenge.protectionSpace.host == host {
                    let credential = URLCredential(trust: serverTrust)
                    completionHandler(.useCredential, credential)
            } else {
                completionHandler(.performDefaultHandling, nil)
            }
        }
    }
}

// MARK: - UIWebViewDelegate

extension WebViewController: UIWebViewDelegate {
    final public func webViewDidStartLoad(_ webView: UIWebView) {
        delegate?.webViewControllerDidStartLoad?(self)
    }
    
    public func webViewDidFinishLoad(_ webView: UIWebView) {
        delegate?.webViewControllerDidFinishLoad?(self)

        if self.errorView != nil {
            self.removeErrorDisplay()
        }
    }
    
    final public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if pushesWebViewControllerForNavigationType(navigationType: navigationType) {
            pushWebViewController()
        }
        
        if didInterceptRequest(request) {
            return false
        } else {
            return delegate?.webViewController?(self, shouldStartLoadWithRequest: request, navigationType: navigationType) ?? true
        }
    }
    
    final public func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        if (error as NSError).code != NSURLErrorCancelled && showErrorDisplay {
            renderFeatureErrorDisplayWithError(error: error, featureName: featureName(forError: error))
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
            configureBridgeContext(context: context)
        } else {
            print("Failed to retrieve JavaScript context from web view.")
        }
    }
    
    public func didCreateJavaScriptContext(context: JSContext) {
        configureBridgeContext(context: context)
        delegate?.webViewControllerDidCreateJavaScriptContext?(self, context: context)
        configureContext(context: context)
        
        if let hybridAPI = hybridAPI, let readyCallback = context.objectForKeyedSubscript("nativeBridgeReady") {
            if !readyCallback.isUndefined {
                readyCallback.call(withData: hybridAPI)
            }
        }
    }
    
    /**
     Explictly set the bridge's JavaScript context.
    */
    final public func configureBridgeContext(context: JSContext) {
        bridgeContext = context
    }
    
    public func configureContext(context: JSContext) {
        addBridgeAPIObject()
    }
}


// MARK: - UIView Utils

extension UIView {
    
    func captureImage() -> UIImage? {
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
        layer.render(in: context)
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
                if let gesture = gesture as? UITapGestureRecognizer, gesture.numberOfTapsRequired == 2 {
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
        let guid = UUID().uuidString
        
        DispatchQueue.global().async {
            if let imageData = UIImageJPEGRepresentation(self, 1.0),
                let filePath = UIImage.absoluteFilePath(guid: guid) {
                FileManager.default.createFile(atPath: filePath, contents: imageData, attributes: nil)
            }
        }
        
        return guid
    }
    
    class func loadImageFromGUID(guid: String) -> UIImage? {
        guard let filePath = UIImage.absoluteFilePath(guid: guid) else { return nil }
        return UIImage(contentsOfFile: filePath)
    }
    
    private class func absoluteFilePath(guid: String) -> String? {
        return NSURL(string: NSTemporaryDirectory())?.appendingPathComponent(guid)!.absoluteString
    }
}

// MARK: - JSContext Event

@objc(WebViewBridging)
public protocol WebViewBridging {
    func didCreateJavaScriptContext(context: JSContext)
}

private var globalWebViews = NSHashTable<UIWebView>.weakObjects()

@objc(WebViewManager)
public class WebViewManager: NSObject {
    // globalWebViews is a weak hash table.  No need to remove items.
    @objc static public func addBridgedWebView(webView: UIWebView?) {
        if let webView = webView {
            globalWebViews.add(webView)
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
            let newValue = UUID().uuidString
            objc_setAssociatedObject(self, &AssociatedKeys.uniqueIDKey, newValue as NSString?, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return newValue
        }
    }
    
    func webView(webView: AnyObject, didCreateJavaScriptContext context: JSContext, forFrame frame: AnyObject) {
        let notifyWebviews = { () -> Void in
            let allWebViews = globalWebViews.allObjects
            for webView in allWebViews {
                let cookie = "__thgWebviewCookie\(webView.hash)"
                let js = "var \(cookie) = '\(cookie)'"
                webView.stringByEvaluatingJavaScript(from: js)
                
                let contextCookie = context.objectForKeyedSubscript(cookie).toString()
                if contextCookie == cookie {
                    if let bridgingDelegate = webView.delegate as? WebViewBridging {
                        bridgingDelegate.didCreateJavaScriptContext(context: context)
                    }
                }
            }
        
        }
        
        let webFrameClass1: AnyClass! = NSClassFromString("WebFrame") // Most web-views
        let webFrameClass2: AnyClass! = NSClassFromString("NSKVONotifying_WebFrame") // Objc webviews accessed via swift
        
        if (type(of: frame) === webFrameClass1) || (type(of: frame) === webFrameClass2) {
            if Thread.isMainThread {
                notifyWebviews()
            } else {
                DispatchQueue.main.async(execute: notifyWebviews)
            }
        }
    }
}

extension URL {
    /// Get the absolute URL string value without the query string.
    var absoluteStringWithoutQuery: String? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        components?.query = nil
        return components?.string
    }
}
