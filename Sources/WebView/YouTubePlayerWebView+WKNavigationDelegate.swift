import Foundation
import WebKit

// MARK: - WKNavigationDelegate

extension YouTubePlayerWebView: WKNavigationDelegate {
    
    /// WebView decide policy for NavigationAction
    /// - Parameters:
    ///   - webView: The WKWebView
    ///   - navigationAction: The WKNavigationAction
    ///   - decisionHandler: The decision handler
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        // Verify request URL is available
        guard let requestURL = navigationAction.request.url else {
            // Otherwise cancel navigation action
            return decisionHandler(.cancel)
        }
        // Check if scheme is ytplayer
        if requestURL.scheme == YouTubePlayer.JavaScriptEvent.scheme {
            // Check if JavaScriptEvent can be initialized from URL host
            if let javaScriptEvent = requestURL.host.flatMap(YouTubePlayer.JavaScriptEvent.init) {
                // Handle JavaScriptEvent
                self.handle(
                    javaScriptEvent: javaScriptEvent,
                    data: URLComponents(
                        url: requestURL,
                        resolvingAgainstBaseURL: false
                    )?
                    .queryItems?
                    .first { $0.name == YouTubePlayer.JavaScriptEvent.dataParameterName }?
                    .value
                )
            }
            // Cancel navigation action
            return decisionHandler(.cancel)
        }
        // Check if scheme is set to http or https
        if requestURL.scheme == "http" || requestURL.scheme == "https" {
            // Allow or cancel navigation action
            return decisionHandler(
                self.shouldAllowHTTPNavigation(to: requestURL) ? .allow : .cancel
            )
        }
        // Allow navigation action
        decisionHandler(.allow)
    }
    
}

// MARK: - Handle YouTube Player Event Callback

private extension YouTubePlayerWebView {
    
    /// Handle YouTubePlayer HTML JavaScriptEvent
    /// - Parameters:
    ///   - javaScriptEvent: The JavaScriptEvent
    ///   - data: The optional event data
    func handle(
        javaScriptEvent: YouTubePlayer.JavaScriptEvent,
        data: String?
    ) {
        // Switch on JavaScriptEvent
        switch javaScriptEvent {
        case .onIframeAPIReady:
            // Simply do nothing
            break
        case .onIframeAPIFailedToLoad:
            // Send error state
            self.stateSubject.send(.error(.iFrameAPIFailedToLoad))
        case .onReady:
            // Send ready state
            self.stateSubject.send(.ready)
            // Check if autoPlay is enabled
            if self.player.configuration.autoPlay == true {
                // Play Video
                self.play()
            }
        case .onStateChange:
            // Send VideoState
            data
                .flatMap(Int.init)
                .flatMap(YouTubePlayer.VideoState.init)
                .map(self.videoStateSubject.send)
        case .onPlaybackQualityChange:
            // Send PlaybackQuality
            data
                .flatMap(YouTubePlayer.PlaybackQuality.init)
                .map(self.playbackQualitySubject.send)
        case .onPlaybackRateChange:
            // Send PlaybackRate
            data
                .flatMap(YouTubePlayer.PlaybackRate.init)
                .map(self.playbackRateSubject.send)
        case .onError:
            // Send error state
            data
                .flatMap(Int.init)
                .flatMap(YouTubePlayer.Error.init)
                .map { .error($0) }
                .map(self.stateSubject.send)
        }
    }
    
}

// MARK: - Should allow HTTP Navigation for URL

private extension YouTubePlayerWebView {
    
    /// The valid URL RegularExpressions
    static let validURLRegularExpressions = [
        "^http(s)://(www.)youtube.com/embed/(.*)$",
        "^http(s)://pubads.g.doubleclick.net/pagead/conversion/",
        "^http(s)://accounts.google.com/o/oauth2/(.*)$",
        "^https://content.googleapis.com/static/proxy.html(.*)$",
        "^https://tpc.googlesyndication.com/sodar/(.*).html$"
    ]
    .compactMap { pattern in
        try? NSRegularExpression(
            pattern: pattern,
            options: .caseInsensitive
        )
    }
    
    /// Retrieve Bool value if should allow HTTP navigation to a given URL
    /// - Parameter url: The URL
    func shouldAllowHTTPNavigation(
        to url: URL
    ) -> Bool {
        // Check if Request URL host is equal to origin URL host
        if url.host?.lowercased() == self.originURL?.host?.lowercased() {
            // Allow navigation action
            return true
        }
        // For each valid URL RegularExpression
        for validURLRegularExpression in Self.validURLRegularExpressions {
            // Find first match in URL
            let match = validURLRegularExpression.firstMatch(
                in: url.absoluteString,
                options: .init(),
                range: .init(location: 0, length: url.absoluteString.count)
            )
            // Check if a match is available
            if match != nil {
                // Return true as URL is valid
                return true
            }
        }
        // Open URL
        UIApplication.shared.open(
            url,
            options: [.universalLinksOnly : false]
        )
        // Disallow URL
        return false
    }
    
}