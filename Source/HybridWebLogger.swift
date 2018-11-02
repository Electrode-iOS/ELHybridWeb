//
//  HybridWebLogger.swift
//  ELHybridWeb
//
//  Created by Angelo Di Paolo on 10/26/18.
//  Copyright © 2018 WalmartLabs. All rights reserved.
//

import Foundation

/// Represents the granularity and severity of a log message.
/// - Note: If your app has different `flag` values, you can override them value by setting your own.
public struct HybridWebLogFlag: OptionSet {
    public let rawValue: UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    public static var fatal   = HybridWebLogFlag(rawValue: UInt(1 << 0))
    public static var error   = HybridWebLogFlag(rawValue: UInt(1 << 1))
    public static var warning = HybridWebLogFlag(rawValue: UInt(1 << 2))
    public static var info    = HybridWebLogFlag(rawValue: UInt(1 << 3))
    public static var debug   = HybridWebLogFlag(rawValue: UInt(1 << 4))
    public static var verbose = HybridWebLogFlag(rawValue: UInt(1 << 5))
}

/// Protocol for consuming logs of `ELRouter`.
public protocol HybridWebLogger {
    
    /// Called when the framework wants to log a `message` with an associated `flag`.
    ///
    /// - Parameters:
    ///   - flag: The `flag` the `logMessage` was recorded with
    ///   - message: autoclosure returning the message
    func log(_ flag: HybridWebLogFlag, _ message: @autoclosure () -> String)
}

/// Set to consume the logs of `ELRouter`
public var logger: HybridWebLogger?

/// Convenient wrapper for sending messages to `logger`
internal func log(_ flag: HybridWebLogFlag, _ message: @autoclosure () -> String) {
    logger?.log(flag, message)
}
