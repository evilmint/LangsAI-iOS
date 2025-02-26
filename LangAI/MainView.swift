import ComposableArchitecture
import SwiftUI

struct MainView: View {
    @Bindable var store: StoreOf<Main>
    @State var textFieldLabel = "Your translation"

    @Shared(.appStorage("llmEndpoint")) var llmEndpoint = ""
    @Shared(.appStorage("llmSecret")) var llmSecret = ""
    @Shared(.appStorage("sourceLanguage")) var sourceLanguage = ""
    @Shared(.appStorage("targetLanguage")) var targetLanguage = ""
    @Shared(.appStorage("cefrLevel")) var cefrLevel = ""
    @Shared(.appStorage("learningContext")) var context = ""

    init(store: StoreOf<Main>) {
        self.store = store

        #if os(iOS)
            UIPageControl.appearance().currentPageIndicatorTintColor = .primary
            UIPageControl.appearance().pageIndicatorTintColor = .neutral300
            UIPageControl.appearance().tintColor = .red
        #endif
    }

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let originalText = store.originalText {
                        Text(originalText)
                            .multilineTextAlignment(.center)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.neutral200)
                    } else {
                        ActivityIndicator()
                            .frame(width: 32, height: 32)
                            .padding()
                    }

                    if let translation = store.translation {
                        Divider()
                            .foregroundStyle(.neutral200)
                        Text(translation)
                            .foregroundStyle(.neutral200)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity)
                    }

                    if let rating = store.rating {
                        let localizedDescription = LocalizedStringKey(rating.shortDescription)
                        let localizedCorrected = LocalizedStringKey(rating.correctedTranslation)
                        let localizedTips = LocalizedStringKey(rating.feedbackAndTips)

                        Divider()
                            .foregroundStyle(.neutral200)
                        VStack(alignment: .center) {
                            Text(rating.cefrRating)
                                .foregroundStyle(.neutral200)
                                .font(.largeTitle)

                            Text(localizedDescription)
                                .foregroundStyle(.neutral200)
                                .multilineTextAlignment(.center)
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity)

                        Text("Corrected translation")
                            .foregroundStyle(.neutral200)
                            .font(.headline)

                        Text(localizedCorrected)
                            .foregroundStyle(.neutral200)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity)

                        Text("Tips")
                            .foregroundStyle(.neutral200)
                            .font(.headline)

                        Text(localizedTips)
                            .foregroundStyle(.neutral200)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(32)

                Spacer()
            }
            .frame(maxHeight: .infinity)
            .layoutPriority(1)

            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    if store.rating == nil {
                        TextField(textFieldLabel, text: $store.search.sending(\.searchTextChanged))
                            .foregroundColor(.textColor100)
                            .font(.title3)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 12)
                            .autocorrectionDisabled()
                            .background(.neutral200.opacity(0.3))
                            .mask(RoundedRectangle(cornerRadius: 24))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.neutral200.opacity(0.6), lineWidth: 1)
                            )
                            .onKeyPress(.return) {
                                #if os(macOS)
                                    store.send(.search)
                                #endif
                                return .handled
                            }
                            .textFieldStyle(PlainTextFieldStyle())

                        Button {
                            store.send(.search)
                        } label: {
                            Image(systemSymbol: .arrowForwardCircleFill)
                                .resizable()
                                .frame(width: 40, height: 40)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .foregroundStyle(store.isTranslationPossible ? .neutral300 : .neutral200)
                        .sensoryFeedback(trigger: store.rating == nil) { _, _ in
                            .impact(flexibility: .solid, intensity: 0.3)
                        }
                        .disabled(store.isTranslationPossible == false)
                    } else {
                        HStack {
//                            Picker("Context", selection: $store.topicSelected) {
//                                ForEach(LanguageLearningTopic.allCases) { topic in
//                                    Text(topic.name).tag(topic)
//                                }
//                            }
//                            .frame(maxWidth: 240)

                            Button {
                                store.send(.next)
                            } label: {
                                Image(systemSymbol: .arrowUturnLeftCircleFill)
                                    .resizable()
                                    .frame(width: 40, height: 40)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .foregroundStyle(.themePrimary)
                            .sensoryFeedback(trigger: store.rating == nil) { _, _ in
                                .impact(flexibility: .solid, intensity: 0.3)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, 12)
                .padding(.horizontal, 32)
                .background(.thinMaterial)

                Color.clear
                    .ignoresSafeArea(.all)
                    .frame(maxWidth: .infinity)
                    .background(.neutral100)
            }
            .sheet(
                item: $store.scope(
                    state: \.destination?.preferences, action: \.destination.preferences
                )
            ) { store in
                PreferencesView(store: store)
            }
            .navigationSubtitle("\(context) \(cefrLevel) · \(sourceLanguage) to \(targetLanguage)")
        }
        .background(.thinMaterial)
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    MainView(
        store: Store(initialState: Main.State()) {
            Main()
        }
    )
}
