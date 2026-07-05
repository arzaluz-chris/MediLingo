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
                TextField("Buscar término…", text: $vm.query)
                    .autocorrectionDisabled()
                    .padding(MLSpacing.md)
                    .background(Color.mlSurface)
                    .clipShape(RoundedRectangle(cornerRadius: MLRadius.md))
                    .foregroundStyle(Color.mlTextPrimary)
                    .submitLabel(.search)
                    .onSubmit { Task { await vm.search() } }
                    .padding(.horizontal, MLSpacing.md)

                if vm.isLoading {
                    MLLoadingView()
                } else if vm.words.isEmpty {
                    MLEmptyState(systemImage: "magnifyingglass", title: "Sin resultados",
                                 subtitle: "Prueba con otro término.")
                } else {
                    ScrollView {
                        VStack(spacing: MLSpacing.sm) {
                            ForEach(vm.words) { word in row(word, vm: vm) }
                        }
                        .padding(MLSpacing.md)
                    }
                }
            }
            .padding(.top, MLSpacing.md)
        } else {
            MLLoadingView()
        }
    }

    private func row(_ word: VocabularyWord, vm: VocabularyViewModel) -> some View {
        MLCard {
            HStack(spacing: MLSpacing.md) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(word.word).font(MLFont.heading(17)).foregroundStyle(Color.mlTextPrimary)
                    Text(word.translationES).font(MLFont.caption()).foregroundStyle(Color.mlTextSecondary)
                }
                Spacer(minLength: 0)
                Button {
                    vm.addToDeck(word)
                } label: {
                    Image(systemName: vm.added.contains(word.id) ? "checkmark.circle.fill" : "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(vm.added.contains(word.id) ? Color.mlSuccess : Color.mlPrimary)
                }
                .disabled(vm.added.contains(word.id))
                .accessibilityLabel("Agregar \(word.word) al repaso")
            }
        }
    }
}
