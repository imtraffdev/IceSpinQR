import SwiftUI

struct IceSpinQRRootView: View {
    @EnvironmentObject private var IceSpinQRStore: IceSpinQRLocalStore
    @State private var IceSpinQRLaunchStage = 0
    @State private var IceSpinQRLaunchProgress = 0.0
    @State private var IceSpinQRLaunchDestinationState: IceSpinQRLaunchDestination?
    @State private var IceSpinQRDidStartLaunch = false
    @State private var IceSpinQRToast: String?

    var body: some View {
        ZStack {
            IceSpinQRGlacierBackground()

            if let destination = IceSpinQRLaunchDestinationState {
                switch destination {
                case .native:
                    IceSpinQRNativeContent
                case .web(let url):
                    IceSpinQRGateWebContainer(url: url) {
                        var transaction = Transaction()
                        transaction.disablesAnimations = true
                        withTransaction(transaction) {
                            IceSpinQRLaunchDestinationState = .native
                        }
                    }
                    .transition(.opacity)
                case .offline:
                    IceSpinQRSplashView(stage: IceSpinQRLaunchStage, progress: IceSpinQRLaunchProgress, isOffline: true)
                        .transition(.opacity)
                }
            } else {
                IceSpinQRSplashView(stage: IceSpinQRLaunchStage, progress: IceSpinQRLaunchProgress)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.22), value: IceSpinQRLaunchDestinationState)
        .overlay(alignment: .bottom) {
            if case .native = IceSpinQRLaunchDestinationState, let IceSpinQRToast {
                IceSpinQRToastView(text: IceSpinQRToast)
                    .padding(.horizontal, 18)
                    .padding(.bottom, 12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .foregroundStyle(IceSpinQRTheme.foam)
        .tint(IceSpinQRTheme.cyan)
        .preferredColorScheme(.dark)
        .task { await IceSpinQRRunLaunchGate() }
    }

    @ViewBuilder
    private var IceSpinQRNativeContent: some View {
        if !IceSpinQRStore.isAuthenticated {
            IceSpinQRLoginView(IceSpinQRShowToast: IceSpinQRShowToast)
                .transition(.opacity)
        } else {
            IceSpinQRAppShell(IceSpinQRShowToast: IceSpinQRShowToast)
                .transition(.opacity)
        }
    }

    private func IceSpinQRRunLaunchGate() async {
        guard !IceSpinQRDidStartLaunch else { return }
        IceSpinQRDidStartLaunch = true

        async let splash: Void = IceSpinQRRunSplashSequence()
        async let gate = IceSpinQRRemoteGate.IceSpinQRResolveDestination()
        let destination = await gate
        _ = await splash

        withAnimation {
            IceSpinQRLaunchDestinationState = destination
        }
    }

    private func IceSpinQRRunSplashSequence() async {
        for step in 0...24 {
            await MainActor.run {
                IceSpinQRLaunchProgress = Double(step) / 24.0
                IceSpinQRLaunchStage = min(2, step / 8)
            }
            try? await Task.sleep(nanoseconds: 58_000_000)
        }
        try? await Task.sleep(nanoseconds: 260_000_000)
    }

    private func IceSpinQRShowToast(_ text: String) {
        withAnimation { IceSpinQRToast = text }
        Task {
            try? await Task.sleep(nanoseconds: 1_600_000_000)
            await MainActor.run {
                withAnimation {
                    if IceSpinQRToast == text { IceSpinQRToast = nil }
                }
            }
        }
    }
}
