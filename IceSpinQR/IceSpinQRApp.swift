import SwiftUI
import UIKit

@main
struct IceSpinQRApp: App {
    @UIApplicationDelegateAdaptor(IceSpinQRAppDelegate.self) private var appDelegate
    @StateObject private var IceSpinQRStore = IceSpinQRLocalStore()

    var body: some Scene {
        WindowGroup {
            IceSpinQRRootView()
                .environmentObject(IceSpinQRStore)
        }
    }
}

@MainActor
final class IceSpinQRAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        IceSpinQROrientationController.current
    }
}

@MainActor
enum IceSpinQROrientationController {
    static var current: UIInterfaceOrientationMask = .portrait {
        didSet {
            IceSpinQRRefreshSupportedInterfaceOrientations()
        }
    }

    private static func IceSpinQRRefreshSupportedInterfaceOrientations() {
        let windowScenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }

        for scene in windowScenes {
            for window in scene.windows {
                IceSpinQRUpdateSupportedInterfaceOrientations(from: window.rootViewController)
            }

            if #available(iOS 16.0, *) {
                scene.requestGeometryUpdate(.iOS(interfaceOrientations: current))
            }
        }
    }

    private static func IceSpinQRUpdateSupportedInterfaceOrientations(from viewController: UIViewController?) {
        viewController?.setNeedsUpdateOfSupportedInterfaceOrientations()

        if let navigationController = viewController as? UINavigationController {
            IceSpinQRUpdateSupportedInterfaceOrientations(from: navigationController.visibleViewController)
        }

        if let tabBarController = viewController as? UITabBarController {
            IceSpinQRUpdateSupportedInterfaceOrientations(from: tabBarController.selectedViewController)
        }

        if let presentedViewController = viewController?.presentedViewController {
            IceSpinQRUpdateSupportedInterfaceOrientations(from: presentedViewController)
        }
    }
}
