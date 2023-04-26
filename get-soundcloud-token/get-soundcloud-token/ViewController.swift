//
//  ViewController.swift
//  get-yandex-token
//
//  Created by Bahdan Piatrouski on 3.04.23.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    var webView: WKWebView!
    var urlObservation: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://api.soundcloud.com/connect?client_id=5acc74891941cfc73ec8ee2504be6617&redirect_uri=https://quodlibet.github.io/callbacks/soundcloud.html&response_type=code")!
        webView.load(URLRequest(url: url))
        urlObservation = webView.observe(\.url, changeHandler: { (webView, change) in
            guard var url = webView.url?.absoluteString else { return }
            
            if url.contains("https://quodlibet.github.io/callbacks/soundcloud.html?code="){
                let token = url.replacing("https://quodlibet.github.io/callbacks/soundcloud.html?code=", with: "")
                print(token)
            }
        })
    }
    
    override func loadView() {
        let config = WKWebViewConfiguration()
        config.applicationNameForUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 16_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.3 Mobile/15E148 Safari/604.1"
        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        view = webView
    }
}

extension ViewController: WKNavigationDelegate {
    
}

