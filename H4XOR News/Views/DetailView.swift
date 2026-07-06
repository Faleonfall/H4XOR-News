import SwiftUI

struct DetailView: View {
    let url: String?

    var body: some View {
        WebView(urlString: url)
            .navigationTitle("Article")
            .navigationBarTitleDisplayMode(.inline)
    }
}
