import SwiftUI
import UIKit

struct IceSpinQRGlyph: View {
    var kind: IceSpinQRGlyphKind
    var color: Color = IceSpinQRTheme.cyan
    var lineWidth: CGFloat = 1.65

    var body: some View {
        Canvas { IceSpinQRContext, IceSpinQRSize in
            let IceSpinQRRect = CGRect(origin: .zero, size: IceSpinQRSize).insetBy(dx: lineWidth, dy: lineWidth)
            var IceSpinQRPath = Path()

            switch kind {
            case .dashboard:
                IceSpinQRPath.addRoundedRect(in: CGRect(x: IceSpinQRRect.minX, y: IceSpinQRRect.minY, width: IceSpinQRRect.width * 0.42, height: IceSpinQRRect.height * 0.42), cornerSize: CGSize(width: 5, height: 5))
                IceSpinQRPath.addRoundedRect(in: CGRect(x: IceSpinQRRect.midX + 3, y: IceSpinQRRect.minY, width: IceSpinQRRect.width * 0.38, height: IceSpinQRRect.height * 0.62), cornerSize: CGSize(width: 5, height: 5))
                IceSpinQRPath.addRoundedRect(in: CGRect(x: IceSpinQRRect.minX, y: IceSpinQRRect.midY + 3, width: IceSpinQRRect.width * 0.42, height: IceSpinQRRect.height * 0.38), cornerSize: CGSize(width: 5, height: 5))
            case .reserve:
                IceSpinQRPath.addRoundedRect(in: IceSpinQRRect.insetBy(dx: IceSpinQRRect.width * 0.12, dy: IceSpinQRRect.height * 0.12), cornerSize: CGSize(width: 7, height: 7))
                IceSpinQRPath.move(to: CGPoint(x: IceSpinQRRect.minX + IceSpinQRRect.width * 0.22, y: IceSpinQRRect.minY + IceSpinQRRect.height * 0.38))
                IceSpinQRPath.addLine(to: CGPoint(x: IceSpinQRRect.maxX - IceSpinQRRect.width * 0.22, y: IceSpinQRRect.minY + IceSpinQRRect.height * 0.38))
                IceSpinQRPath.move(to: CGPoint(x: IceSpinQRRect.midX, y: IceSpinQRRect.midY))
                IceSpinQRPath.addLine(to: CGPoint(x: IceSpinQRRect.midX, y: IceSpinQRRect.maxY - IceSpinQRRect.height * 0.20))
            case .schedule:
                IceSpinQRPath.addRoundedRect(in: IceSpinQRRect.insetBy(dx: IceSpinQRRect.width * 0.12, dy: IceSpinQRRect.height * 0.15), cornerSize: CGSize(width: 7, height: 7))
                IceSpinQRPath.move(to: CGPoint(x: IceSpinQRRect.minX + IceSpinQRRect.width * 0.24, y: IceSpinQRRect.minY + IceSpinQRRect.height * 0.42))
                IceSpinQRPath.addLine(to: CGPoint(x: IceSpinQRRect.maxX - IceSpinQRRect.width * 0.24, y: IceSpinQRRect.minY + IceSpinQRRect.height * 0.42))
                IceSpinQRPath.addEllipse(in: CGRect(x: IceSpinQRRect.minX + IceSpinQRRect.width * 0.30, y: IceSpinQRRect.midY + 2, width: 4, height: 4))
                IceSpinQRPath.addEllipse(in: CGRect(x: IceSpinQRRect.maxX - IceSpinQRRect.width * 0.36, y: IceSpinQRRect.midY + 2, width: 4, height: 4))
            case .profile:
                IceSpinQRPath.addEllipse(in: CGRect(x: IceSpinQRRect.midX - IceSpinQRRect.width * 0.16, y: IceSpinQRRect.minY + IceSpinQRRect.height * 0.18, width: IceSpinQRRect.width * 0.32, height: IceSpinQRRect.height * 0.32))
                IceSpinQRPath.addArc(center: CGPoint(x: IceSpinQRRect.midX, y: IceSpinQRRect.maxY - IceSpinQRRect.height * 0.10), radius: IceSpinQRRect.width * 0.30, startAngle: .degrees(205), endAngle: .degrees(335), clockwise: false)
            case .learn:
                IceSpinQRPath.addRoundedRect(in: IceSpinQRRect.insetBy(dx: IceSpinQRRect.width * 0.18, dy: IceSpinQRRect.height * 0.12), cornerSize: CGSize(width: 5, height: 5))
                IceSpinQRPath.move(to: CGPoint(x: IceSpinQRRect.minX + IceSpinQRRect.width * 0.30, y: IceSpinQRRect.minY + IceSpinQRRect.height * 0.34))
                IceSpinQRPath.addLine(to: CGPoint(x: IceSpinQRRect.maxX - IceSpinQRRect.width * 0.30, y: IceSpinQRRect.minY + IceSpinQRRect.height * 0.34))
                IceSpinQRPath.move(to: CGPoint(x: IceSpinQRRect.minX + IceSpinQRRect.width * 0.30, y: IceSpinQRRect.midY))
                IceSpinQRPath.addLine(to: CGPoint(x: IceSpinQRRect.maxX - IceSpinQRRect.width * 0.24, y: IceSpinQRRect.midY))
            case .table:
                IceSpinQRPath.addRoundedRect(in: IceSpinQRRect.insetBy(dx: IceSpinQRRect.width * 0.12, dy: IceSpinQRRect.height * 0.24), cornerSize: CGSize(width: 7, height: 7))
                IceSpinQRPath.move(to: CGPoint(x: IceSpinQRRect.minX + IceSpinQRRect.width * 0.24, y: IceSpinQRRect.maxY - IceSpinQRRect.height * 0.22))
                IceSpinQRPath.addLine(to: CGPoint(x: IceSpinQRRect.minX + IceSpinQRRect.width * 0.18, y: IceSpinQRRect.maxY))
                IceSpinQRPath.move(to: CGPoint(x: IceSpinQRRect.maxX - IceSpinQRRect.width * 0.24, y: IceSpinQRRect.maxY - IceSpinQRRect.height * 0.22))
                IceSpinQRPath.addLine(to: CGPoint(x: IceSpinQRRect.maxX - IceSpinQRRect.width * 0.18, y: IceSpinQRRect.maxY))
            case .lounge:
                IceSpinQRPath.addRoundedRect(in: IceSpinQRRect.insetBy(dx: IceSpinQRRect.width * 0.10, dy: IceSpinQRRect.height * 0.30), cornerSize: CGSize(width: 8, height: 8))
                IceSpinQRPath.move(to: CGPoint(x: IceSpinQRRect.minX + IceSpinQRRect.width * 0.18, y: IceSpinQRRect.maxY - IceSpinQRRect.height * 0.22))
                IceSpinQRPath.addLine(to: CGPoint(x: IceSpinQRRect.maxX - IceSpinQRRect.width * 0.18, y: IceSpinQRRect.maxY - IceSpinQRRect.height * 0.22))
            case .dining:
                IceSpinQRPath.move(to: CGPoint(x: IceSpinQRRect.minX + IceSpinQRRect.width * 0.30, y: IceSpinQRRect.minY + IceSpinQRRect.height * 0.12))
                IceSpinQRPath.addLine(to: CGPoint(x: IceSpinQRRect.minX + IceSpinQRRect.width * 0.30, y: IceSpinQRRect.maxY - IceSpinQRRect.height * 0.12))
                IceSpinQRPath.move(to: CGPoint(x: IceSpinQRRect.maxX - IceSpinQRRect.width * 0.34, y: IceSpinQRRect.minY + IceSpinQRRect.height * 0.12))
                IceSpinQRPath.addCurve(to: CGPoint(x: IceSpinQRRect.maxX - IceSpinQRRect.width * 0.34, y: IceSpinQRRect.maxY - IceSpinQRRect.height * 0.12), control1: CGPoint(x: IceSpinQRRect.maxX, y: IceSpinQRRect.midY), control2: CGPoint(x: IceSpinQRRect.maxX - IceSpinQRRect.width * 0.64, y: IceSpinQRRect.midY))
            case .host:
                IceSpinQRPath.addEllipse(in: IceSpinQRRect.insetBy(dx: IceSpinQRRect.width * 0.20, dy: IceSpinQRRect.height * 0.20))
                IceSpinQRPath.move(to: CGPoint(x: IceSpinQRRect.midX, y: IceSpinQRRect.minY))
                IceSpinQRPath.addLine(to: CGPoint(x: IceSpinQRRect.midX, y: IceSpinQRRect.maxY))
                IceSpinQRPath.move(to: CGPoint(x: IceSpinQRRect.minX, y: IceSpinQRRect.midY))
                IceSpinQRPath.addLine(to: CGPoint(x: IceSpinQRRect.maxX, y: IceSpinQRRect.midY))
            case .accessibility:
                IceSpinQRPath.addEllipse(in: CGRect(x: IceSpinQRRect.midX - 4, y: IceSpinQRRect.minY + 2, width: 8, height: 8))
                IceSpinQRPath.move(to: CGPoint(x: IceSpinQRRect.midX, y: IceSpinQRRect.minY + 14))
                IceSpinQRPath.addLine(to: CGPoint(x: IceSpinQRRect.midX, y: IceSpinQRRect.maxY - 6))
                IceSpinQRPath.move(to: CGPoint(x: IceSpinQRRect.minX + 6, y: IceSpinQRRect.midY))
                IceSpinQRPath.addLine(to: CGPoint(x: IceSpinQRRect.maxX - 6, y: IceSpinQRRect.midY))
            case .clock:
                IceSpinQRPath.addEllipse(in: IceSpinQRRect.insetBy(dx: IceSpinQRRect.width * 0.10, dy: IceSpinQRRect.height * 0.10))
                IceSpinQRPath.move(to: CGPoint(x: IceSpinQRRect.midX, y: IceSpinQRRect.midY))
                IceSpinQRPath.addLine(to: CGPoint(x: IceSpinQRRect.midX, y: IceSpinQRRect.minY + IceSpinQRRect.height * 0.28))
                IceSpinQRPath.move(to: CGPoint(x: IceSpinQRRect.midX, y: IceSpinQRRect.midY))
                IceSpinQRPath.addLine(to: CGPoint(x: IceSpinQRRect.maxX - IceSpinQRRect.width * 0.28, y: IceSpinQRRect.midY))
            case .check:
                IceSpinQRPath.move(to: CGPoint(x: IceSpinQRRect.minX + IceSpinQRRect.width * 0.24, y: IceSpinQRRect.midY))
                IceSpinQRPath.addLine(to: CGPoint(x: IceSpinQRRect.minX + IceSpinQRRect.width * 0.43, y: IceSpinQRRect.maxY - IceSpinQRRect.height * 0.28))
                IceSpinQRPath.addLine(to: CGPoint(x: IceSpinQRRect.maxX - IceSpinQRRect.width * 0.20, y: IceSpinQRRect.minY + IceSpinQRRect.height * 0.28))
            case .alert:
                IceSpinQRPath.move(to: CGPoint(x: IceSpinQRRect.midX, y: IceSpinQRRect.minY + 2))
                IceSpinQRPath.addLine(to: CGPoint(x: IceSpinQRRect.maxX - 2, y: IceSpinQRRect.maxY - 2))
                IceSpinQRPath.addLine(to: CGPoint(x: IceSpinQRRect.minX + 2, y: IceSpinQRRect.maxY - 2))
                IceSpinQRPath.closeSubpath()
                IceSpinQRPath.move(to: CGPoint(x: IceSpinQRRect.midX, y: IceSpinQRRect.midY - 4))
                IceSpinQRPath.addLine(to: CGPoint(x: IceSpinQRRect.midX, y: IceSpinQRRect.midY + 5))
            case .arrow:
                IceSpinQRPath.move(to: CGPoint(x: IceSpinQRRect.minX + IceSpinQRRect.width * 0.34, y: IceSpinQRRect.minY + IceSpinQRRect.height * 0.22))
                IceSpinQRPath.addLine(to: CGPoint(x: IceSpinQRRect.maxX - IceSpinQRRect.width * 0.28, y: IceSpinQRRect.midY))
                IceSpinQRPath.addLine(to: CGPoint(x: IceSpinQRRect.minX + IceSpinQRRect.width * 0.34, y: IceSpinQRRect.maxY - IceSpinQRRect.height * 0.22))
            case .wave:
                IceSpinQRPath = IceSpinQRWaveMark().path(in: IceSpinQRRect)
            case .note:
                IceSpinQRPath.addRoundedRect(in: IceSpinQRRect.insetBy(dx: IceSpinQRRect.width * 0.16, dy: IceSpinQRRect.height * 0.10), cornerSize: CGSize(width: 5, height: 5))
                IceSpinQRPath.move(to: CGPoint(x: IceSpinQRRect.minX + IceSpinQRRect.width * 0.28, y: IceSpinQRRect.minY + IceSpinQRRect.height * 0.36))
                IceSpinQRPath.addLine(to: CGPoint(x: IceSpinQRRect.maxX - IceSpinQRRect.width * 0.24, y: IceSpinQRRect.minY + IceSpinQRRect.height * 0.36))
                IceSpinQRPath.move(to: CGPoint(x: IceSpinQRRect.minX + IceSpinQRRect.width * 0.28, y: IceSpinQRRect.midY))
                IceSpinQRPath.addLine(to: CGPoint(x: IceSpinQRRect.maxX - IceSpinQRRect.width * 0.34, y: IceSpinQRRect.midY))
            }

            IceSpinQRContext.stroke(IceSpinQRPath, with: .color(color), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct IceSpinQRHeaderBlock: View {
    var title: String
    var subtitle: String
    var detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 58, height: 42)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 27, weight: .black))
                    Text(subtitle)
                        .font(.system(size: 11, weight: .black))
                        .foregroundStyle(IceSpinQRTheme.cyan)
                        .textCase(.uppercase)
                }
            }
            Text(detail)
                .font(.system(size: 14))
                .foregroundStyle(IceSpinQRTheme.muted)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .IceSpinQRPanel()
    }
}

struct IceSpinQRSectionTitle: View {
    var title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.system(size: 18, weight: .black))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct IceSpinQRStatusPill: View {
    var text: String
    var color: Color

    init(_ text: String, color: Color) {
        self.text = text
        self.color = color
    }

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .black))
            .foregroundStyle(color)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(color.opacity(0.14), in: Capsule())
            .overlay(Capsule().stroke(color.opacity(0.28), lineWidth: 0.8))
    }
}

struct IceSpinQRPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .black))
            .foregroundStyle(IceSpinQRTheme.midnight)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                LinearGradient(
                    colors: [
                        IceSpinQRTheme.cyan.opacity(configuration.isPressed ? 0.72 : 1),
                        Color(red: 0.370, green: 0.850, blue: 0.960).opacity(configuration.isPressed ? 0.76 : 1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 12)
            )
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.30), lineWidth: 0.8))
    }
}

struct IceSpinQRSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .black))
            .foregroundStyle(IceSpinQRTheme.foam)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                configuration.isPressed ? IceSpinQRTheme.slate.opacity(0.72) : IceSpinQRTheme.panelRaised,
                in: RoundedRectangle(cornerRadius: 12)
            )
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(IceSpinQRTheme.line, lineWidth: 0.8))
    }
}

struct IceSpinQRDestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .black))
            .foregroundStyle(IceSpinQRTheme.foam)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                Color(red: 0.560, green: 0.120, blue: 0.160).opacity(configuration.isPressed ? 0.70 : 0.92),
                in: RoundedRectangle(cornerRadius: 12)
            )
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.18), lineWidth: 0.8))
    }
}

struct IceSpinQRIconButton: View {
    var glyph: IceSpinQRGlyphKind
    var title: String
    var IceSpinQRIsActive = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                IceSpinQRGlyph(kind: glyph, color: IceSpinQRIsActive ? IceSpinQRTheme.midnight : IceSpinQRTheme.foam.opacity(0.82), lineWidth: 1.65)
                    .frame(width: 23, height: 23)
                Text(title)
                    .font(.system(size: 10, weight: .black))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .foregroundStyle(IceSpinQRIsActive ? IceSpinQRTheme.midnight : IceSpinQRTheme.foam.opacity(0.82))
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(
                IceSpinQRIsActive ? IceSpinQRTheme.cyan : Color.white.opacity(0.06),
                in: RoundedRectangle(cornerRadius: 12)
            )
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(IceSpinQRIsActive ? Color.white.opacity(0.36) : IceSpinQRTheme.line, lineWidth: 0.8))
        }
        .buttonStyle(.plain)
    }
}

struct IceSpinQRTabBar: View {
    @Binding var IceSpinQRSelectedTab: IceSpinQRNavigationTab

    var body: some View {
        HStack(spacing: 8) {
            ForEach(IceSpinQRNavigationTab.allCases, id: \.self) { IceSpinQRTab in
                IceSpinQRIconButton(glyph: IceSpinQRTab.IceSpinQRGlyph, title: IceSpinQRTab.rawValue, IceSpinQRIsActive: IceSpinQRSelectedTab == IceSpinQRTab) {
                    IceSpinQRHaptics.IceSpinQRTap()
                    withAnimation(.spring(response: 0.26, dampingFraction: 0.78)) {
                        IceSpinQRSelectedTab = IceSpinQRTab
                    }
                }
            }
        }
        .padding(8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(IceSpinQRTheme.line))
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }
}

struct IceSpinQRPanelModifier: ViewModifier {
    var IceSpinQRCornerRadius: CGFloat

    init(cornerRadius: CGFloat) {
        self.IceSpinQRCornerRadius = cornerRadius
    }

    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: [IceSpinQRTheme.panel.opacity(0.97), IceSpinQRTheme.panelRaised.opacity(0.90)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: IceSpinQRCornerRadius)
            )
            .overlay(RoundedRectangle(cornerRadius: IceSpinQRCornerRadius).stroke(IceSpinQRTheme.line, lineWidth: 0.8))
            .shadow(color: Color.black.opacity(0.16), radius: 14, y: 8)
    }
}

struct IceSpinQRToastView: View {
    var text: String

    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .black))
            .foregroundStyle(IceSpinQRTheme.midnight)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(IceSpinQRTheme.cyan, in: Capsule())
            .shadow(color: .black.opacity(0.24), radius: 18, y: 10)
    }
}

extension View {
    func IceSpinQRPanel(cornerRadius: CGFloat = 16) -> some View {
        modifier(IceSpinQRPanelModifier(cornerRadius: cornerRadius))
    }

    func IceSpinQRInputStyle() -> some View {
        padding(14)
            .background(IceSpinQRTheme.panelRaised, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(IceSpinQRTheme.line, lineWidth: 0.8))
    }
}

extension String {
    var IceSpinQRTrimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension Date {
    var IceSpinQRVisitDate: String {
        formatted(date: .abbreviated, time: .shortened)
    }
}

enum IceSpinQRHaptics {
    static func IceSpinQRTap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func IceSpinQRSuccess() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func IceSpinQRWarning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}
