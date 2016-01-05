//
//  Util.swift
//  THGHybridWeb
//
//  Created by Angelo Di Paolo on 7/7/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import Foundation

protocol HybridAPIErrorType {
    var message: String {get}
}

final class Box<T> {
    let value: T
    
    init(_ value: T) {
        self.value = value
    }
}

enum HybridAPIResult<T> {
    case Success(Box<T>)
    case Failure(HybridAPIErrorType)
}
