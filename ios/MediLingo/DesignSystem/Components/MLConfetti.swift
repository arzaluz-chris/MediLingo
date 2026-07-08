import SwiftUI

// Celebration confetti overlay (lesson complete, achievements). Pure Canvas —
// no assets, cheap to render, and disabled entirely under Reduce Motion.
struct MLConfettiView: View {
    /// Total time particles keep falling.
    var duration: TimeInterval = 2.8

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var startDate = Date()

    private static let colors: [Color] = [
        .mlPrimary, .mlEmerald, .mlCyan, .mlMint, .mlXP, .mlGems, .mlStreak,
    ]

    private struct Particle {
        let x: Double          // 0...1 horizontal origin
        let delay: Double
        let speed: Double      // points/sec
        let drift: Double      // horizontal sway amplitude
        let size: Double
        let colorIndex: Int
        let spin: Double       // rotations/sec
    }

    private let particles: [Particle] = {
        var generator = SystemRandomNumberGenerator()
        return (0..<90).map { _ in
            Particle(
                x: .random(in: 0...1, using: &generator),
                delay: .random(in: 0...0.7, using: &generator),
                speed: .random(in: 180...340, using: &generator),
                drift: .random(in: 12...44, using: &generator),
                size: .random(in: 6...11, using: &generator),
                colorIndex: .random(in: 0..<7, using: &generator),
                spin: .random(in: 0.6...2.2, using: &generator),
            )
        }
    }()

    var body: some View {
        if reduceMotion {
            EmptyView()
        } else {
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let elapsed = timeline.date.timeIntervalSince(startDate)
                    guard elapsed < duration + 1.5 else { return }
                    for particle in particles {
                        let t = elapsed - particle.delay
                        guard t > 0 else { continue }
                        let y = t * particle.speed - 20
                        guard y < size.height + 20 else { continue }
                        let x = particle.x * size.width + sin(t * 2.6) * particle.drift
                        // Fade out near the end of the celebration.
                        let fade = max(0, min(1, (duration + 1.0 - elapsed) / 1.0))

                        var ctx = context
                        ctx.translateBy(x: x, y: y)
                        ctx.rotate(by: .radians(t * particle.spin * 2 * .pi))
                        ctx.opacity = fade
                        let rect = CGRect(
                            x: -particle.size / 2, y: -particle.size / 3.4,
                            width: particle.size, height: particle.size / 1.7,
                        )
                        ctx.fill(
                            Path(roundedRect: rect, cornerRadius: 1.5),
                            with: .color(Self.colors[particle.colorIndex]),
                        )
                    }
                }
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }
}
