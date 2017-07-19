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
    public var info: [String: String]?
    
    public init(appVersion: String) {
        let currentDevice = UIDevice.current
        self.device = currentDevice.model
        self.platform = "\(currentDevice.systemName) \(currentDevice.systemVersion)"
        self.appVersion = appVersion
    }
    
    init(appVersion: String, info: [String: String]) {
        self.init(appVersion: appVersion)
        self.info = info
    }
    
    public var asDictionary: [String: String] {
        var dictionary = ["device": device, "platform": platform, "appVersion": appVersion]
        
        if let info = info {
            for (key, value) in info {
                dictionary[key] = value
            }
        }
        
        return dictionary
    }
}
