//
//  HybridAPI+NativeDetailView.swift
//  ELHybridWebExample
//
//  Created by Angelo Di Paolo on 5/15/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import Foundation
import JavaScriptCore
import ELHybridWeb

@objc protocol DetailViewJSExport: JSExport {
    func pushDetailView(detailID: String)
    func pushDetailViewWithCallback(detailID: String, _ callback: JSValue)
}

extension HybridAPI: DetailViewJSExport {
    
    /**
     Example of adding a custom method that pushes a native view controller.
    */
    func pushDetailView(detailID: String) {
        let detailViewController = DetailViewController(nibName: "DetailViewController", bundle: nil)
        detailViewController.detailID = detailID
        detailViewController.previousWebViewController = parentViewController as? WebViewController
        parentViewController?.navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    /**
     Example of adding a custom method that pushes a native view controller with
     a callback. The callback is used to notify web to update it's view.
    */
    func pushDetailViewWithCallback(detailID: String, _ callback: JSValue) {
        let detailViewController = DetailViewController(nibName: "DetailViewController", bundle: nil)
        detailViewController.detailID = detailID
        detailViewController.webCallback = callback
        detailViewController.previousWebViewController = parentViewController as? WebViewController
        parentViewController?.navigationController?.pushViewController(detailViewController, animated: true)
    }
}
