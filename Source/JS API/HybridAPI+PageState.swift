//
//  HybridAPI+PageState.swift
//  THGHybridWeb
//
//  Created by Angelo Di Paolo on 5/11/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import Foundation
import JavaScriptCore

@objc protocol PageStateJSExport: JSExport {
    func updatePageState(options: [String: AnyObject])
}

extension HybridAPI: PageStateJSExport {
    
    func updatePageState(options: [String: AnyObject]) {
        if let title = options["title"] as? String {
            parentViewController?.title = title
        }
    }
}
