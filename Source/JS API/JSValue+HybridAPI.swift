//
//  JSValue+HybridAPI.swift
//  ELHybridWeb
//
//  Created by Angelo Di Paolo on 5/1/15.
//  Copyright (c) 2015 WalmartLabs. All rights reserved.
//

import JavaScriptCore

// MARK: - Callback Helpers

public extension JSValue {
    
    /**
     Calls the value like it was a JavaScript function in the form of 
     `function(error, data)`.
     - parameter data: The data that is passed to the callback
     :return: The return value of the function call.
    */
    func callWithData(data: AnyObject) -> JSValue! {
        return call(withArguments: [JSValue(nullIn: context), data])
    }
    
    /**
     Calls the value like it was a JavaScript function in the form of
     `function(error, data)`.
     - parameter error: The error that is passed to the callback.
     :return: The return value of the function call.
    */
    func callWithError(error: NSError) -> JSValue! {
        return call(withErrorMessage: error.localizedDescription)
    }
    
    /**
    Calls the value like it was a JavaScript function in the form of
    `function(error, data)`.
    - parameter errorMessage: The message used to create the JavaScript error
     that is passed to the callback.
    :return: The return value of the function call.
    */
    func call(withErrorMessage message: String) -> JSValue! {
        let jsError = JSValue(newErrorFromMessage: message, in: context)!
        return call(withArguments: [jsError, JSValue(nullIn: context)])
    }
    
    /**
    Calls the value like it was a JavaScript function in the form of
    `function(error, data)`.
    :param: error The value used to create the JavaScript error message.
    that is passed to the callback.
    :return: The return value of the function call.
    */
    func callWithErrorType(error: HybridAPIErrorType) -> JSValue! {
        let jsError = JSValue(newErrorFromMessage: error.message, in: context)!
        return call(withArguments: [jsError, JSValue(nullIn: context)])
    }
    
    /**
     Calls the javascript function with a timeout to prevent deadlocks.
     Calls the value like it was a JavaScript function in the form of
     `function(error, data)`.
     :param: data The data that is passed to the callback
     :return: The return value of the function call.
    */
    func safelyCall(data: Any) {
        return safelyCall(withArguments: [JSValue(nullIn: context), data])
    }
    
    /**
    Calls the javascript function with a timeout to prevent deadlocks.
    :param: arguments The arguments array to be passed to the javascript function.
    */
    func safelyCall(withArguments arguments: [Any]!) {
        if isUndefined || isNull {
            return
        }
        
        var args: [Any] = [self, NSNumber(value: 0)]
        if arguments != nil {
            args += arguments
        }
        
        DispatchQueue.main.async {
            self.context.objectForKeyedSubscript("setTimeout").call(withArguments: args)
        }
    }
}

// MARK: - String Helpers

internal extension JSValue {
    var asString: String? {
        if self.isString { return self.toString() }
        return nil
    }
}

// MARK: - Optional Helpers

extension JSValue {
    var asValidValue: JSValue? {
        if isUndefined || isNull {
            return nil
        }
        return self
    }
}

