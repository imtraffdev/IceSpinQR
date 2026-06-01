import SwiftUI

enum IceSpinQRTheme {
    static let midnight = Color(red: 0.025, green: 0.055, blue: 0.095)
    static let navy = Color(red: 0.045, green: 0.105, blue: 0.165)
    static let harbor = Color(red: 0.105, green: 0.205, blue: 0.315)
    static let slate = Color(red: 0.150, green: 0.255, blue: 0.365)
    static let cyan = Color(red: 0.250, green: 0.760, blue: 0.900)
    static let aqua = Color(red: 0.150, green: 0.580, blue: 0.690)
    static let iceSilver = Color(red: 0.720, green: 0.840, blue: 0.930)
    static let royal = Color(red: 0.100, green: 0.280, blue: 0.560)
    static let violet = Color(red: 0.380, green: 0.460, blue: 0.820)
    static let sand = Color(red: 0.840, green: 0.910, blue: 0.960)
    static let foam = Color(red: 0.930, green: 0.965, blue: 0.985)
    static let muted = Color(red: 0.700, green: 0.790, blue: 0.875)
    static let panel = Color(red: 0.065, green: 0.130, blue: 0.205)
    static let panelRaised = Color(red: 0.095, green: 0.180, blue: 0.275)
    static let line = Color.white.opacity(0.12)
    static let accentLine = sand.opacity(0.48)
    static let success = Color(red: 0.350, green: 0.820, blue: 0.650)
    static let warning = Color(red: 0.950, green: 0.610, blue: 0.270)
}

struct IceSpinQRGlacierBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, IceSpinQRTheme.midnight, IceSpinQRTheme.royal, IceSpinQRTheme.harbor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            IceSpinQRRouteGrid()
                .opacity(0.54)

            ForEach(0..<28, id: \.self) { IceSpinQRIndex in
                Circle()
                    .fill(IceSpinQRIndex.isMultiple(of: 3) ? IceSpinQRTheme.cyan.opacity(0.18) : IceSpinQRTheme.foam.opacity(0.12))
                    .frame(width: CGFloat(2 + IceSpinQRIndex % 4), height: CGFloat(2 + IceSpinQRIndex % 4))
                    .position(
                        x: CGFloat((IceSpinQRIndex * 37) % 390),
                        y: CGFloat((IceSpinQRIndex * 79) % 860)
                    )
            }

            VStack(spacing: 30) {
                ForEach(0..<6, id: \.self) { IceSpinQRIndex in
                    IceSpinQRCrystalMark()
                        .stroke(IceSpinQRIndex.isMultiple(of: 2) ? IceSpinQRTheme.cyan.opacity(0.10) : IceSpinQRTheme.iceSilver.opacity(0.075), lineWidth: 1.2)
                        .frame(width: 120 + CGFloat(IceSpinQRIndex % 3) * 58, height: 70)
                        .frame(maxWidth: .infinity, alignment: IceSpinQRIndex.isMultiple(of: 2) ? .leading : .trailing)
                        .padding(.horizontal, CGFloat(18 + IceSpinQRIndex * 8))
                }
            }
            .rotationEffect(.degrees(-5))
        }
        .ignoresSafeArea()
    }
}

struct IceSpinQRCrystalMark: Shape {
    func path(in rect: CGRect) -> Path {
        var IceSpinQRPath = Path()
        IceSpinQRPath.move(to: CGPoint(x: rect.midX, y: rect.minY))
        IceSpinQRPath.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        IceSpinQRPath.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        IceSpinQRPath.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        IceSpinQRPath.closeSubpath()
        IceSpinQRPath.move(to: CGPoint(x: rect.midX, y: rect.minY))
        IceSpinQRPath.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        IceSpinQRPath.move(to: CGPoint(x: rect.minX, y: rect.midY))
        IceSpinQRPath.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return IceSpinQRPath
    }
}

struct IceSpinQRWaveMark: Shape {
    func path(in rect: CGRect) -> Path {
        var IceSpinQRPath = Path()
        let IceSpinQRStep = rect.width / 4
        IceSpinQRPath.move(to: CGPoint(x: rect.minX, y: rect.midY))
        for IceSpinQRIndex in 0..<4 {
            let IceSpinQRStart = rect.minX + CGFloat(IceSpinQRIndex) * IceSpinQRStep
            IceSpinQRPath.addCurve(
                to: CGPoint(x: IceSpinQRStart + IceSpinQRStep, y: rect.midY),
                control1: CGPoint(x: IceSpinQRStart + IceSpinQRStep * 0.30, y: rect.minY),
                control2: CGPoint(x: IceSpinQRStart + IceSpinQRStep * 0.70, y: rect.maxY)
            )
        }
        return IceSpinQRPath
    }
}

struct IceSpinQRRouteGrid: View {
    var body: some View {
        GeometryReader { IceSpinQRProxy in
            Canvas { IceSpinQRContext, IceSpinQRSize in
                var IceSpinQRPath = Path()
                let step: CGFloat = 42
                stride(from: CGFloat(0), through: IceSpinQRSize.width, by: step).forEach { IceSpinQRX in
                    IceSpinQRPath.move(to: CGPoint(x: IceSpinQRX, y: 0))
                    IceSpinQRPath.addLine(to: CGPoint(x: IceSpinQRX, y: IceSpinQRSize.height))
                }
                stride(from: CGFloat(0), through: IceSpinQRSize.height, by: step).forEach { IceSpinQRY in
                    IceSpinQRPath.move(to: CGPoint(x: 0, y: IceSpinQRY))
                    IceSpinQRPath.addLine(to: CGPoint(x: IceSpinQRSize.width, y: IceSpinQRY))
                }
                IceSpinQRContext.stroke(IceSpinQRPath, with: .color(Color.white.opacity(0.045)), lineWidth: 0.7)

                var route = Path()
                route.move(to: CGPoint(x: IceSpinQRProxy.size.width * 0.10, y: IceSpinQRProxy.size.height * 0.16))
                route.addCurve(
                    to: CGPoint(x: IceSpinQRProxy.size.width * 0.86, y: IceSpinQRProxy.size.height * 0.78),
                    control1: CGPoint(x: IceSpinQRProxy.size.width * 0.28, y: IceSpinQRProxy.size.height * 0.34),
                    control2: CGPoint(x: IceSpinQRProxy.size.width * 0.66, y: IceSpinQRProxy.size.height * 0.42)
                )
                IceSpinQRContext.stroke(route, with: .color(IceSpinQRTheme.cyan.opacity(0.14)), style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [8, 12]))
            }
        }
        .ignoresSafeArea()
    }
}

struct IceSpinQRSplashView: View {
    var stage: Int
    var progress: Double
    var isOffline = false

    @State private var IceSpinQRIsPulsing = false

    var body: some View {
        ZStack {
            IceSpinQRGlacierBackground()

            VStack(spacing: 22) {
                Spacer()
                ZStack {
                    Circle()
                        .fill(IceSpinQRTheme.cyan.opacity(IceSpinQRIsPulsing ? 0.10 : 0.22))
                        .frame(width: IceSpinQRIsPulsing ? 270 : 210, height: IceSpinQRIsPulsing ? 270 : 210)
                        .blur(radius: 18)
                    Circle()
                        .stroke(IceSpinQRTheme.iceSilver.opacity(IceSpinQRIsPulsing ? 0.10 : 0.38), lineWidth: 1.4)
                        .frame(width: IceSpinQRIsPulsing ? 250 : 188, height: IceSpinQRIsPulsing ? 250 : 188)
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 205)
                        .scaleEffect(IceSpinQRIsPulsing ? 1.045 : 0.965)
                        .shadow(color: IceSpinQRTheme.cyan.opacity(IceSpinQRIsPulsing ? 0.55 : 0.22), radius: IceSpinQRIsPulsing ? 30 : 12, y: 8)
                }
                .animation(.easeInOut(duration: 1.15).repeatForever(autoreverses: true), value: IceSpinQRIsPulsing)

                Text(isOffline ? "Offline access ready" : "Preparing secure QR access")
                    .font(.system(size: 14, weight: .black))
                    .tracking(1.1)
                    .foregroundStyle(IceSpinQRTheme.iceSilver)

                IceSpinQRProgressDock(progress: progress)
                    .frame(maxWidth: 190)

                Spacer()
            }
            .padding(.horizontal, 28)
        }
        .onAppear { IceSpinQRIsPulsing = true }
    }
}

struct IceSpinQRProgressDock: View {
    var progress: Double

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<18, id: \.self) { IceSpinQRIndex in
                Capsule()
                    .fill(Double(IceSpinQRIndex) / 18.0 <= progress ? IceSpinQRTheme.cyan : IceSpinQRTheme.foam.opacity(0.14))
                    .frame(height: IceSpinQRIndex.isMultiple(of: 3) ? 18 : 12)
            }
        }
    }
}
