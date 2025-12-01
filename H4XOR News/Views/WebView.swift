//
//  WebView.swift
//  H4XOR News
//
//  Created by Volodymyr Kryvytskyi on 15.09.2023.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    
    let urlString: String?
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard
            let safeString = urlString,
            let url = URL(string: safeString)
        else { return }
        
        // Avoid reloading if the same URL is already displayed
        if uiView.url?.absoluteString != safeString {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
}
