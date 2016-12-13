//
//  HybridAPIInfo.swift
//  ELHybridWeb
//
//  Created by Angelo Di Paolo on 7/20/15.
//  Copyright (c) 2015 WalmartLabs. All rights reserved.
//

import JavaScriptCore
import UIKit

public struct HybridAPIInfo {
    public let device: String
    public let platform: String
    public let appVersion: String
    
    public init(appVersion: String) {
        let currentDevice = UIDevice.current
        self.device = currentDevice.model
        self.platform = "\(currentDevice.systemName) \(currentDevice.systemVersion)"
        self.appVersion = appVersion
    }
    
    public var asDictionary: [String: String] {
        return ["device": device, "platform": platform, "appVersion": appVersion]
    }
}
