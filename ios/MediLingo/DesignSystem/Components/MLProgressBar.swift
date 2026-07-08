import SwiftUI

// Linear progress bar for lesson/XP progress (CLAUDE-ios.md § Component Library).
// Gradient fill + a subtle top highlight (the Duolingo "pill shine").
struct MLProgressBar: View {
    /// 0.0 ... 1.0
    let progress: Double
    var tint: Color = .mlEmerald
    var height: CGFloat = 12

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.mlSurfaceElevated)
                if clampedProgress > 0 {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [tint.opacity(0.85), tint],
                                startPoint: .top, endPoint: .bottom,
                            )
                        )
                        .overlay(alignment: .top) {
                            // Shine highlight.
                            Capsule()
                                .fill(Color.white.opacity(0.28))
                                .frame(height: max(2, height * 0.28))
                                .padding(.horizontal, height * 0.4)
                                .padding(.top, height * 0.18)
                        }
                        .frame(width: max(height, geo.size.width * clampedProgress))
                }
            }
        }
        .frame(height: height)
        .animation(MLMotion.smooth, value: clampedProgress)
        .accessibilityElement()
        .accessibilityLabel("Progreso")
        .accessibilityValue("\(Int(clampedProgress * 100)) por ciento")
    }

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }
}

// Circular progress ring (daily goal, achievement completion).
struct MLProgressRing: View {
    /// 0.0 ... 1.0
    let progress: Double
    var lineWidth: CGFloat = 10
    var tint: Color = .mlEmerald
    /// Optional center content (e.g. a percentage or icon).
    var label: String?

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.mlSurfaceElevated, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0.001, clampedProgress))
                .stroke(
                    AngularGradient(
                        colors: [tint.opacity(0.7), tint],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360 * clampedProgress),
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round),
                )
                .rotationEffect(.degrees(-90))
            if let label {
                Text(label)
                    .font(MLFont.statValue)
                    .foregroundStyle(Color.mlTextPrimary)
                    .monospacedDigit()
                    .minimumScaleFactor(0.5)
                    .padding(lineWidth + MLSpacing.xs)
            }
        }
        .animation(MLMotion.smooth, value: clampedProgress)
        .accessibilityElement()
        .accessibilityLabel("Progreso")
        .accessibilityValue("\(Int(clampedProgress * 100)) por ciento")
    }

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }
}
