//
//  HybridAPI+Dialog.swift
//  ELHybridWeb
//
//  Created by Angelo Di Paolo on 5/4/15.
//  Copyright (c) 2015 WalmartLabs. All rights reserved.
//

import JavaScriptCore

@objc protocol DialogJSExport: JSExport {
    func dialog(_ options: [String: AnyObject], _ callback: JSValue)
}

extension HybridAPI {
    func dialog(_ options: [String: AnyObject], _ callback: JSValue) {
        ELHybridWeb.log(.debug, "options:\(options), callback\(callback)") // provide breadcrumbs
        dialog.show(options: options, callback: callback)
    }
}
