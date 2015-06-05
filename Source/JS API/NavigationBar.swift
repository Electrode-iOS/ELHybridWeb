//
//  NavigationBar.swift
//  THGHybridWeb
//
//  Created by Angelo Di Paolo on 6/3/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import JavaScriptCore

@objc protocol NavigationBarJSExport: JSExport {
    func setTitle(title: String)
    func setButtons(buttons: [BarButton])
    func createButton(title: String, _ onClick: JSValue) -> BarButton
}

@objc public class NavigationBar: ViewControllerChild {
    
    private var buttons: [Int: BarButton]? {
        didSet {
            if let leftButton = buttons?[0]?.barButtonItem {
                parentViewController?.navigationItem.leftBarButtonItem = leftButton
            }
            
            if let rightButton = buttons?[1]?.barButtonItem {
                parentViewController?.navigationItem.rightBarButtonItem = rightButton
            }
        }
    }
}

extension NavigationBar: NavigationBarJSExport {
    
    func setTitle(title: String) {
        dispatch_async(dispatch_get_main_queue()) {
            parentViewController?.title = title
        }
    }
    
    func createButton(title: String, _ onClick: JSValue) -> BarButton {
        return BarButton(title: title, onClick: onClick)
    }
    
    func setButtons(buttonsToSet: [BarButton]) {
        dispatch_async(dispatch_get_main_queue()) {
            self.buttons = BarButton.dictionaryFromArray(buttonsToSet)
        }
    }
}
