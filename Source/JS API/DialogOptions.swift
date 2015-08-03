//
//  DialogOptions.swift
//  THGHybridWeb
//
//  Created by Angelo Di Paolo on 7/7/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import JavaScriptCore
import UIKit

struct DialogOptions {
    var title: String?
    var message: String?
    let actions: [DialogAction]
    
    init(title: String?, message: String?, actions: [DialogAction]) {
        self.title = title
        self.message = message
        self.actions = actions
    }
    
    // TODO: Refactor after migrating to Swift 2 with real initializer that throws an ErrorType
    static func resultOrErrorWithOptions(options: [String: AnyObject]) -> HybridAPIResult<DialogOptions> {
        let title = options["title"] as? String
        let message = options["message"] as? String
        
        if message == nil && title == nil {
            return .Failure(DialogOptionsError.EmptyTitleAndMessage)
        }
        
        if let actions = options["actions"] as? [[String: AnyObject]] where count(actions) > 0 {
            var dialogActions = [DialogAction]()
            
            for actionOptions in actions {
                switch DialogAction.resultOrError(actionOptions) {
                    
                case .Success(let boxedDialogAction):
                    dialogActions.append(boxedDialogAction.value)
                    
                case .Failure(let error):
                    return .Failure(error)
                }
            }
            
            return .Success(Box(DialogOptions(title: title, message: message, actions: dialogActions)))
        } else {
            return .Failure(DialogOptionsError.MissingAction)
        }
    }
    
    func actionAtIndex(index: Int) -> String? {
        return actions[index].actionID
    }
}

enum DialogOptionsError: String, HybridAPIErrorType {
    case MissingAction = "Must have at least one action defined in `actions` array of the options parameter."
    case EmptyTitleAndMessage = "Must have at least title or message defined in options parameter."
    case MissingActionParameters = "Action objects must have `id` and `label` parameters."
    
    var message: String { return self.rawValue }
}

struct DialogAction {
    let actionID: String
    let label: String
    
    static func resultOrError(options: [String: AnyObject]) ->  HybridAPIResult<DialogAction> {
        if let actionID = options["id"] as? String,
            let label = options["label"] as? String {
                return .Success(Box(DialogAction(actionID: actionID, label: label)))
        } else {
            return .Failure(DialogOptionsError.MissingActionParameters)
        }
    }
}
