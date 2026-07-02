import SwiftUI
import WebKit

struct LegalWebView: View {
    @EnvironmentObject private var container: AppContainer
    let document: LegalDocument

    var body: some View {
        WebView(url: container.config.legalLinks.url(for: document))
            .navigationTitle(document.title)
            .navigationBarTitleDisplayMode(.inline)
    }
}

private struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.load(URLRequest(url: url))
    }
}
