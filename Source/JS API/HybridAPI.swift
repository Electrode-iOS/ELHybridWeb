//
//  HybridAPI.swift
//  ELHybridWeb
//
//  Created by Angelo Di Paolo on 4/22/15.
//  Copyright (c) 2015 WalmartLabs. All rights reserved.
//

import JavaScriptCore
import UIKit

@objc protocol HybridAPIJSExport: JSExport {
    var navigation: Navigation {get}
    var navigationBar: NavigationBar {get}
    var view: ViewAPI {get}
    var tabBar: TabBar {get}
    func info() -> [String: String]
    func newState()
}

/**
 Exports the hybrid API to JavaScript.
*/
@objc public class HybridAPI: ViewControllerChild, HybridAPIJSExport, ShareJSExport, DialogJSExport {
    
    public static let exportName = "NativeBridge"
    var navigation: Navigation
    var navigationBar: NavigationBar
    private (set) public var view: ViewAPI
    private (set) public var tabBar: TabBar
    var dialog: Dialog

    public required init(parentViewController: UIViewController) {
        navigation = Navigation(parentViewController: parentViewController)
        navigationBar = NavigationBar(parentViewController: parentViewController)
        view = ViewAPI(parentViewController: parentViewController)
        tabBar = TabBar(parentViewController: parentViewController)
        dialog = Dialog()
        super.init(parentViewController: parentViewController)
    }

    override public weak var parentViewController: UIViewController? {
        didSet {
            navigation.parentViewController = parentViewController
            navigationBar.parentViewController = parentViewController
            view.parentViewController = parentViewController
            tabBar.parentViewController = parentViewController
        }
    }
    
    public func info() -> [String: String] {
        return HybridAPIInfo(appVersion: "1.0").asDictionary
    }
    
    func newState() {
        webViewController?.hybridAPI = nil
        webViewController?.addBridgeAPIObject()
    }
}
