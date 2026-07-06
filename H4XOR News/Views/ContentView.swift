import SwiftUI

struct ContentView: View {
    @StateObject private var networkManager = NetworkManager()

    var body: some View {
        NavigationStack {
            // MARK: - Story List
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
            .contentMargins(.top, 0, for: .scrollContent)
            // MARK: - Title Header
            .safeAreaInset(edge: .top, spacing: 0) {
                Text("H4XOR NEWS")
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color(.systemGroupedBackground))
            }
            .toolbar(.hidden, for: .navigationBar)
            // MARK: - Loading & Error States
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

#Preview {
    ContentView()
}
