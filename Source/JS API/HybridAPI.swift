//
//  HybridAPI.swift
//  THGHybridWeb
//
//  Created by Angelo Di Paolo on 4/22/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import JavaScriptCore
import THGBridge

@objc protocol HybridAPIJSExport: JSExport {
    var navigation: Navigation {get}
}

/**
 Exports the hybrid API to JavaScript.
*/
@objc public class HybridAPI: ViewControllerChild, HybridAPIJSExport {
    
    var navigation: Navigation
    public static let exportName = "NativeBridge"

    public required init(parentViewController: UIViewController) {
        self.navigation = Navigation(parentViewController: parentViewController)
        super.init(parentViewController: parentViewController)
    }

    override public weak var parentViewController: UIViewController? {
        didSet {
            navigation.parentViewController = parentViewController
        }
    }
}

// MARK: - WebViewController Integration

public extension WebViewController {
    
    public func addHybridAPI() {
        let platform = HybridAPI(parentViewController: self)
        bridge.addExport(platform, name: HybridAPI.exportName)
    }
}

// MARK: - Bridge Integration

public extension Bridge {
    
    public var hybridAPI: HybridAPI? {
        return contextValueForName(HybridAPI.exportName).toObject() as? HybridAPI
    }
}
