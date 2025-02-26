import ComposableArchitecture
import Dependencies
import SFSafeSymbols
import SwiftUI

@Reducer
struct Main {
    @Reducer
    enum Destination {
        case preferences(Preferences)
    }

    @CasePathable
    enum Action: BindableAction {
        case search
        case setOriginalText(String)
        case searchTextChanged(String)
        case handleRating(RatingResponse)
        case binding(BindingAction<State>)
        case onAppear
        case next
        case generateSentence
        case openPreferences
        case destination(PresentationAction<Destination.Action>)
    }

    @ObservableState
    struct State {
        var search = ""
        var translation: String?
        var rating: RatingResponse?
        var originalText: String?

        @Presents var destination: Destination.State?

        var isTranslationPossible: Bool {
            originalText != nil
        }
    }

    @Dependency(LLMClient.self) var llmClient
    @Dependency(PromptClient.self) var promptClient

    @Shared(.appStorage("llmEndpoint")) var llmEndpoint = ""
    @Shared(.appStorage("llmModel")) var llmModel = ""
    @Shared(.appStorage("llmSecret")) var llmSecret = ""
    @Shared(.appStorage("sourceLanguage")) var sourceLanguage = ""
    @Shared(.appStorage("targetLanguage")) var targetLanguage = ""
    @Shared(.appStorage("cefrLevel")) var cefrLevel = ""
    @Shared(.appStorage("learningContext")) var context = ""

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .openPreferences:
                state.destination = .preferences(Preferences.State())
                return .none

            case .generateSentence:
                return .run { [llmEndpoint, llmModel, llmSecret, cefrLevel, sourceLanguage, topic = context] send in
                    // For future - sentence, paragraph, letter?
                    let prompt = try promptClient.generateSentence(
                        sourceLanguage: sourceLanguage,
                        cefrLevel: cefrLevel,
                        context: LanguageLearningTopic(rawValue: topic) ?? .everyday
                    )

                    #if DEBUG
                        print(prompt)
                    #endif

                    let phrase = try await llmClient.chat(endpoint: llmEndpoint, model: llmModel, bearer: llmSecret, input: prompt)
                    let languageSentence = try JSONDecoder().decode(LanguageSentence.self, from: phrase.message.data(using: .utf8)!)

                    await send(.setOriginalText(languageSentence.sentence))
                }

            case .next:
                state.originalText = nil
                state.rating = nil
                state.translation = nil

                return .send(.generateSentence)

            case .onAppear:
                return .send(.generateSentence)

            case let .searchTextChanged(query):
                #if os(iOS)
                    UIImpactFeedbackGenerator(style: .medium).prepare()
                #endif
                state.search = query
                return .none

            case let .handleRating(rating):
                state.rating = rating
                return .none

            case .search:
                guard let originalText = state.originalText else { return .none }
                let translation = state.search
                state.translation = translation
                state.search = ""
                #if os(iOS)
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                #endif

                return .run { [llmEndpoint, llmModel, llmSecret, targetLanguage] send in
                    let prompt = try promptClient.rateTranslation(
                        original: originalText,
                        translation: translation,
                        sourceLanguage: sourceLanguage,
                        targetLanguage: targetLanguage
                    )

                    #if DEBUG
                        print(prompt)
                    #endif
                    let output = try await llmClient.chat(
                        endpoint: llmEndpoint,
                        model: llmModel,
                        bearer: llmSecret,
                        input: prompt
                    )

                    let rating = try JSONDecoder().decode(RatingResponse.self, from: output.message.data(using: .utf8)!)
                    await send(.handleRating(rating))
                }

            case let .setOriginalText(originalText):
                state.originalText = originalText
                return .none

//            case .destination(.dismiss):
//                return .send(.next)

            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
