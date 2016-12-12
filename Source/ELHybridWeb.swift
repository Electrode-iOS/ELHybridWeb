//
//  ELHybridWeb.swift
//  ELHybridWeb
//
//  Created by Brandon Sneed on 2/12/16.
//  Copyright © 2016 WalmartLabs. All rights reserved.
//

import Foundation
import ELLog

var sharedLogger = Logger()

internal func log(level: LogLevel, _ message: String) {
    sharedLogger.log(level, message: "ELHybridWeb: " + message)
}
