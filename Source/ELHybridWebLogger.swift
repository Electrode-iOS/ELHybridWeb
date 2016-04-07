//
//  ELHybridWebLogger.swift
//  walmart
//
//  Created by David Pettigrew on 10/22/15.
//  Copyright (c) 2015 Walmart. All rights reserved.
//

import Foundation
import ELLog

public class ELHybridWebLogger {

    public static let sharedLogger = ELHybridWebLogger.thgHybridWebLogger()

    /// Private convenience method for instantiating the default logging scheme.
    private static func thgHybridWebLogger() -> Logger {
        let logger = Logger()
        let console = LogConsoleDestination()
        console.level = LogLevel.Debug.rawValue | LogLevel.Error.rawValue
        console.showCaller = true
        logger.addDestination(console)
        return logger
    }
    
}

