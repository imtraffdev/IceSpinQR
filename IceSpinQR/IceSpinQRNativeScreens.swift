import CoreImage.CIFilterBuiltins
import SwiftUI
import UIKit

struct IceSpinQRLoginView: View {
    @EnvironmentObject private var IceSpinQRStore: IceSpinQRLocalStore
    @State private var IceSpinQRLogin = ""
    @State private var IceSpinQRPassword = ""
    @State private var IceSpinQRError = ""
    var IceSpinQRShowToast: (String) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                Spacer(minLength: 54)
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 245)
                    .shadow(color: IceSpinQRTheme.cyan.opacity(0.42), radius: 24, y: 10)

                VStack(alignment: .leading, spacing: 9) {
                    Text("Secure Access")
                        .font(.system(size: 34, weight: .black))
                    Text("Sign in to manage QR rewards, event registrations and loyalty privileges.")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(IceSpinQRTheme.muted)
                        .lineSpacing(3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 14) {
                    TextField("Username", text: $IceSpinQRLogin)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .IceSpinQRInputStyle()
                    SecureField("Password", text: $IceSpinQRPassword)
                        .IceSpinQRInputStyle()
                    if !IceSpinQRError.isEmpty {
                        Text(IceSpinQRError)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(IceSpinQRTheme.warning)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Button("Sign In") {
                        IceSpinQRHaptics.IceSpinQRTap()
                        if IceSpinQRStore.IceSpinQRAuthenticate(login: IceSpinQRLogin, password: IceSpinQRPassword) {
                            IceSpinQRError = ""
                            IceSpinQRShowToast("Signed in")
                        } else {
                            IceSpinQRError = "Incorrect username or password."
                            IceSpinQRHaptics.IceSpinQRWarning()
                        }
                    }
                    .buttonStyle(IceSpinQRPrimaryButtonStyle())
                }
                .padding(18)
                .IceSpinQRPanel(cornerRadius: 26)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 22)
        }
        .scrollIndicators(.hidden)
    }
}

struct IceSpinQRAppShell: View {
    @State private var IceSpinQRSelectedTab: IceSpinQRNavigationTab = .rewards
    var IceSpinQRShowToast: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $IceSpinQRSelectedTab) {
                IceSpinQRRewardsScreen(IceSpinQRShowToast: IceSpinQRShowToast).tag(IceSpinQRNavigationTab.rewards)
                IceSpinQREventsScreen(IceSpinQRShowToast: IceSpinQRShowToast).tag(IceSpinQRNavigationTab.events)
                IceSpinQRScanScreen(IceSpinQRShowToast: IceSpinQRShowToast).tag(IceSpinQRNavigationTab.scan)
                IceSpinQRPrivilegesScreen(IceSpinQRShowToast: IceSpinQRShowToast).tag(IceSpinQRNavigationTab.privileges)
                IceSpinQRProfileScreen(IceSpinQRShowToast: IceSpinQRShowToast).tag(IceSpinQRNavigationTab.profile)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            IceSpinQRBottomTabBar(IceSpinQRSelectedTab: $IceSpinQRSelectedTab)
        }
    }
}

struct IceSpinQRRewardsScreen: View {
    @EnvironmentObject private var IceSpinQRStore: IceSpinQRLocalStore
    @State private var IceSpinQRPresentedReward: IceSpinQRReward?
    var IceSpinQRShowToast: (String) -> Void

    var body: some View {
        IceSpinQRScreen(title: "Track Rewards", subtitle: "Generate temporary QR keys") {
            IceSpinQRStatsGrid()
            ForEach(IceSpinQRStore.IceSpinQRRewards) { reward in
                IceSpinQRRewardCard(reward: reward, onActivate: {
                    IceSpinQRStore.IceSpinQRActivateReward(reward)
                    IceSpinQRPresentedReward = IceSpinQRStore.IceSpinQRRewards.first { $0.id == reward.id }
                    IceSpinQRShowToast("Reward QR generated")
                }, onShow: {
                    IceSpinQRPresentedReward = reward
                }, onRedeem: {
                    IceSpinQRStore.IceSpinQRRedeemReward(reward)
                    IceSpinQRShowToast("Reward marked redeemed")
                })
            }
        }
        .sheet(item: $IceSpinQRPresentedReward) { reward in
            IceSpinQRFullQRSheet(title: reward.title, detail: reward.detail, payload: reward.qrPayload)
        }
    }
}

struct IceSpinQREventsScreen: View {
    @EnvironmentObject private var IceSpinQRStore: IceSpinQRLocalStore
    @State private var IceSpinQRPresentedEvent: IceSpinQREvent?
    var IceSpinQRShowToast: (String) -> Void

    var body: some View {
        IceSpinQRScreen(title: "Register For Events", subtitle: "Create personal entry passes") {
            ForEach(IceSpinQRStore.IceSpinQREvents) { event in
                IceSpinQREventCard(event: event, onRegister: {
                    IceSpinQRStore.IceSpinQRRegister(event: event)
                    IceSpinQRPresentedEvent = IceSpinQRStore.IceSpinQREvents.first { $0.id == event.id }
                    IceSpinQRShowToast("Event registration created")
                }, onShow: {
                    IceSpinQRPresentedEvent = event
                })
            }
        }
        .sheet(item: $IceSpinQRPresentedEvent) { event in
            IceSpinQRFullQRSheet(title: event.title, detail: event.location, payload: event.qrPayload)
        }
    }
}

struct IceSpinQRScanScreen: View {
    @EnvironmentObject private var IceSpinQRStore: IceSpinQRLocalStore
    @State private var IceSpinQRManualCode = ""
    var IceSpinQRShowToast: (String) -> Void

    var body: some View {
        IceSpinQRScreen(title: "Scan & Confirm", subtitle: "Manual fallback for QR codes") {
            VStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(.black.opacity(0.34))
                        .frame(height: 290)
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(IceSpinQRTheme.cyan.opacity(0.55), lineWidth: 1.4)
                    IceSpinQRScannerFrame()
                        .stroke(IceSpinQRTheme.iceSilver, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 205, height: 205)
                    VStack(spacing: 7) {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.system(size: 42, weight: .semibold))
                        Text("Camera scanner preview")
                            .font(.system(size: 15, weight: .black))
                        Text("Use manual input in simulator or when scanning is unavailable.")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(IceSpinQRTheme.muted)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 32)
                }

                TextField("Enter QR or access code", text: $IceSpinQRManualCode)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .IceSpinQRInputStyle()

                Button("Confirm Code") {
                    let result = IceSpinQRStore.IceSpinQRSubmitManualCode(IceSpinQRManualCode)
                    IceSpinQRShowToast(result)
                    if result != "Enter a valid QR or access code." {
                        IceSpinQRManualCode = ""
                    }
                }
                .buttonStyle(IceSpinQRPrimaryButtonStyle())
            }
            .padding(16)
            .IceSpinQRPanel(cornerRadius: 28)

            IceSpinQRSectionTitle("Recent activity")
            ForEach(IceSpinQRStore.IceSpinQRScanHistory.prefix(6)) { record in
                IceSpinQRHistoryRow(record: record)
            }
        }
    }
}

struct IceSpinQRPrivilegesScreen: View {
    @EnvironmentObject private var IceSpinQRStore: IceSpinQRLocalStore
    var IceSpinQRShowToast: (String) -> Void

    var body: some View {
        IceSpinQRScreen(title: "Manage Privileges", subtitle: "Verify loyalty access") {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(IceSpinQRStore.IceSpinQRProfileState.loyaltyTier)
                            .font(.system(size: 31, weight: .black))
                        Text("\(IceSpinQRStore.IceSpinQRProfileState.loyaltyPoints) loyalty points")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(IceSpinQRTheme.muted)
                    }
                    Spacer()
                    Image(systemName: "snowflake.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(IceSpinQRTheme.cyan)
                }
                ProgressView(value: 0.84)
                    .tint(IceSpinQRTheme.cyan)
            }
            .padding(18)
            .IceSpinQRPanel(cornerRadius: 28)

            ForEach(IceSpinQRStore.IceSpinQRPrivileges) { privilege in
                IceSpinQRPrivilegeCard(privilege: privilege) {
                    IceSpinQRStore.IceSpinQRVerifyPrivilege(privilege)
                    IceSpinQRShowToast("Privilege verified")
                }
            }
        }
    }
}

struct IceSpinQRProfileScreen: View {
    @EnvironmentObject private var IceSpinQRStore: IceSpinQRLocalStore
    @State private var IceSpinQRShowsDeleteConfirmation = false
    var IceSpinQRShowToast: (String) -> Void

    var body: some View {
        IceSpinQRScreen(title: "Profile", subtitle: "Loyalty identity") {
            VStack(spacing: 14) {
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 180)
                Text(IceSpinQRStore.IceSpinQRProfileState.name)
                    .font(.system(size: 30, weight: .black))
                Text("@\(IceSpinQRStore.IceSpinQRProfileState.username)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(IceSpinQRTheme.muted)
                IceSpinQRQRCodeView(payload: "ICE-TIER-\(IceSpinQRStore.IceSpinQRProfileState.loyaltyTier)-\(IceSpinQRStore.IceSpinQRProfileState.username.uppercased())")
                    .frame(width: 142, height: 142)
                    .padding(10)
                    .background(.white, in: RoundedRectangle(cornerRadius: 18))
            }
            .frame(maxWidth: .infinity)
            .padding(18)
            .IceSpinQRPanel(cornerRadius: 30)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                IceSpinQRMiniStat(title: "Scans", value: "\(IceSpinQRStore.IceSpinQRProfileState.scans)")
                IceSpinQRMiniStat(title: "Rewards", value: "\(IceSpinQRStore.IceSpinQRProfileState.activatedRewards)")
                IceSpinQRMiniStat(title: "Events", value: "\(IceSpinQRStore.IceSpinQRProfileState.registeredEvents)")
                IceSpinQRMiniStat(title: "Tier", value: IceSpinQRStore.IceSpinQRProfileState.loyaltyTier)
            }

            Button("Sign Out") {
                IceSpinQRStore.IceSpinQRSignOut()
                IceSpinQRShowToast("Signed out")
            }
            .buttonStyle(IceSpinQRSecondaryButtonStyle())

            Button("Delete Profile") {
                IceSpinQRShowsDeleteConfirmation = true
            }
            .buttonStyle(IceSpinQRDestructiveButtonStyle())
        }
        .alert("Delete Profile?", isPresented: $IceSpinQRShowsDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                IceSpinQRStore.IceSpinQRDeleteProfile()
            }
        } message: {
            Text("This removes local profile data, QR history, reward states, event registrations and privilege settings from this device.")
        }
    }
}

struct IceSpinQRScreen<Content: View>: View {
    var title: String
    var subtitle: String
    @ViewBuilder var content: Content

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                IceSpinQRHeaderBlock(title: title, subtitle: subtitle, detail: "Ice Spin Casino QR keeps venue actions quick: scan, confirm, generate a secure code and continue.")
                content
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
    }
}

struct IceSpinQRStatsGrid: View {
    @EnvironmentObject private var IceSpinQRStore: IceSpinQRLocalStore

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(IceSpinQRStore.IceSpinQRStats) { stat in
                VStack(alignment: .leading, spacing: 8) {
                    IceSpinQRGlyph(kind: stat.glyph, color: IceSpinQRTheme.cyan)
                        .frame(width: 24, height: 24)
                    Text(stat.value)
                        .font(.system(size: 25, weight: .black))
                    Text(stat.title)
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(IceSpinQRTheme.muted)
                    Text(stat.detail)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(IceSpinQRTheme.muted.opacity(0.75))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .IceSpinQRPanel(cornerRadius: 20)
            }
        }
    }
}

struct IceSpinQRRewardCard: View {
    var reward: IceSpinQRReward
    var onActivate: () -> Void
    var onShow: () -> Void
    var onRedeem: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(reward.title)
                        .font(.system(size: 21, weight: .black))
                    Text(reward.detail)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(IceSpinQRTheme.muted)
                }
                Spacer()
                IceSpinQRStatusPill(reward.state.rawValue, color: reward.state == .ready ? IceSpinQRTheme.cyan : IceSpinQRTheme.success)
            }
            HStack {
                IceSpinQRSmallInfo(title: "Tier", value: reward.tier)
                IceSpinQRSmallInfo(title: "Expires", value: reward.expiresAt.formatted(date: .abbreviated, time: .omitted))
            }
            HStack(spacing: 12) {
                Button(reward.state == .ready ? "Generate QR" : "Show QR") {
                    reward.state == .ready ? onActivate() : onShow()
                }
                .buttonStyle(IceSpinQRPrimaryButtonStyle())
                Button("Mark Redeemed", action: onRedeem)
                    .disabled(reward.state == .redeemed)
                    .buttonStyle(IceSpinQRSecondaryButtonStyle())
            }
        }
        .padding(16)
        .IceSpinQRPanel(cornerRadius: 26)
    }
}

struct IceSpinQREventCard: View {
    var event: IceSpinQREvent
    var onRegister: () -> Void
    var onShow: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(event.title)
                        .font(.system(size: 22, weight: .black))
                    Text(event.location)
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(IceSpinQRTheme.cyan)
                }
                Spacer()
                IceSpinQRStatusPill(event.state.rawValue, color: event.state == .open ? IceSpinQRTheme.iceSilver : IceSpinQRTheme.success)
            }
            Text(event.detail)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(IceSpinQRTheme.muted)
            HStack {
                IceSpinQRSmallInfo(title: "Date", value: event.date.formatted(date: .abbreviated, time: .shortened))
                IceSpinQRSmallInfo(title: "Tier", value: event.requiredTier)
            }
            Button(event.state == .open ? "Register" : "Show Entry QR") {
                event.state == .open ? onRegister() : onShow()
            }
            .buttonStyle(IceSpinQRPrimaryButtonStyle())
        }
        .padding(16)
        .IceSpinQRPanel(cornerRadius: 26)
    }
}

struct IceSpinQRPrivilegeCard: View {
    var privilege: IceSpinQRPrivilege
    var onVerify: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: privilege.symbol)
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(privilege.isEnabled ? IceSpinQRTheme.cyan : IceSpinQRTheme.muted)
                .frame(width: 48, height: 48)
                .background(Color.white.opacity(0.08), in: Circle())
            VStack(alignment: .leading, spacing: 5) {
                Text(privilege.title)
                    .font(.system(size: 17, weight: .black))
                Text(privilege.detail)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(IceSpinQRTheme.muted)
            }
            Spacer()
            Button(privilege.isEnabled ? "Verified" : "Verify", action: onVerify)
                .font(.system(size: 11, weight: .black))
                .foregroundStyle(privilege.isEnabled ? IceSpinQRTheme.success : IceSpinQRTheme.midnight)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(privilege.isEnabled ? IceSpinQRTheme.success.opacity(0.12) : IceSpinQRTheme.cyan, in: Capsule())
        }
        .padding(14)
        .IceSpinQRPanel(cornerRadius: 22)
    }
}

struct IceSpinQRFullQRSheet: View {
    var title: String
    var detail: String
    var payload: String

    var body: some View {
        ZStack {
            IceSpinQRGlacierBackground()
            VStack(spacing: 18) {
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 185)
                Text(title)
                    .font(.system(size: 26, weight: .black))
                    .multilineTextAlignment(.center)
                Text(detail)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(IceSpinQRTheme.muted)
                    .multilineTextAlignment(.center)
                IceSpinQRQRCodeView(payload: payload)
                    .frame(width: 248, height: 248)
                    .padding(16)
                    .background(.white, in: RoundedRectangle(cornerRadius: 28))
                Text(payload)
                    .font(.system(size: 12, weight: .black, design: .monospaced))
                    .foregroundStyle(IceSpinQRTheme.iceSilver)
            }
            .padding(24)
        }
        .presentationDetents([.large])
    }
}

struct IceSpinQRQRCodeView: View {
    static let IceSpinQRContext = CIContext()
    static let IceSpinQRFilter = CIFilter.qrCodeGenerator()
    var payload: String

    var body: some View {
        if let image = IceSpinQRMakeQR(payload) {
            Image(uiImage: image)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: "qrcode")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.black)
        }
    }

    private func IceSpinQRMakeQR(_ value: String) -> UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(value.utf8)
        filter.correctionLevel = "M"
        guard let output = filter.outputImage,
              let cgImage = Self.IceSpinQRContext.createCGImage(output.transformed(by: CGAffineTransform(scaleX: 10, y: 10)), from: output.transformed(by: CGAffineTransform(scaleX: 10, y: 10)).extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}

struct IceSpinQRBottomTabBar: View {
    @Binding var IceSpinQRSelectedTab: IceSpinQRNavigationTab

    var body: some View {
        HStack(spacing: 8) {
            ForEach(IceSpinQRNavigationTab.allCases, id: \.rawValue) { tab in
                Button {
                    IceSpinQRSelectedTab = tab
                } label: {
                    VStack(spacing: 5) {
                        IceSpinQRGlyph(kind: tab.IceSpinQRGlyph, color: IceSpinQRSelectedTab == tab ? IceSpinQRTheme.midnight : IceSpinQRTheme.foam.opacity(0.78), lineWidth: 2)
                            .frame(width: 24, height: 24)
                        Text(tab.rawValue)
                            .font(.system(size: 9, weight: .black))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity, minHeight: 58)
                    .background(IceSpinQRSelectedTab == tab ? IceSpinQRTheme.cyan : IceSpinQRTheme.panelRaised, in: RoundedRectangle(cornerRadius: 18))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(IceSpinQRTheme.line, lineWidth: 0.8))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
    }
}

struct IceSpinQRSmallInfo: View {
    var title: String
    var value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .black))
                .foregroundStyle(IceSpinQRTheme.muted)
            Text(value)
                .font(.system(size: 12, weight: .black))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
    }
}

struct IceSpinQRMiniStat: View {
    var title: String
    var value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(value)
                .font(.system(size: 22, weight: .black))
                .lineLimit(1)
                .minimumScaleFactor(0.62)
            Text(title)
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(IceSpinQRTheme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .IceSpinQRPanel(cornerRadius: 18)
    }
}

struct IceSpinQRHistoryRow: View {
    var record: IceSpinQRScanRecord

    var body: some View {
        HStack {
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(IceSpinQRTheme.success)
            VStack(alignment: .leading, spacing: 4) {
                Text(record.result)
                    .font(.system(size: 14, weight: .black))
                Text(record.code)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(IceSpinQRTheme.muted)
            }
            Spacer()
            Text(record.date.formatted(date: .omitted, time: .shortened))
                .font(.system(size: 11, weight: .black))
                .foregroundStyle(IceSpinQRTheme.muted)
        }
        .padding(13)
        .IceSpinQRPanel(cornerRadius: 18)
    }
}

struct IceSpinQRScannerFrame: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let length: CGFloat = 54
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + length))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + length, y: rect.minY))
        path.move(to: CGPoint(x: rect.maxX - length, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + length))
        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY - length))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX - length, y: rect.maxY))
        path.move(to: CGPoint(x: rect.minX + length, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - length))
        return path
    }
}
