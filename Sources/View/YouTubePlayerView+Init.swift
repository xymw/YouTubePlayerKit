import Foundation
import SwiftUI

// MARK: - Initializer with no Overlay

public extension YouTubePlayerView where Overlay == EmptyView {
    /// Creates a new instance of `YouTubePlayer.View`
    /// - Parameter player: The YouTubePlayer
    init(
        _ player: YouTubePlayer,
        webView: YouTubePlayerWebView
    ) {
        self.init(player, webView: webView) { _ in
            EmptyView()
        }
    }
}

// MARK: - Initializer with Placeholder Overlay

public extension YouTubePlayerView {
    /// Creates a new instance of `YouTubePlayer.View`
    /// - Parameters:
    ///   - player: The YouTube Player
    ///   - transaction: The transaction to use when the `YouTubePlayer.State` changes. Default value `.init()`
    ///   - placeholderOverlay: The placeholder overlay which is visible during `idle` and `error` state
    init<PlaceholderOverlay: View>(
        _ player: YouTubePlayer,
        webView: YouTubePlayerWebView,
        transaction: Transaction = .init(),
        @ViewBuilder placeholderOverlay: @escaping () -> PlaceholderOverlay
    ) where Overlay == _ConditionalContent<EmptyView, PlaceholderOverlay> {
        self.init(
            player,
            webView: webView,
            transaction: transaction
        ) { state in
            if state.isReady {
                EmptyView()
            } else {
                placeholderOverlay()
            }
        }
    }
}

// MARK: - Initializer with Idle, Ready and Error Overlay

public extension YouTubePlayerView {
    /// Creates a new instance of `YouTubePlayer.View`
    /// - Parameters:
    ///   - player: The YouTube Player
    ///   - transaction: The transaction to use when the `YouTubePlayer.State` changes. Default value `.init()`
    ///   - idleOverlay: The idle overlay
    ///   - readyOverlay: The ready overlay
    ///   - errorOverlay: The error overlay
    init<IdleOverlay: View, ReadyOverlay: View, ErrorOverlay: View>(
        _ player: YouTubePlayer,
        webView: YouTubePlayerWebView,
        transaction: Transaction = .init(),
        @ViewBuilder idleOverlay: @escaping () -> IdleOverlay,

        @ViewBuilder readyOverlay: @escaping () -> ReadyOverlay,

        @ViewBuilder errorOverlay: @escaping (YouTubePlayer.Error) -> ErrorOverlay
    ) where Overlay == _ConditionalContent<_ConditionalContent<IdleOverlay, ReadyOverlay>, ErrorOverlay> {
        self.init(
            player,
            webView: webView,
            transaction: transaction
        ) { state in
            switch state {
            case .idle:
                idleOverlay()
            case .ready:
                readyOverlay()
            case let .error(playerError):
                errorOverlay(playerError)
            }
        }
    }
}

// MARK: - Initializer with Idle Overlay

public extension YouTubePlayerView {
    /// Creates a new instance of `YouTubePlayer.View`
    /// - Parameters:
    ///   - player: The YouTube Player
    ///   - transaction: The transaction to use when the `YouTubePlayer.State` changes. Default value `.init()`
    ///   - idleOverlay: The idle overlay
    init<IdleOverlay: View>(
        _ player: YouTubePlayer,
        webView: YouTubePlayerWebView,
        transaction: Transaction = .init(),
        @ViewBuilder idleOverlay: @escaping () -> IdleOverlay
    ) where Overlay == _ConditionalContent<_ConditionalContent<IdleOverlay, EmptyView>, EmptyView> {
        self.init(
            player,
            webView: webView,
            transaction: transaction
        ) { state in
            switch state {
            case .idle:
                idleOverlay()
            case .ready:
                EmptyView()
            case .error:
                EmptyView()
            }
        }
    }
}

// MARK: - Initializer with Idle and Ready Overlay

public extension YouTubePlayerView {
    /// Creates a new instance of `YouTubePlayer.View`
    /// - Parameters:
    ///   - player: The YouTube Player
    ///   - transaction: The transaction to use when the `YouTubePlayer.State` changes. Default value `.init()`
    ///   - idleOverlay: The idle overlay
    ///   - readyOverlay: The ready overlay
    init<IdleOverlay: View, ReadyOverlay: View>(
        _ player: YouTubePlayer,
        webView: YouTubePlayerWebView,
        transaction: Transaction = .init(),
        @ViewBuilder idleOverlay: @escaping () -> IdleOverlay,

        @ViewBuilder readyOverlay: @escaping () -> ReadyOverlay
    ) where Overlay == _ConditionalContent<_ConditionalContent<IdleOverlay, ReadyOverlay>, EmptyView> {
        self.init(
            player,
            webView: webView,
            transaction: transaction
        ) { state in
            switch state {
            case .idle:
                idleOverlay()
            case .ready:
                readyOverlay()
            case .error:
                EmptyView()
            }
        }
    }
}

// MARK: - Initializer with Ready Overlay

public extension YouTubePlayerView {
    /// Creates a new instance of `YouTubePlayer.View`
    /// - Parameters:
    ///   - player: The YouTube Player
    ///   - transaction: The transaction to use when the `YouTubePlayer.State` changes. Default value `.init()`
    ///   - readyOverlay: The ready overlay
    init<ReadyOverlay: View>(
        _ player: YouTubePlayer,
        webView: YouTubePlayerWebView,
        transaction: Transaction = .init(),
        @ViewBuilder readyOverlay: @escaping () -> ReadyOverlay
    ) where Overlay == _ConditionalContent<_ConditionalContent<EmptyView, ReadyOverlay>, EmptyView> {
        self.init(
            player,
            webView: webView,
            transaction: transaction
        ) { state in
            switch state {
            case .idle:
                EmptyView()
            case .ready:
                readyOverlay()
            case .error:
                EmptyView()
            }
        }
    }
}

// MARK: - Initializer with Ready and Error Overlay

public extension YouTubePlayerView {
    /// Creates a new instance of `YouTubePlayer.View`
    /// - Parameters:
    ///   - player: The YouTube Player
    ///   - transaction: The transaction to use when the `YouTubePlayer.State` changes. Default value `.init()`
    ///   - readyOverlay: The ready overlay
    ///   - errorOverlay: The error overlay
    init<ReadyOverlay: View, ErrorOverlay: View>(
        _ player: YouTubePlayer,
        webView: YouTubePlayerWebView,
        transaction: Transaction = .init(),
        @ViewBuilder readyOverlay: @escaping () -> ReadyOverlay,

        @ViewBuilder errorOverlay: @escaping (YouTubePlayer.Error) -> ErrorOverlay
    ) where Overlay == _ConditionalContent<_ConditionalContent<EmptyView, ReadyOverlay>, ErrorOverlay> {
        self.init(
            player,
            webView: webView,
            transaction: transaction
        ) { state in
            switch state {
            case .idle:
                EmptyView()
            case .ready:
                readyOverlay()
            case let .error(playerError):
                errorOverlay(playerError)
            }
        }
    }
}

// MARK: - Initializer with Error Overlay

public extension YouTubePlayerView {
    /// Creates a new instance of `YouTubePlayer.View`
    /// - Parameters:
    ///   - player: The YouTube Player
    ///   - transaction: The transaction to use when the `YouTubePlayer.State` changes. Default value `.init()`
    ///   - errorOverlay: The error overlay
    init<ErrorOverlay: View>(
        _ player: YouTubePlayer,
        webView: YouTubePlayerWebView,
        transaction: Transaction = .init(),
        @ViewBuilder errorOverlay: @escaping (YouTubePlayer.Error) -> ErrorOverlay
    ) where Overlay == _ConditionalContent<_ConditionalContent<EmptyView, EmptyView>, ErrorOverlay> {
        self.init(
            player,
            webView: webView,
            transaction: transaction
        ) { state in
            switch state {
            case .idle:
                EmptyView()
            case .ready:
                EmptyView()
            case let .error(playerError):
                errorOverlay(playerError)
            }
        }
    }
}
