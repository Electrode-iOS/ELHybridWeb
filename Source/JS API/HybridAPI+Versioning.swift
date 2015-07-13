//
//  HybridAPI+Versioning.swift
//  THGHybridWeb
//
//  Created by Angelo Di Paolo on 7/13/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import JavaScriptCore

@objc protocol HybridAPIVersion: JSExport {
    func version() -> String
}

extension HybridAPI: HybridAPIVersion {
    private static let versionNumber = "0.0.7"
    
    final func version() -> String {
        return HybridAPI.versionNumber
    }
}
