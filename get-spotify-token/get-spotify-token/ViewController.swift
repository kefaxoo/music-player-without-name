//
//  ViewController.swift
//  get-spotify-token
//
//  Created by Bahdan Piatrouski on 14.04.23.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    var webView: WKWebView!
    var urlObservation: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://accounts.spotify.com/login")!
        webView.load(URLRequest(url: url))
        urlObservation = webView.observe(\.url, changeHandler: { (webView, change) in
            guard var url = webView.url?.absoluteString else { return }
            
            print(url)
            if url.contains("https://accounts.spotify.com/ru/status") {
                let newUrl = URL(string: "https://open.spotify.com/get_access_token")!
                webView.load(URLRequest(url: newUrl))
            }
        })
    }
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
}

extension ViewController: WKNavigationDelegate {
    
}
