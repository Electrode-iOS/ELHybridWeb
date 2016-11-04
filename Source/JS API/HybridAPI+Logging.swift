//
//  HybridAPI+Logging.swift
//  ELHybridWeb
//
//  Created by Angelo Di Paolo on 5/11/15.
//  Copyright (c) 2015 WalmartLabs. All rights reserved.
//

import Foundation
import JavaScriptCore
import ELLog

@objc protocol HybridLoggingJSExport: JSExport {
    func log(value: AnyObject)
}

extension HybridAPI {
    func log(value: AnyObject) {
        log(.Info, "HybridAPI: \(value)")
    }
    
    func log(level: LogLevel, _ message: String) {
        sharedLogger.log(level, message: message)
    }
}
