//
//  JSValue+HybridAPI.swift
//  THGHybridWeb
//
//  Created by Angelo Di Paolo on 5/1/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import JavaScriptCore

// MARK: - Callback Helpers

internal extension JSValue {
    
    /**
     Calls the value like it was a JavaScript function in the form of 
     `function(error, data)`.
     :param: data The data that is passed to the callback
     :return: The return value of the function call.
    */
    func callWithData(data: AnyObject) -> JSValue! {
        return callWithArguments([JSValue(nullInContext: context), data])
    }
    
    /**
     Calls the value like it was a JavaScript function in the form of
     `function(error, data)`.
     :param: error The error that is passed to the callback.
     :return: The return value of the function call.
    */
    func callWithError(error: NSError) -> JSValue! {
        return callWithErrorMessage(error.localizedDescription)
    }
    
    /**
    Calls the value like it was a JavaScript function in the form of
    `function(error, data)`.
    :param: errorMessage The message used to create the JavaScript error
     that is passed to the callback.
    :return: The return value of the function call.
    */
    func callWithErrorMessage(errorMessage: String) -> JSValue! {
        let jsError = JSValue(newErrorFromMessage: errorMessage, inContext: context)
        return callWithArguments([jsError, JSValue(nullInContext: context)])
    }
    
    /**
    Calls the value like it was a JavaScript function in the form of
    `function(error, data)`.
    :param: error The value used to create the JavaScript error message.
    that is passed to the callback.
    :return: The return value of the function call.
    */
    func callWithErrorType(error: HybridAPIErrorType) -> JSValue! {
        let jsError = JSValue(newErrorFromMessage: error.message, inContext: context)
        return callWithArguments([jsError, JSValue(nullInContext: context)])
    }
    
    /**
    Calls the javascript function with a timeout to prevent deadlocks.
    :param: arguments The arguments array to be passed to the javascript function.
    */
    func safelyCallWithArguments(arguments: [AnyObject]!) {
        if isUndefined() || isNull() {
            return
        }
        
        var args: [AnyObject] = [self, NSNumber(integer: 0)]
        if arguments != nil {
            args += arguments
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.context.objectForKeyedSubscript("setTimeout").callWithArguments(args)
        })
    }
}

// MARK: - String Helpers

internal extension JSValue {
    var asString: String? {
        if self.isString() { return self.toString() }
        return nil
    }
}

// MARK: - Optional Helpers

extension JSValue {
    var asValidValue: JSValue? {
        if isUndefined() || isNull() {
            return nil
        }
        return self
    }
}

