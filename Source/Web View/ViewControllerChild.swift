//
//  ViewControllerChild.swift
//  ELHybridWeb
//
//  Created by Angelo Di Paolo on 4/28/15.
//  Copyright (c) 2015 WalmartLabs. All rights reserved.
//

import Foundation
import UIKit

protocol ViewControllerChildType {
    weak var parentViewController: UIViewController? {get set}
    init(parentViewController: UIViewController)
}

/**
 An abstract class for implementing a bridge object that requires a reference
 to a parent view controller.
*/
@objc public class ViewControllerChild: NSObject, ViewControllerChildType {
    public weak var parentViewController: UIViewController?

    public required init(parentViewController: UIViewController) {
        self.parentViewController = parentViewController
    }
}

// MARK: WebViewController Integration

extension ViewControllerChild {
    
    weak var webViewController: WebViewController? {
        return parentViewController as? WebViewController
    }
}