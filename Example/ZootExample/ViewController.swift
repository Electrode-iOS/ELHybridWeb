//
//  ViewController.swift
//  ELHybridWebExample
//
//  Created by Angelo Di Paolo on 5/11/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import UIKit
import JavaScriptCore
import ELHybridWeb

class ViewController: UIViewController {
    var webViewURL = NSURL(string: "http://bridgeofdeath.herokuapp.com/")
    
    /**
     Example of pusing a web view from a native view.
    */
    @IBAction func pushWebView(sender: UIButton) {
        if let url = webViewURL {
            let webController = WebViewController()
            webController.load(url: url as URL)
            navigationController?.pushViewController(webController, animated: true)
        }
    }
}
