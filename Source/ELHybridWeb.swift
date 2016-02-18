//
//  ELHybridWeb.swift
//  ELHybridWeb
//
//  Created by Brandon Sneed on 2/12/16.
//  Copyright © 2016 WalmartLabs. All rights reserved.
//

import Foundation
import ELLog

@objc
public class ELHybridWeb: NSObject {
    public static let logging = Logger()
}

internal func log(level: LogLevel, _ message: String) {
    ELHybridWeb.logging.log(level, message: "\(ELHybridWeb.self): " + message)
}
