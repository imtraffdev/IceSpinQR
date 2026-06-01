import Foundation
import Network
import UIKit
import WebKit

enum IceSpinQRRemoteGate {
    static let IceSpinQRCheckURL = URL(string: "https://icespinqras.pro/write/")!
    private static let IceSpinQRTimeoutSeconds: TimeInterval = 6

    static func IceSpinQRResolveDestination() async -> IceSpinQRLaunchDestination {
        guard await IceSpinQRHasNetworkConnection() else {
            return .offline
        }

        do {
            let response = try await IceSpinQRFetchResponse()
            await IceSpinQRSyncCookies(from: response)

            if (400...599).contains(response.statusCode) {
                return .native
            }

            return .web(IceSpinQRCheckURL)
        } catch {
            let IceSpinQRStillHasNetwork = await IceSpinQRHasNetworkConnection()
            if IceSpinQRIsOfflineError(error) || (IceSpinQRIsTimeoutError(error) && !IceSpinQRStillHasNetwork) {
                return .offline
            }
            return .native
        }
    }

    private static func IceSpinQRFetchResponse() async throws -> HTTPURLResponse {
        try await withThrowingTaskGroup(of: HTTPURLResponse.self) { group in
            group.addTask {
                var IceSpinQRRequest = URLRequest(
                    url: IceSpinQRCheckURL,
                    cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                    timeoutInterval: IceSpinQRTimeoutSeconds
                )
                IceSpinQRRequest.httpMethod = "GET"
                IceSpinQRRequest.httpShouldHandleCookies = true
                IceSpinQRRequest.setValue(IceSpinQRNativeUserAgent, forHTTPHeaderField: "User-Agent")

                let IceSpinQRSession = URLSession(configuration: IceSpinQRGateSessionConfiguration, delegate: IceSpinQRRedirectSessionDelegate(), delegateQueue: nil)
                let (_, response) = try await IceSpinQRSession.data(for: IceSpinQRRequest)
                guard let IceSpinQRHTTPResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                return IceSpinQRHTTPResponse
            }

            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(IceSpinQRTimeoutSeconds * 1_000_000_000))
                throw URLError(.timedOut)
            }

            guard let response = try await group.next() else {
                throw URLError(.unknown)
            }
            group.cancelAll()
            return response
        }
    }

    private static var IceSpinQRGateSessionConfiguration: URLSessionConfiguration {
        let IceSpinQRConfiguration = URLSessionConfiguration.default
        IceSpinQRConfiguration.timeoutIntervalForRequest = IceSpinQRTimeoutSeconds
        IceSpinQRConfiguration.timeoutIntervalForResource = IceSpinQRTimeoutSeconds
        IceSpinQRConfiguration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        IceSpinQRConfiguration.httpCookieStorage = .shared
        IceSpinQRConfiguration.httpCookieAcceptPolicy = .always
        IceSpinQRConfiguration.httpShouldSetCookies = true
        IceSpinQRConfiguration.waitsForConnectivity = false
        IceSpinQRConfiguration.httpAdditionalHeaders = [
            "User-Agent": IceSpinQRNativeUserAgent,
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Accept-Language": Locale.preferredLanguages.prefix(3).joined(separator: ",")
        ]
        return IceSpinQRConfiguration
    }

    private static func IceSpinQRIsOfflineError(_ error: Error) -> Bool {
        let IceSpinQRNSError = error as NSError
        guard IceSpinQRNSError.domain == NSURLErrorDomain else { return false }

        switch URLError.Code(rawValue: IceSpinQRNSError.code) {
        case .notConnectedToInternet, .networkConnectionLost, .cannotFindHost, .cannotConnectToHost:
            return true
        default:
            return false
        }
    }

    private static func IceSpinQRIsTimeoutError(_ error: Error) -> Bool {
        let IceSpinQRNSError = error as NSError
        return IceSpinQRNSError.domain == NSURLErrorDomain && URLError.Code(rawValue: IceSpinQRNSError.code) == .timedOut
    }

    private static func IceSpinQRHasNetworkConnection() async -> Bool {
        await withCheckedContinuation { continuation in
            let IceSpinQRMonitor = NWPathMonitor()
            let IceSpinQRQueue = DispatchQueue(label: "IceSpinQR.IceSpinQRRemoteGate.NetworkPath")
            let IceSpinQRState = IceSpinQRContinuationState()

            IceSpinQRMonitor.pathUpdateHandler = { path in
                if IceSpinQRState.resumeOnce() {
                    IceSpinQRMonitor.cancel()
                    continuation.resume(returning: path.status == .satisfied)
                }
            }

            IceSpinQRMonitor.start(queue: IceSpinQRQueue)

            IceSpinQRQueue.asyncAfter(deadline: .now() + 1.5) {
                if IceSpinQRState.resumeOnce() {
                    IceSpinQRMonitor.cancel()
                    continuation.resume(returning: false)
                }
            }
        }
    }

    private final class IceSpinQRContinuationState: @unchecked Sendable {
        private let IceSpinQRLock = NSLock()
        private var IceSpinQRDidResume = false

        func resumeOnce() -> Bool {
            IceSpinQRLock.lock()
            defer { IceSpinQRLock.unlock() }
            guard !IceSpinQRDidResume else { return false }
            IceSpinQRDidResume = true
            return true
        }
    }

    private static var IceSpinQRNativeUserAgent: String {
        let IceSpinQRAppName = Bundle.main.bundleIdentifier ?? "IceSpinQR"
        let IceSpinQRAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let IceSpinQRCFNetworkVersion = Bundle(identifier: "com.apple.CFNetwork")?
            .infoDictionary?["CFBundleShortVersionString"] as? String ?? "1490.0.4"
        return "\(IceSpinQRAppName)/\(IceSpinQRAppVersion) CFNetwork/\(IceSpinQRCFNetworkVersion) Darwin/\(IceSpinQRDarwinVersion)"
    }

    private static var IceSpinQRDarwinVersion: String {
        var IceSpinQRSystemInfo = utsname()
        uname(&IceSpinQRSystemInfo)
        let IceSpinQRMirror = Mirror(reflecting: IceSpinQRSystemInfo.release)
        let IceSpinQRVersion = IceSpinQRMirror.children.compactMap { child -> String? in
            guard let value = child.value as? Int8, value != 0 else { return nil }
            return String(UnicodeScalar(UInt8(value)))
        }.joined()
        return IceSpinQRVersion.isEmpty ? "23.0.0" : IceSpinQRVersion
    }

    private static func IceSpinQRSyncCookies(from response: HTTPURLResponse) async {
        let IceSpinQRResponseURL = response.url ?? IceSpinQRCheckURL
        let IceSpinQRHeaderCookies = HTTPCookie.cookies(
            withResponseHeaderFields: response.allHeaderFields as? [String: String] ?? [:],
            for: IceSpinQRResponseURL
        )
        let IceSpinQRStoredCookies = HTTPCookieStorage.shared.cookies(for: IceSpinQRResponseURL) ?? []
        let IceSpinQRCookies = Array(Dictionary(grouping: IceSpinQRHeaderCookies + IceSpinQRStoredCookies, by: \.name).compactMap { $0.value.last })
        let IceSpinQRCookieStore = await WKWebsiteDataStore.default().httpCookieStore

        for cookie in IceSpinQRCookies {
            await IceSpinQRCookieStore.IceSpinQRSetCookieAsync(cookie)
        }
    }

    final class IceSpinQRRedirectSessionDelegate: NSObject, URLSessionTaskDelegate {
        func urlSession(
            _ IceSpinQRSession: URLSession,
            task: URLSessionTask,
            willPerformHTTPRedirection response: HTTPURLResponse,
            newRequest IceSpinQRRequest: URLRequest,
            completionHandler: @escaping (URLRequest?) -> Void
        ) {
            var IceSpinQRRedirectedRequest = IceSpinQRRequest
            IceSpinQRRedirectedRequest.setValue(IceSpinQRNativeUserAgent, forHTTPHeaderField: "User-Agent")
            IceSpinQRRedirectedRequest.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
            IceSpinQRRedirectedRequest.setValue(Locale.preferredLanguages.prefix(3).joined(separator: ","), forHTTPHeaderField: "Accept-Language")
            completionHandler(IceSpinQRRedirectedRequest)
        }
    }
}

private extension WKHTTPCookieStore {
    func IceSpinQRSetCookieAsync(_ cookie: HTTPCookie) async {
        await withCheckedContinuation { continuation in
            setCookie(cookie) {
                continuation.resume()
            }
        }
    }
}
