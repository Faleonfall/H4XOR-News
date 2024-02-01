//
//  DetailView.swift
//  H4XOR News
//
//  Created by Volodymyr Kryvytskyi on 15.09.2023.
//

import SwiftUI

struct DetailView: View {
    
    let url: String?
    
    var body: some View {
        WebView(urlString: url)
    }
}
