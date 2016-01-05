//
//  DialogAlert.swift
//  THGHybridWeb
//
//  Created by Angelo Di Paolo on 7/30/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import Foundation
import UIKit

@objc class DialogAlert: NSObject {
    var callback: ((Int) -> Void)?
    private (set) var dialogOptions: DialogOptions
    private var alertView: UIAlertView?
    var visible: Bool {
        return alertView?.visible ?? false
    }
    
    init(dialogOptions: DialogOptions) {
        self.dialogOptions = dialogOptions
    }
    
    deinit {
        alertView?.delegate = nil
    }
    
    func show(callback: (Int) -> Void) {
        self.callback = callback
        
        alertView = createAlertView()
        alertView?.show()
    }
    
    func createAlertView() -> UIAlertView {
        let alert = UIAlertView(title: dialogOptions.title, message: dialogOptions.message, delegate: self, cancelButtonTitle: nil)
        
        for action in dialogOptions.actions {
            alert.addButtonWithTitle(action.label)
        }
        
        return alert
    }
}

extension DialogAlert: UIAlertViewDelegate {
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        callback?(buttonIndex)
    }
}
