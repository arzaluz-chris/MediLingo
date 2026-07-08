import SwiftUI

@MainActor
@Observable
final class VocabularyViewModel {
    var query = ""
    var words: [VocabularyWord] = []
    var added: Set<UUID> = []
    var isLoading = false

    private let content: ContentRepositoryProtocol
    private let flashcards: FlashcardRepositoryProtocol

    init(content: ContentRepositoryProtocol, flashcards: FlashcardRepositoryProtocol) {
        self.content = content
        self.flashcards = flashcards
    }

    func search() async {
        isLoading = true
        defer { isLoading = false }
        words = (try? await content.searchVocabulary(query: query)) ?? []
    }

    func addToDeck(_ word: VocabularyWord) {
        added.insert(word.id)
        Task { try? await flashcards.addWord(vocabularyID: word.id) }
    }
}

// Browse + search published vocabulary; add words to the review deck.
//
// Redesign: proper search field with icon and clear button, richer term cards
// (word + phonetic + translation), and an animated add-to-deck action.
struct VocabularyView: View {
    @Environment(AppDependencies.self) private var dependencies
    @State private var viewModel: VocabularyViewModel?

    var body: some View {
        ZStack {
            Color.mlBackground.ignoresSafeArea()
            content
        }
        .navigationTitle("Vocabulario")
        .task {
            if viewModel == nil {
                viewModel = VocabularyViewModel(
                    content: dependencies.contentRepository,
                    flashcards: dependencies.flashcardRepository,
                )
                await viewModel?.search()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let viewModel {
            @Bindable var vm = viewModel
            VStack(spacing: MLSpacing.sm) {
                searchField(vm)
                    .padding(.horizontal, MLSpacing.md)

                if vm.isLoading {
                    MLSkeletonList(rows: 6, rowHeight: 72)
                } else if vm.words.isEmpty {
                    MLEmptyState(systemImage: "magnifyingglass", title: "Sin resultados",
                                 subtitle: "Prueba con otro término médico, como “heart” o “fiebre”.",
                                 tint: .mlCyan)
                } else {
                    ScrollView {
                        VStack(spacing: MLSpacing.sm + MLSpacing.xs) {
                            ForEach(vm.words) { word in row(word, vm: vm) }
                        }
                        .padding(MLSpacing.md)
                        .padding(.bottom, MLSpacing.xl)
                    }
                    .scrollDismissesKeyboard(.immediately)
                }
            }
            .padding(.top, MLSpacing.sm)
        } else {
            MLSkeletonList(rows: 6, rowHeight: 72)
        }
    }

    private func searchField(_ vm: VocabularyViewModel) -> some View {
        @Bindable var vm = vm
        return HStack(spacing: MLSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.mlTextTertiary)
            TextField("Buscar término…", text: $vm.query)
                .autocorrectionDisabled()
                .font(MLFont.body)
                .foregroundStyle(Color.mlTextPrimary)
                .submitLabel(.search)
                .onSubmit { Task { await vm.search() } }
            if !vm.query.isEmpty {
                Button {
                    vm.query = ""
                    Task { await vm.search() }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.mlTextTertiary)
                }
                .accessibilityLabel("Borrar búsqueda")
            }
        }
        .padding(MLSpacing.md)
        .background(Color.mlSurface, in: RoundedRectangle(cornerRadius: MLRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: MLRadius.md, style: .continuous)
                .strokeBorder(Color.mlCardStroke, lineWidth: 1)
        )
    }

    private func row(_ word: VocabularyWord, vm: VocabularyViewModel) -> some View {
        let isAdded = vm.added.contains(word.id)
        return MLCard {
            HStack(spacing: MLSpacing.md) {
                VStack(alignment: .leading, spacing: MLSpacing.xxs) {
                    HStack(spacing: MLSpacing.sm) {
                        Text(word.word)
                            .font(MLFont.headline)
                            .foregroundStyle(Color.mlTextPrimary)
                        if let phonetic = word.phonetic {
                            Text(phonetic)
                                .font(MLFont.mono)
                                .foregroundStyle(Color.mlTextTertiary)
                        }
                    }
                    Text(word.translationES)
                        .font(MLFont.subheadline)
                        .foregroundStyle(Color.mlTextSecondary)
                }
                Spacer(minLength: 0)
                Button {
                    MLHaptic.correct()
                    withAnimation(MLMotion.bouncy) { vm.addToDeck(word) }
                } label: {
                    Image(systemName: isAdded ? "checkmark.circle.fill" : "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(isAdded ? Color.mlEmerald : Color.mlPrimary)
                        .contentTransition(.symbolEffect(.replace))
                }
                .disabled(isAdded)
                .accessibilityLabel(isAdded ? "\(word.word) agregada al repaso" : "Agregar \(word.word) al repaso")
            }
        }
    }
}
