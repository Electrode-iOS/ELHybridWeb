//
//  DialogOptions.swift
//  THGHybridWeb
//
//  Created by Angelo Di Paolo on 7/7/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import JavaScriptCore

struct DialogOptions {
    var title: String?
    var message: String?
    let actions: [[String: AnyObject]]
    
    init(title: String?, message: String?, actions: [[String: AnyObject]]) {
        self.title = title
        self.message = message
        self.actions = actions
    }
    
    // TODO: Refactor after migrating to Swift 2 with real initializer that throws an ErrorType
    static func initOrErrorWithOptions(options: [String: AnyObject]) -> DialogOptionsResult {
        let title = options["title"] as? String
        let message = options["message"] as? String
        
        if message == nil && title == nil {
            return .Failure(DialogOptionsError.EmptyTitleAndMessage)
        }
        
        if let actions = options["actions"] as? [[String: AnyObject]] where count(actions) > 0 {
            return .Result(DialogOptions(title: title, message: message, actions: actions))
        } else {
            return .Failure(DialogOptionsError.MissingAction)
        }
    }
    
    func alertControllerWithCallback(callback: JSValue) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        for action in actions {
            if let alertAction = alertActionWithOptionAction(action, callback: callback) {
                alertController.addAction(alertAction)
            }
        }
        
        return alertController
    }
    
    private func alertActionWithOptionAction(optionAction: [String: AnyObject], callback: JSValue) -> UIAlertAction? {
        if let actionID = optionAction["id"] as? String,
            let actionLabel = optionAction["label"] as? String {
                return UIAlertAction(title: actionLabel, style: .Default) { (action) in
                    callback.callWithData(actionID)
                }
        }
        
        return nil
    }
}

enum DialogOptionsResult {
    case Result(DialogOptions)
    case Failure(HybridAPIErrorType)
}

enum DialogOptionsError: String, HybridAPIErrorType {
    case MissingAction = "Must have at least one action defined in `actions` array of the options parameter."
    case EmptyTitleAndMessage = "Must have at least title or message defined in options parameter."
    
    var message: String { return self.rawValue }
}
