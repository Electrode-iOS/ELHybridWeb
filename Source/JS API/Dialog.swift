//
//  Dialog.swift
//  ELHybridWeb
//
//  Created by Angelo Di Paolo on 7/30/15.
//  Copyright (c) 2015 WalmartLabs. All rights reserved.
//

import JavaScriptCore

@objc class Dialog: NSObject {
    var dialogAlert: DialogAlert?
    
    func show(options: [String: AnyObject], callback: JSValue) {
        ELHybridWebLogger.sharedLogger.log(.Debug, message: "options:\(options), callback:\(callback)") // provide breadcrumbs
        switch DialogOptions.resultOrErrorWithOptions(options) {
            
        case .Success(let box):
            dispatch_async(dispatch_get_main_queue()) {
                // bail out if an alert is currently visible to prevent showing multiple alerts
                if let visible = self.dialogAlert?.visible
                    where visible == true {
                    return
                }
                
                let dialogOptions = box.value
                self.dialogAlert = DialogAlert(dialogOptions: dialogOptions)
                
                self.dialogAlert?.show { buttonIndex in
                    if let action = dialogOptions.actionAtIndex(buttonIndex) {
                        callback.safelyCallWithData(action)
                    }
                }
            }
            
        case .Failure(let error):
            callback.callWithErrorMessage(error.message)
        }
    }
}
