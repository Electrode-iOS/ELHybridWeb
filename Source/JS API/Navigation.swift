//
//  Navigation.swift
//  THGHybridWeb
//
//  Created by Angelo Di Paolo on 4/22/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import JavaScriptCore

protocol HybridNavigationViewController: class {
    func nextViewController() -> UIViewController
}

@objc protocol NavigationJSExport: JSExport {
    func animateBackward()
    func animateForward()
}

@objc public class Navigation: ViewControllerChild, NavigationJSExport {
    
    weak var hybridNavigationViewController: HybridNavigationViewController? {
        return parentViewController as? HybridNavigationViewController
    }
    
    func animateForward() {
        dispatch_async(dispatch_get_main_queue()) {
            if let viewController = self.hybridNavigationViewController?.nextViewController() {
                self.parentViewController?.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    func animateBackward() {
        dispatch_async(dispatch_get_main_queue()) {
            self.parentViewController?.navigationController?.popViewControllerAnimated(true)
        }
    }
}
