import SwiftUI

// Shared building blocks for exercise type views.

/// Two-phase answer state used by every exercise view.
enum AnswerPhase: Sendable { case answering, checked }

/// A selectable answer choice used by choice-style exercises.
/// States: idle → selected (blue) → correct (emerald) / incorrect (red).
struct AnswerButton: View {
    let text: String
    var imageURL: String?
    let isSelected: Bool
    /// nil while answering; true/false once checked (for correct/incorrect tint).
    var correctness: Bool?
    let action: () -> Void

    var body: some View {
        Button {
            MLHaptic.selection()
            action()
        } label: {
            HStack(spacing: MLSpacing.sm + MLSpacing.xs) {
                if let imageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        Color.mlSurfaceElevated
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: MLRadius.sm, style: .continuous))
                }

                Text(text)
                    .font(MLFont.bodyMedium)
                    .foregroundStyle(Color.mlTextPrimary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let correctness {
                    Image(systemName: correctness ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(correctness ? Color.mlEmerald : Color.mlError)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(MLSpacing.md)
            .frame(minHeight: 56)
            .background(background)
            .clipShape(shape)
            .overlay(shape.strokeBorder(border, lineWidth: isSelected || correctness != nil ? 2 : 1))
            .mlShadow(.soft)
        }
        .buttonStyle(MLPressableButtonStyle())
        .animation(MLMotion.snappy, value: correctness == nil)
        .accessibilityLabel(accessibilityText)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: MLRadius.md, style: .continuous)
    }

    private var accessibilityText: String {
        switch correctness {
        case .some(true): "\(text). Correcta"
        case .some(false): "\(text). Incorrecta"
        case nil: text
        }
    }

    private var background: Color {
        switch correctness {
        case .some(true): Color.mlEmerald.opacity(0.12)
        case .some(false): Color.mlError.opacity(0.12)
        case nil: isSelected ? Color.mlPrimary.opacity(0.1) : Color.mlSurface
        }
    }

    private var border: Color {
        switch correctness {
        case .some(true): .mlEmerald
        case .some(false): .mlError
        case nil: isSelected ? .mlPrimary : .mlCardStroke
        }
    }
}

/// Bottom bar: the Check button while answering; once checked, a tinted
/// feedback panel (Duolingo-style) springs up with the explanation.
/// Owns the correct/incorrect haptic + sound so every exercise feels the same.
struct ExerciseFooter: View {
    let phase: AnswerPhase
    let canCheck: Bool
    let isCorrect: Bool
    var explanation: String?
    let onCheck: () -> Void
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: MLSpacing.md) {
            if phase == .checked {
                feedbackBanner
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            MLButton(
                title: phase == .checked ? "Continuar" : "Comprobar",
                style: phase == .checked ? (isCorrect ? .secondary : .destructive) : .primary,
                isEnabled: phase == .checked ? true : canCheck,
            ) {
                if phase == .checked {
                    onContinue()
                } else {
                    if isCorrect {
                        MLHaptic.correct()
                        MLSoundPlayer.play(.correct)
                    } else {
                        MLHaptic.incorrect()
                        MLSoundPlayer.play(.incorrect)
                    }
                    onCheck()
                }
            }
        }
        .padding(MLSpacing.md)
        .background(feedbackBackground)
        .animation(MLMotion.smooth, value: phase)
    }

    private var feedbackBanner: some View {
        HStack(alignment: .top, spacing: MLSpacing.sm + MLSpacing.xs) {
            ZStack {
                Circle()
                    .fill(Color.mlOnAccent)
                    .frame(width: 36, height: 36)
                Image(systemName: isCorrect ? "checkmark" : "xmark")
                    .font(.body.weight(.heavy))
                    .foregroundStyle(isCorrect ? Color.mlEmerald : Color.mlError)
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: MLSpacing.xxs) {
                Text(isCorrect ? "¡Correcto!" : "Incorrecto")
                    .font(MLFont.title3)
                    .foregroundStyle(isCorrect ? Color.mlEmerald : Color.mlError)
                if let explanation, !explanation.isEmpty {
                    Text(explanation)
                        .font(MLFont.subheadline)
                        .foregroundStyle(Color.mlTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var feedbackBackground: some View {
        if phase == .checked {
            (isCorrect ? Color.mlEmerald : Color.mlError)
                .opacity(0.1)
                .background(.bar)
                .ignoresSafeArea(edges: .bottom)
        } else {
            Rectangle().fill(.bar).ignoresSafeArea(edges: .bottom)
        }
    }
}

/// Common vertical layout: prompt on top, exercise body in the middle, footer pinned.
struct ExerciseScaffold<Body: View>: View {
    let prompt: String
    var promptImageURL: String?
    @ViewBuilder let content: () -> Body
    let footer: ExerciseFooter

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: MLSpacing.lg) {
                    if let promptImageURL, let url = URL(string: promptImageURL) {
                        AsyncImage(url: url) { $0.resizable().scaledToFit() } placeholder: {
                            MLSkeleton(height: 180, cornerRadius: MLRadius.lg)
                        }
                        .frame(maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: MLRadius.lg, style: .continuous))
                        .frame(maxWidth: .infinity)
                    }
                    Text(prompt)
                        .font(MLFont.title2)
                        .foregroundStyle(Color.mlTextPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    content()
                }
                .padding(MLSpacing.md)
                .padding(.bottom, MLSpacing.lg)
            }
            footer
        }
    }
}

/// Simple wrapping chip row for word banks / tokens.
struct FlowChips: View {
    let items: [String]
    let onTap: (String) -> Void

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: MLSpacing.sm)],
                  spacing: MLSpacing.sm) {
            ForEach(items, id: \.self) { item in
                Button {
                    MLHaptic.selection()
                    onTap(item)
                } label: {
                    Text(item)
                        .font(MLFont.bodyMedium)
                        .foregroundStyle(Color.mlTextPrimary)
                        .padding(.horizontal, MLSpacing.md)
                        .padding(.vertical, MLSpacing.sm + MLSpacing.xs)
                        .frame(maxWidth: .infinity)
                        .background(Color.mlSurface, in: Capsule())
                        .overlay(Capsule().strokeBorder(Color.mlCardStroke, lineWidth: 1))
                        .mlShadow(.soft)
                }
                .buttonStyle(MLPressableButtonStyle(scale: 0.93))
            }
        }
    }
}

/// Rounded text input shared by typing-style exercises.
struct ExerciseTextField: View {
    let placeholder: String
    @Binding var text: String
    var lineLimit: ClosedRange<Int> = 1...4
    var disabled: Bool = false

    var body: some View {
        TextField(placeholder, text: $text, axis: .vertical)
            .lineLimit(lineLimit)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .font(MLFont.body)
            .foregroundStyle(Color.mlTextPrimary)
            .padding(MLSpacing.md)
            .background(Color.mlSurface, in: RoundedRectangle(cornerRadius: MLRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: MLRadius.md, style: .continuous)
                    .strokeBorder(Color.mlCardStroke, lineWidth: 1)
            )
            .disabled(disabled)
            .accessibilityLabel(placeholder)
    }
}
