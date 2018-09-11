//
//  UserProfileViewController.swift
//  ImagEngine
//
//  Created by Melissa Zellhuber on 9/11/18.
//  Copyright © 2018 mzellhuber. All rights reserved.
//

import UIKit
import WebKit
import MBProgressHUD

class UserProfileViewController: UIViewController {
    
    var hud = MBProgressHUD()
    
    var webView: WKWebView!
    
    var urlString:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        let url = URL(string: urlString)!
        webView.load(URLRequest(url: url))
    }
}

extension UserProfileViewController : WKNavigationDelegate{

    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
        hud.hide(animated: true)
    }
    
}
