import SwiftUI

// Shared building blocks for exercise type views.

/// Two-phase answer state used by every exercise view.
enum AnswerPhase: Sendable { case answering, checked }

/// A selectable answer chip/button used by choice-style exercises.
struct AnswerButton: View {
    let text: String
    var imageURL: String?
    let isSelected: Bool
    /// nil while answering; true/false once checked (for correct/incorrect tint).
    var correctness: Bool?
    let action: () -> Void

    var body: some View {
        Button(action: {
            MLHaptic.tap()
            action()
        }) {
            HStack(spacing: MLSpacing.sm) {
                if let imageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        Color.mlSurfaceElevated
                    }
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: MLRadius.sm))
                }
                Text(text)
                    .font(MLFont.body())
                    .foregroundStyle(Color.mlTextPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(MLSpacing.md)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: MLRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: MLRadius.md)
                    .strokeBorder(border, lineWidth: 2),
            )
        }
        .accessibilityLabel(text)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    private var background: Color {
        switch correctness {
        case .some(true): Color.mlSuccess.opacity(0.2)
        case .some(false): Color.mlError.opacity(0.2)
        case nil: isSelected ? Color.mlPrimary.opacity(0.2) : Color.mlSurface
        }
    }

    private var border: Color {
        switch correctness {
        case .some(true): .mlSuccess
        case .some(false): .mlError
        case nil: isSelected ? .mlPrimary : .clear
        }
    }
}

/// Bottom bar: shows the Check button while answering, then a feedback banner
/// with the explanation + Continue button once checked.
struct ExerciseFooter: View {
    let phase: AnswerPhase
    let canCheck: Bool
    let isCorrect: Bool
    var explanation: String?
    let onCheck: () -> Void
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: MLSpacing.sm) {
            if phase == .checked {
                HStack(spacing: MLSpacing.sm) {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(isCorrect ? Color.mlSuccess : Color.mlError)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(isCorrect ? "¡Correcto!" : "Incorrecto")
                            .font(MLFont.heading(17))
                            .foregroundStyle(isCorrect ? Color.mlSuccess : Color.mlError)
                        if let explanation, !explanation.isEmpty {
                            Text(explanation)
                                .font(MLFont.caption())
                                .foregroundStyle(Color.mlTextSecondary)
                        }
                    }
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            MLButton(
                title: phase == .checked ? "Continuar" : "Comprobar",
                style: phase == .checked ? (isCorrect ? .primary : .destructive) : .primary,
                isEnabled: phase == .checked ? true : canCheck,
            ) {
                phase == .checked ? onContinue() : onCheck()
            }
        }
        .padding(MLSpacing.md)
        .background(Color.mlBackground)
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
                        AsyncImage(url: url) { $0.resizable().scaledToFit() } placeholder: { Color.mlSurfaceElevated }
                            .frame(maxHeight: 180)
                            .clipShape(RoundedRectangle(cornerRadius: MLRadius.md))
                    }
                    Text(prompt)
                        .font(MLFont.heading())
                        .foregroundStyle(Color.mlTextPrimary)
                    content()
                }
                .padding(MLSpacing.md)
            }
            footer
        }
    }
}
