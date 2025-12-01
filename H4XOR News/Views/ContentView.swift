//
//  ContentView.swift
//  H4XOR News
//
//  Created by Volodymyr Kryvytskyi on 10.09.2023.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var networkManager = NetworkManager()
    
    var body: some View {
        NavigationStack {
            List(networkManager.posts) { post in
                NavigationLink {
                    DetailView(url: post.url)
                } label: {
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text("\(post.points)")
                            .font(.headline)
                            .monospacedDigit()
                            .frame(minWidth: 36, alignment: .trailing)
                        Text(post.title)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("H4XOR NEWS")
            .overlay {
                if networkManager.isLoading && networkManager.posts.isEmpty {
                    ProgressView("Loading…")
                        .controlSize(.large)
                } else if let message = networkManager.errorMessage, networkManager.posts.isEmpty {
                    VStack(spacing: 12) {
                        Text(message)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        Button("Retry") {
                            Task { await networkManager.fetchFrontPage() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }
            .refreshable {
                await networkManager.fetchFrontPage()
            }
        }
        .task {
            await networkManager.fetchFrontPage()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
