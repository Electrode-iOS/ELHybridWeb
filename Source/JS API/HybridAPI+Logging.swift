//
//  HybridAPI+Logging.swift
//  ELHybridWeb
//
//  Created by Angelo Di Paolo on 5/11/15.
//  Copyright (c) 2015 WalmartLabs. All rights reserved.
//

import Foundation
import JavaScriptCore

@objc protocol HybridLoggingJSExport: JSExport {
    func log(_ value: AnyObject)
}

extension HybridAPI {
    func log(_ value: AnyObject) {
        ELHybridWeb.log(.info, "HybridAPI: \(value)")
    }
}
