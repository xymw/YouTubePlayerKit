import SwiftUI
import WebKit

// MARK: - YouTubePlayerView

/// A YouTubePlayer SwiftUI View
public struct YouTubePlayerView<Overlay: View> {
    // MARK: Properties

    /// The YouTubePlayer
    public let player: YouTubePlayer
    public let webView: YouTubePlayerWebView

    /// The The transaction to use when the `YouTubePlayer.State` changes
    public let transaction: Transaction

    /// The Overlay ViewBuilder closure
    public let overlay: (YouTubePlayer.State) -> Overlay

    /// The current YouTubePlayer State
    @State
    private var state: YouTubePlayer.State = .idle

    // MARK: Initializer

    /// Creates a new instance of `YouTubePlayer.View`
    /// - Parameters:
    ///   - player: The YouTubePlayer
    ///   - transaction: The transaction to use when the `YouTubePlayer.State` changes. Default value `.init()`
    ///   - overlay: The Overlay ViewBuilder closure
    public init(
        _ player: YouTubePlayer,
        webView: YouTubePlayerWebView,
        transaction: Transaction = .init(),
        @ViewBuilder overlay: @escaping (YouTubePlayer.State) -> Overlay
    ) {
        self.player = player
        self.webView = webView
        self.transaction = transaction
        self.overlay = overlay
    }
}

// MARK: - View

extension YouTubePlayerView: View {
    /// The content and behavior of the view
    public var body: some View {
        YouTubePlayerWebView.Representable(
            webView: self.webView
        )
        .overlay(
            self.overlay(self.state)
        )
        .preference(
            key: YouTubePlayer.PreferenceKey.self,
            value: self.player
        )
        .onReceive(
            self.player
                .statePublisher
                .receive(on: DispatchQueue.main)
        ) { state in
            withTransaction(self.transaction) {
                self.state = state
            }
        }
    }
}

// MARK: - YouTubePlayerWebView+Representable

public extension YouTubePlayerWebView {
    #if !os(macOS)
        /// The YouTubePlayer UIView SwiftUI Representable
        struct Representable: UIViewRepresentable {
            /// The YouTube Player
            let webView: YouTubePlayerWebView

            /// Make YouTubePlayerWebView
            /// - Parameter context: The Context
            /// - Returns: The YouTubePlayerWebView
            public func makeUIView(
                context _: Context
            ) -> YouTubePlayerWebView {
                webView
            }

            /// Update YouTubePlayerWebView
            /// - Parameters:
            ///   - uiView: The YouTubePlayerWebView
            ///   - context: The Context
            public func updateUIView(
                _ uiView: YouTubePlayerWebView,
                context _: Context
            ) {
                uiView.player = webView.player
            }
        }
    #else
        /// The YouTubePlayer NSView SwiftUI Representable
        struct Representable: NSViewRepresentable {
            /// The YouTube Player
            let webView: YouTubePlayerWebView

            /// Make YouTubePlayerWebView
            /// - Parameter context: The Context
            /// - Returns: The YouTubePlayerWebView
            func makeNSView(
                context _: Context
            ) -> YouTubePlayerWebView {
                webView
            }

            /// Update YouTubePlayerWebView
            /// - Parameters:
            ///   - nsView: The YouTubePlayerWebView
            ///   - context: The Context
            func updateNSView(
                _ nsView: YouTubePlayerWebView,
                context _: Context
            ) {
                nsView.player = webView.player
            }
        }
    #endif
}
