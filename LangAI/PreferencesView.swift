import ComposableArchitecture
import SwiftUI

struct PreferencesView: View {
    @Bindable var store: StoreOf<Preferences>

    @Shared(.appStorage("llmEndpoint")) var llmEndpoint = ""
    @Shared(.appStorage("llmSecret")) var llmSecret = ""
    @Shared(.appStorage("sourceLanguage")) var sourceLanguage = ""
    @Shared(.appStorage("targetLanguage")) var targetLanguage = ""
    @Shared(.appStorage("cefrLevel")) var cefrLevel = ""
    @Shared(.appStorage("learningContext")) var context = ""

    var body: some View {
        VStack {
            HStack {
                TextField("LLM Endpoint", text: Binding($llmEndpoint))
                    .frame(maxWidth: 440)
            }

            HStack {
                TextField(text: Binding($llmSecret)) {
                    Text("LLM Secret")
                }
                .frame(maxWidth: 440)
            }

            HStack {
                Picker("Source language", selection: Binding($sourceLanguage)) {
                    ForEach(Language.allCases) { language in
                        Text(language.name).tag(language.name)
                    }
                }
                .frame(maxWidth: 240)
            }
            HStack {
                Picker("Target language", selection: Binding($targetLanguage)) {
                    ForEach(Language.allCases) { language in
                        Text(language.name).tag(language.name)
                    }
                }
                .frame(maxWidth: 240)
            }

            HStack {
                Picker("CEFR Level", selection: Binding($cefrLevel)) {
                    ForEach(CEFRLevel.allCases) { level in
                        Text(level.name).tag(level.name)
                    }
                }
                .frame(maxWidth: 240)
            }

            HStack {
                Picker("Context", selection: Binding($context)) {
                    ForEach(LanguageLearningTopic.allCases) { topic in
                        Text(topic.name).tag(topic.name)
                    }
                }
                .frame(maxWidth: 240)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 400)
    }
}
