import Foundation

enum IceSpinQRLaunchDestination: Equatable {
    case native
    case web(URL)
    case offline
}

enum IceSpinQRGlyphKind: CaseIterable {
    case dashboard
    case reserve
    case schedule
    case profile
    case learn
    case table
    case lounge
    case dining
    case host
    case accessibility
    case clock
    case check
    case alert
    case arrow
    case wave
    case note
}

enum IceSpinQRNavigationTab: String, CaseIterable {
    case rewards = "Rewards"
    case events = "Events"
    case scan = "Scan"
    case privileges = "Privileges"
    case profile = "Profile"

    var IceSpinQRGlyph: IceSpinQRGlyphKind {
        switch self {
        case .rewards: .dashboard
        case .events: .schedule
        case .scan: .reserve
        case .privileges: .host
        case .profile: .profile
        }
    }
}

enum IceSpinQRRewardState: String, Codable {
    case ready = "Ready"
    case active = "QR Active"
    case redeemed = "Redeemed"
    case expired = "Expired"
}

struct IceSpinQRReward: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var detail: String
    var tier: String
    var expiresAt: Date
    var state: IceSpinQRRewardState
    var qrPayload: String
}

enum IceSpinQREventState: String, Codable {
    case open = "Open"
    case registered = "Registered"
    case checkedIn = "Checked In"
    case closed = "Closed"
}

struct IceSpinQREvent: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var date: Date
    var location: String
    var detail: String
    var requiredTier: String
    var state: IceSpinQREventState
    var qrPayload: String
}

struct IceSpinQRPrivilege: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var detail: String
    var symbol: String
    var isEnabled: Bool
    var lastVerified: Date?
}

struct IceSpinQRScanRecord: Identifiable, Codable, Equatable {
    var id = UUID()
    var code: String
    var result: String
    var date: Date
}

struct IceSpinQRProfile: Codable, Equatable {
    var name = "John Doe"
    var username = "demo"
    var loyaltyTier = "Crystal"
    var loyaltyPoints = 18400
    var scans = 0
    var activatedRewards = 0
    var registeredEvents = 0
}

struct IceSpinQRStat: Identifiable, Equatable {
    var id = UUID()
    var title: String
    var value: String
    var detail: String
    var glyph: IceSpinQRGlyphKind
}
