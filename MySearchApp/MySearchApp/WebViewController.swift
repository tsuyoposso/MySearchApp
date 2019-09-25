//
//  WebViewController.swift
//  MySearchApp
//
//  Created by 長坂豪士 on 2019/09/24.
//  Copyright © 2019 Tsuyoshi Nagasaka. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    var itemUrl: String?
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0_1 like Mac OS X) AppleWeKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A402 Safari/604.1"
        
        guard let itemUrl = itemUrl else {
            return
        }
        
        guard let url = URL(string: itemUrl) else {
            return
        }

        let request = URLRequest(url: url)
        webView.load(request)


    }
}
