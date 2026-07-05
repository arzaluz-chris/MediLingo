import SwiftUI

// Linear progress bar for lesson/XP progress (CLAUDE-ios.md § Component Library).
struct MLProgressBar: View {
    /// 0.0 ... 1.0
    let progress: Double
    var tint: Color = .mlSuccess
    var height: CGFloat = 12

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.mlSurfaceElevated)
                Capsule()
                    .fill(tint)
                    .frame(width: geo.size.width * clampedProgress)
            }
        }
        .frame(height: height)
        .animation(.easeInOut(duration: 0.3), value: clampedProgress)
        .accessibilityLabel("Progress")
        .accessibilityValue("\(Int(clampedProgress * 100)) percent")
    }

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }
}
