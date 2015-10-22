//
//  THGHybridWebLogger.swift
//  walmart
//
//  Created by David Pettigrew on 10/22/15.
//  Copyright (c) 2015 Walmart. All rights reserved.
//

import Foundation

@objc
public class THGHybridWebLogger {

    public static let sharedLogger = THGHybridWebLogger.thgHybridWebLogger()

    /// Private convenience method for instantiating the default logging scheme.
    private static func thgHybridWebLogger() -> Logger {
        let logger = Logger()
        let destination = LogTextfileDestination(filename: "HybridAPI.log.txt")
        destination.level = LogLevel.Debug.rawValue | LogLevel.Error.rawValue
        destination.showCaller = true
        logger.addDestination(destination)
        return logger
    }
    
}

