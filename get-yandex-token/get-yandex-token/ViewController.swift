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
        let url = URL(string: "https://oauth.yandex.ru/authorize?response_type=token&client_id=23cabbbdc6cd418abb4b39c32c41195d")!
        webView.load(URLRequest(url: url))
        urlObservation = webView.observe(\.url, changeHandler: { (webView, change) in
            guard var url = webView.url?.absoluteString else { return }
            
            if url.contains("access_token") {
                url = url.replacing("https://music.yandex.ru/#", with: "")
                print(url)
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

