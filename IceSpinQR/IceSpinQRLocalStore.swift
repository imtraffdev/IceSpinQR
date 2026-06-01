import Foundation

final class IceSpinQRLocalStore: ObservableObject {
    private enum IceSpinQRKeys {
        static let authenticated = "icespinqr_authenticated_v1"
        static let rewards = "icespinqr_rewards_v1"
        static let events = "icespinqr_events_v1"
        static let privileges = "icespinqr_privileges_v1"
        static let scans = "icespinqr_scans_v1"
        static let profile = "icespinqr_profile_v1"
    }

    private enum IceSpinQRTestAccess {
        static let login = "demo"
        static let password = "IceQR2026!"
    }

    @Published var isAuthenticated: Bool {
        didSet { UserDefaults.standard.set(isAuthenticated, forKey: IceSpinQRKeys.authenticated) }
    }

    @Published var IceSpinQRRewards: [IceSpinQRReward] {
        didSet { IceSpinQRPersist(IceSpinQRRewards, key: IceSpinQRKeys.rewards) }
    }

    @Published var IceSpinQREvents: [IceSpinQREvent] {
        didSet { IceSpinQRPersist(IceSpinQREvents, key: IceSpinQRKeys.events) }
    }

    @Published var IceSpinQRPrivileges: [IceSpinQRPrivilege] {
        didSet { IceSpinQRPersist(IceSpinQRPrivileges, key: IceSpinQRKeys.privileges) }
    }

    @Published var IceSpinQRScanHistory: [IceSpinQRScanRecord] {
        didSet { IceSpinQRPersist(IceSpinQRScanHistory, key: IceSpinQRKeys.scans) }
    }

    @Published var IceSpinQRProfileState: IceSpinQRProfile {
        didSet { IceSpinQRPersist(IceSpinQRProfileState, key: IceSpinQRKeys.profile) }
    }

    init() {
        isAuthenticated = UserDefaults.standard.bool(forKey: IceSpinQRKeys.authenticated)
        IceSpinQRRewards = Self.IceSpinQRRestore([IceSpinQRReward].self, key: IceSpinQRKeys.rewards) ?? Self.IceSpinQRStarterRewards
        IceSpinQREvents = Self.IceSpinQRRestore([IceSpinQREvent].self, key: IceSpinQRKeys.events) ?? Self.IceSpinQRStarterEvents
        IceSpinQRPrivileges = Self.IceSpinQRRestore([IceSpinQRPrivilege].self, key: IceSpinQRKeys.privileges) ?? Self.IceSpinQRStarterPrivileges
        IceSpinQRScanHistory = Self.IceSpinQRRestore([IceSpinQRScanRecord].self, key: IceSpinQRKeys.scans) ?? []
        IceSpinQRProfileState = Self.IceSpinQRRestore(IceSpinQRProfile.self, key: IceSpinQRKeys.profile) ?? IceSpinQRProfile()
        IceSpinQRRefreshCounters()
    }

    func IceSpinQRAuthenticate(login: String, password: String) -> Bool {
        guard login.IceSpinQRTrimmed.lowercased() == IceSpinQRTestAccess.login,
              password == IceSpinQRTestAccess.password else {
            return false
        }
        isAuthenticated = true
        return true
    }

    func IceSpinQRSignOut() {
        isAuthenticated = false
    }

    func IceSpinQRDeleteProfile() {
        [
            IceSpinQRKeys.authenticated,
            IceSpinQRKeys.rewards,
            IceSpinQRKeys.events,
            IceSpinQRKeys.privileges,
            IceSpinQRKeys.scans,
            IceSpinQRKeys.profile
        ].forEach { UserDefaults.standard.removeObject(forKey: $0) }

        IceSpinQRRewards = Self.IceSpinQRStarterRewards
        IceSpinQREvents = Self.IceSpinQRStarterEvents
        IceSpinQRPrivileges = Self.IceSpinQRStarterPrivileges
        IceSpinQRScanHistory = []
        IceSpinQRProfileState = IceSpinQRProfile()
        isAuthenticated = false
    }

    func IceSpinQRActivateReward(_ reward: IceSpinQRReward) {
        guard let index = IceSpinQRRewards.firstIndex(where: { $0.id == reward.id }) else { return }
        IceSpinQRRewards[index].state = .active
        IceSpinQRRewards[index].qrPayload = "ICE-REWARD-\(reward.id.uuidString.prefix(8))-OPERATOR"
        IceSpinQRRefreshCounters()
    }

    func IceSpinQRRedeemReward(_ reward: IceSpinQRReward) {
        guard let index = IceSpinQRRewards.firstIndex(where: { $0.id == reward.id }) else { return }
        IceSpinQRRewards[index].state = .redeemed
        IceSpinQRRefreshCounters()
    }

    func IceSpinQRRegister(event: IceSpinQREvent) {
        guard let index = IceSpinQREvents.firstIndex(where: { $0.id == event.id }) else { return }
        IceSpinQREvents[index].state = .registered
        IceSpinQREvents[index].qrPayload = "ICE-EVENT-\(event.id.uuidString.prefix(8))-JOHNDOE"
        IceSpinQRRefreshCounters()
    }

    func IceSpinQRCheckIn(event: IceSpinQREvent) {
        guard let index = IceSpinQREvents.firstIndex(where: { $0.id == event.id }) else { return }
        IceSpinQREvents[index].state = .checkedIn
        IceSpinQRRefreshCounters()
    }

    func IceSpinQRVerifyPrivilege(_ privilege: IceSpinQRPrivilege) {
        guard let index = IceSpinQRPrivileges.firstIndex(where: { $0.id == privilege.id }) else { return }
        IceSpinQRPrivileges[index].isEnabled = true
        IceSpinQRPrivileges[index].lastVerified = Date()
    }

    func IceSpinQRSubmitManualCode(_ code: String) -> String {
        let cleaned = code.IceSpinQRTrimmed.uppercased()
        guard cleaned.count >= 5 else { return "Enter a valid QR or access code." }
        let result: String
        if cleaned.contains("REWARD") {
            result = "Reward access confirmed"
        } else if cleaned.contains("EVENT") {
            result = "Event entry confirmed"
        } else if cleaned.contains("TIER") || cleaned.contains("LOYAL") {
            result = "Loyalty level verified"
        } else {
            result = "Code stored for host review"
        }
        IceSpinQRScanHistory.insert(IceSpinQRScanRecord(code: cleaned, result: result, date: Date()), at: 0)
        IceSpinQRScanHistory = Array(IceSpinQRScanHistory.prefix(30))
        IceSpinQRProfileState.scans = IceSpinQRScanHistory.count
        return result
    }

    var IceSpinQRStats: [IceSpinQRStat] {
        [
            IceSpinQRStat(title: "Rewards", value: "\(IceSpinQRRewards.filter { $0.state == .active || $0.state == .ready }.count)", detail: "Available QR actions", glyph: .dashboard),
            IceSpinQRStat(title: "Events", value: "\(IceSpinQREvents.filter { $0.state == .registered }.count)", detail: "Registered visits", glyph: .schedule),
            IceSpinQRStat(title: "Privileges", value: "\(IceSpinQRPrivileges.filter(\.isEnabled).count)", detail: "Verified access items", glyph: .host),
            IceSpinQRStat(title: "Scans", value: "\(IceSpinQRScanHistory.count)", detail: "Recent QR activity", glyph: .reserve)
        ]
    }

    private func IceSpinQRRefreshCounters() {
        IceSpinQRProfileState.activatedRewards = IceSpinQRRewards.filter { $0.state == .active || $0.state == .redeemed }.count
        IceSpinQRProfileState.registeredEvents = IceSpinQREvents.filter { $0.state == .registered || $0.state == .checkedIn }.count
        IceSpinQRProfileState.scans = IceSpinQRScanHistory.count
    }

    private func IceSpinQRPersist<T: Encodable>(_ value: T, key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private static func IceSpinQRRestore<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    private static var IceSpinQRStarterRewards: [IceSpinQRReward] {
        let calendar = Calendar.current
        return [
            IceSpinQRReward(title: "Frost Lounge Credit", detail: "Show the generated QR to a host desk operator for venue-side reward validation.", tier: "Crystal", expiresAt: calendar.date(byAdding: .day, value: 2, to: Date()) ?? Date(), state: .ready, qrPayload: "ICE-REWARD-FROST-READY"),
            IceSpinQRReward(title: "Winter Table Access", detail: "Reserved access confirmation for selected table areas during evening sessions.", tier: "Silver", expiresAt: calendar.date(byAdding: .day, value: 5, to: Date()) ?? Date(), state: .ready, qrPayload: "ICE-REWARD-TABLE-READY"),
            IceSpinQRReward(title: "Private Host Review", detail: "A temporary QR for host-assisted privilege review at Ice Spin Casino.", tier: "Crystal", expiresAt: calendar.date(byAdding: .day, value: 7, to: Date()) ?? Date(), state: .ready, qrPayload: "ICE-REWARD-HOST-READY")
        ]
    }

    private static var IceSpinQRStarterEvents: [IceSpinQREvent] {
        let calendar = Calendar.current
        return [
            IceSpinQREvent(title: "Aurora Night Reception", date: calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date(), location: "Crystal Hall", detail: "Evening venue reception with QR admission and loyalty level check.", requiredTier: "Silver+", state: .open, qrPayload: "ICE-EVENT-AURORA-OPEN"),
            IceSpinQREvent(title: "Glacier Lounge Preview", date: calendar.date(byAdding: .day, value: 4, to: Date()) ?? Date(), location: "Glacier Lounge", detail: "Small group lounge preview. Registration creates a personal entry QR.", requiredTier: "Crystal", state: .open, qrPayload: "ICE-EVENT-GLACIER-OPEN"),
            IceSpinQREvent(title: "Frozen Vault Showcase", date: calendar.date(byAdding: .day, value: 8, to: Date()) ?? Date(), location: "Vault Room", detail: "Access-controlled showcase with QR ticketing and host confirmation.", requiredTier: "Diamond", state: .open, qrPayload: "ICE-EVENT-VAULT-OPEN")
        ]
    }

    private static var IceSpinQRStarterPrivileges: [IceSpinQRPrivilege] {
        [
            IceSpinQRPrivilege(title: "Crystal Entry Lane", detail: "Faster host desk verification through loyalty QR.", symbol: "sparkles", isEnabled: true, lastVerified: Date()),
            IceSpinQRPrivilege(title: "Event Priority List", detail: "Eligibility flag for selected upcoming venue events.", symbol: "calendar.badge.checkmark", isEnabled: true, lastVerified: Date()),
            IceSpinQRPrivilege(title: "Host Assisted Rewards", detail: "Temporary QR generation for operator-side reward activation.", symbol: "qrcode.viewfinder", isEnabled: false, lastVerified: nil),
            IceSpinQRPrivilege(title: "Private Lounge Review", detail: "Privilege status check for premium venue areas.", symbol: "snowflake", isEnabled: false, lastVerified: nil)
        ]
    }
}
