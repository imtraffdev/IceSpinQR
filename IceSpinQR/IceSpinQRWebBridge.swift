import SwiftUI
import UIKit
import WebKit

final class IceSpinQRWebNavigationController: ObservableObject {
    @Published var IceSpinQRCanGoBack = false
    @Published var IceSpinQRCanGoForward = false

    private weak var IceSpinQRWebView: WKWebView?
    private var IceSpinQRStartURL: URL?

    func IceSpinQRAttach(_ IceSpinQRWebView: WKWebView, startURL: URL) {
        self.IceSpinQRWebView = IceSpinQRWebView
        self.IceSpinQRStartURL = startURL
        IceSpinQRUpdateState()
    }

    func IceSpinQRUpdateState() {
        IceSpinQRCanGoBack = IceSpinQRPreviousAllowedItem() != nil
        IceSpinQRCanGoForward = IceSpinQRWebView?.canGoForward ?? false
    }

    func IceSpinQRGoBack() {
        guard let IceSpinQRWebView, let item = IceSpinQRPreviousAllowedItem() else { return }
        IceSpinQRWebView.go(to: item)
        IceSpinQRUpdateStateSoon()
    }

    func IceSpinQRGoForward() {
        guard let IceSpinQRWebView, IceSpinQRWebView.canGoForward else { return }
        IceSpinQRWebView.goForward()
        IceSpinQRUpdateStateSoon()
    }

    private func IceSpinQRUpdateStateSoon() {
        IceSpinQRUpdateState()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.IceSpinQRUpdateState()
        }
    }

    private func IceSpinQRPreviousAllowedItem() -> WKBackForwardListItem? {
        guard let IceSpinQRWebView else { return nil }
        return IceSpinQRWebView.backForwardList.backList.reversed().first { item in
            !IceSpinQRIsStartURL(item.url)
        }
    }

    private func IceSpinQRIsStartURL(_ url: URL) -> Bool {
        guard let IceSpinQRStartURL else { return false }
        return IceSpinQRNormalizedURL(url) == IceSpinQRNormalizedURL(IceSpinQRStartURL)
    }

    private func IceSpinQRNormalizedURL(_ url: URL) -> String {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.fragment = nil
        var normalized = components?.url?.absoluteString ?? url.absoluteString
        while normalized.hasSuffix("/") {
            normalized.removeLast()
        }
        return normalized.lowercased()
    }
}

struct IceSpinQRGateWebContainer: View {
    let IceSpinQRURL: URL
    let IceSpinQROnBlockedResponse: () -> Void
    @State private var IceSpinQRIsWebViewVisible = false
    @StateObject private var IceSpinQRNavigationController = IceSpinQRWebNavigationController()

    init(url: URL, onBlockedResponse: @escaping () -> Void) {
        self.IceSpinQRURL = url
        self.IceSpinQROnBlockedResponse = onBlockedResponse
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            IceSpinQRGateWebView(url: IceSpinQRURL, onReady: {
                IceSpinQRIsWebViewVisible = true
            }, onBlockedResponse: IceSpinQROnBlockedResponse, onWebViewReady: { IceSpinQRWebView in
                IceSpinQRNavigationController.IceSpinQRAttach(IceSpinQRWebView, startURL: IceSpinQRURL)
            }, onNavigationStateChange: { IceSpinQRCanGoBack, IceSpinQRCanGoForward in
                IceSpinQRNavigationController.IceSpinQRUpdateState()
            })
            .background(Color.black)
            .opacity(IceSpinQRIsWebViewVisible ? 1 : 0)

            IceSpinQRWebNavigationOverlay(
                IceSpinQRCanGoBack: IceSpinQRNavigationController.IceSpinQRCanGoBack,
                IceSpinQRCanGoForward: IceSpinQRNavigationController.IceSpinQRCanGoForward,
                IceSpinQRGoBack: IceSpinQRNavigationController.IceSpinQRGoBack,
                IceSpinQRGoForward: IceSpinQRNavigationController.IceSpinQRGoForward
            )
            .opacity(IceSpinQRIsWebViewVisible ? 1 : 0)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            IceSpinQROrientationController.current = UIDevice.current.userInterfaceIdiom == .pad ? .all : .allButUpsideDown
        }
        .onDisappear {
            IceSpinQROrientationController.current = .portrait
        }
    }
}

struct IceSpinQRGateWebView: UIViewRepresentable {
    let url: URL
    let onReady: () -> Void
    let onBlockedResponse: () -> Void
    let onWebViewReady: (WKWebView) -> Void
    let onNavigationStateChange: (Bool, Bool) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(
            onReady: onReady,
            onBlockedResponse: onBlockedResponse,
            onNavigationStateChange: onNavigationStateChange
        )
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsAirPlayForMediaPlayback = true
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.customUserAgent = IceSpinQRWebUserAgent.IceSpinQRSafariLike
        webView.isOpaque = true
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        context.coordinator.webView = webView
        onWebViewReady(webView)
        webView.load(IceSpinQRWebUserAgent.IceSpinQRSafariRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        let onReady: () -> Void
        let onBlockedResponse: () -> Void
        let onNavigationStateChange: (Bool, Bool) -> Void
        weak var webView: WKWebView?

        init(
            onReady: @escaping () -> Void,
            onBlockedResponse: @escaping () -> Void,
            onNavigationStateChange: @escaping (Bool, Bool) -> Void
        ) {
            self.onReady = onReady
            self.onBlockedResponse = onBlockedResponse
            self.onNavigationStateChange = onNavigationStateChange
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            if navigationAction.targetFrame == nil, ["http", "https"].contains(url.scheme?.lowercased()) {
                webView.load(navigationAction.request)
                decisionHandler(.cancel)
                return
            }

            if let scheme = url.scheme?.lowercased(), !["http", "https", "about"].contains(scheme) {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }

            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            IceSpinQRUpdateNavigationState(webView)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            IceSpinQRUpdateNavigationState(webView)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            IceSpinQRUpdateNavigationState(webView)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            IceSpinQRUpdateNavigationState(webView)
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            if navigationResponse.isForMainFrame,
               let response = navigationResponse.response as? HTTPURLResponse,
               (400...599).contains(response.statusCode) {
                decisionHandler(.cancel)
                DispatchQueue.main.async { [onBlockedResponse] in
                    onBlockedResponse()
                }
                return
            }

            if navigationResponse.isForMainFrame {
                DispatchQueue.main.async { [onReady] in
                    onReady()
                }
            }

            decisionHandler(.allow)
        }

        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            if let requestURL = navigationAction.request.url {
                webView.load(IceSpinQRWebUserAgent.IceSpinQRSafariRequest(url: requestURL))
            } else {
                webView.load(navigationAction.request)
            }
            return nil
        }

        func webViewDidClose(_ webView: WKWebView) {
            self.webView?.goBack()
        }

        func webView(
            _ webView: WKWebView,
            runJavaScriptAlertPanelWithMessage message: String,
            initiatedByFrame frame: WKFrameInfo,
            completionHandler: @escaping () -> Void
        ) {
            IceSpinQRPresentWebDialog(
                title: webView.url?.host ?? "Message",
                message: message,
                actions: [UIAlertAction(title: "OK", style: .default) { _ in completionHandler() }],
                fallback: completionHandler
            )
        }

        func webView(
            _ webView: WKWebView,
            runJavaScriptConfirmPanelWithMessage message: String,
            initiatedByFrame frame: WKFrameInfo,
            completionHandler: @escaping (Bool) -> Void
        ) {
            IceSpinQRPresentWebDialog(
                title: webView.url?.host ?? "Confirm",
                message: message,
                actions: [
                    UIAlertAction(title: "Cancel", style: .cancel) { _ in completionHandler(false) },
                    UIAlertAction(title: "OK", style: .default) { _ in completionHandler(true) }
                ],
                fallback: { completionHandler(false) }
            )
        }

        func webView(
            _ webView: WKWebView,
            runJavaScriptTextInputPanelWithPrompt prompt: String,
            defaultText: String?,
            initiatedByFrame frame: WKFrameInfo,
            completionHandler: @escaping (String?) -> Void
        ) {
            let alert = UIAlertController(title: webView.url?.host ?? "Input", message: prompt, preferredStyle: .alert)
            alert.addTextField { textField in
                textField.text = defaultText
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completionHandler(nil) })
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completionHandler(alert.textFields?.first?.text)
            })

            IceSpinQRPresentAlertController(alert, fallback: { completionHandler(nil) })
        }

        func webView(
            _ webView: WKWebView,
            requestMediaCapturePermissionFor origin: WKSecurityOrigin,
            initiatedByFrame frame: WKFrameInfo,
            type: WKMediaCaptureType,
            decisionHandler: @escaping (WKPermissionDecision) -> Void
        ) {
            decisionHandler(.prompt)
        }

        private func IceSpinQRUpdateNavigationState(_ webView: WKWebView) {
            DispatchQueue.main.async { [onNavigationStateChange] in
                onNavigationStateChange(webView.canGoBack, webView.canGoForward)
            }
        }

        private func IceSpinQRPresentWebDialog(
            title: String,
            message: String,
            actions: [UIAlertAction],
            fallback: @escaping () -> Void
        ) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            actions.forEach(alert.addAction)
            IceSpinQRPresentAlertController(alert, fallback: fallback)
        }

        private func IceSpinQRPresentAlertController(_ alert: UIAlertController, fallback: @escaping () -> Void) {
            DispatchQueue.main.async {
                guard let presenter = UIApplication.shared.IceSpinQRTopMostViewController() else {
                    fallback()
                    return
                }

                if presenter.presentedViewController == nil {
                    presenter.present(alert, animated: true)
                } else {
                    fallback()
                }
            }
        }
    }
}

struct IceSpinQRWebNavigationOverlay: View {
    var IceSpinQRCanGoBack: Bool
    var IceSpinQRCanGoForward: Bool
    var IceSpinQRGoBack: () -> Void
    var IceSpinQRGoForward: () -> Void

    var body: some View {
        GeometryReader { proxy in
            VStack {
                Spacer()
                HStack(spacing: 10) {
                    IceSpinQRNavButton(direction: .left, enabled: IceSpinQRCanGoBack, action: IceSpinQRGoBack)
                    IceSpinQRNavButton(direction: .right, enabled: IceSpinQRCanGoForward, action: IceSpinQRGoForward)
                }
                .padding(8)
                .background(Color.black.opacity(0.42), in: Capsule())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 14)
                .padding(.bottom, max(6, proxy.safeAreaInsets.bottom - 18))
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }

    private func IceSpinQRNavButton(direction: IceSpinQRWebArrowDirection, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            IceSpinQRWebArrow(direction: direction, color: enabled ? Color.white : Color.white.opacity(0.28))
                .frame(width: 13, height: 13)
                .frame(width: 32, height: 32)
                .background(Color.white.opacity(enabled ? 0.14 : 0.06), in: Circle())
                .contentShape(Circle())
        }
        .disabled(!enabled)
        .buttonStyle(.plain)
        .allowsHitTesting(enabled)
    }
}

private enum IceSpinQRWebArrowDirection {
    case left
    case right
}

private struct IceSpinQRWebArrow: View {
    var direction: IceSpinQRWebArrowDirection
    var color: Color

    var body: some View {
        IceSpinQRGlyph(kind: .arrow, color: color, lineWidth: 3)
            .rotationEffect(.degrees(direction == .left ? 180 : 0))
    }
}

private enum IceSpinQRWebUserAgent {
    static var IceSpinQRSafariLike: String {
        let osVersion = UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "_")
        let majorVersion = UIDevice.current.systemVersion.split(separator: ".").first.map(String.init) ?? "18"
        return "Mozilla/5.0 (iPhone; CPU iPhone OS \(osVersion) like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/\(majorVersion).0 Mobile/15E148 Safari/604.1"
    }

    static func IceSpinQRSafariRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url, timeoutInterval: 30)
        request.setValue(IceSpinQRSafariLike, forHTTPHeaderField: "User-Agent")
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue(Locale.preferredLanguages.prefix(3).joined(separator: ","), forHTTPHeaderField: "Accept-Language")
        return request
    }
}

private extension UIApplication {
    func IceSpinQRTopMostViewController(
        base: UIViewController? = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }?
            .rootViewController
    ) -> UIViewController? {
        if let navigationController = base as? UINavigationController {
            return IceSpinQRTopMostViewController(base: navigationController.visibleViewController)
        }

        if let tabBarController = base as? UITabBarController {
            return IceSpinQRTopMostViewController(base: tabBarController.selectedViewController)
        }

        if let presented = base?.presentedViewController {
            return IceSpinQRTopMostViewController(base: presented)
        }

        return base
    }
}
