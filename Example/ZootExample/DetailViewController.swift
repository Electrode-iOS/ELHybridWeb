//
//  DetailViewController.swift
//  ZootExample
//
//  Created by Angelo Di Paolo on 5/15/15.
//  Copyright (c) 2015 TheHolyGrail. All rights reserved.
//

import UIKit
import JavaScriptCore
import THGHybridWeb

/**
 Example view controler that displays the details of an item.
*/
class DetailViewController: UIViewController {
    
    var detailID: String?
    weak var previousWebViewController: WebViewController?
    var webCallback: JSValue?
    var testOutput = "test from native"
    
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var webViewButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Details"
        
        if let detailID = detailID {
            detailLabel.text = "Detail ID: \(detailID)"
        }
        
        webViewButton.enabled = (previousWebViewController != nil)
    }
    
    /**
     Example of pushing from native to web with an existing web view.
    */
    @IBAction func pushWebViewCallback(sender: UIButton) {
        
        if let previous = previousWebViewController {
            let webViewController = WebViewController(webView: previous.webView, bridge: previous.bridge)
            
            if let webCallback = webCallback {
                webCallback.callWithArguments([testOutput])
            }
            
            navigationController?.pushViewController(webViewController, animated: true)
        }
    }
}
