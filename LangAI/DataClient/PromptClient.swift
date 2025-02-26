import ComposableArchitecture
import Foundation

@DependencyClient
struct PromptClient: Sendable {
    var rateTranslation: @Sendable (_ original: String, _ translation: String, _ sourceLanguage: String, _ targetLanguage: String) throws -> String
    var generateSentence: @Sendable (_ sourceLanguage: String, _ cefrLevel: String, _ context: LanguageLearningTopic) throws -> String
}

enum PromptClientError: Error {
    case encodingError
}

extension PromptClient: DependencyKey {
    static let liveValue: Self = .init(
        rateTranslation: { original, translation, sourceLanguage, targetLanguage in
            let sampleRatingResponse = RatingResponse(
                cefrRating: "B2",
                outOfTenScale: 7,
                shortDescription: "Short description of the translation.",
                correctedTranslation: "Corrected translation here",
                feedbackAndTips: "Tips and feedback with markdown here"
            )

            guard let json = try String(data: JSONEncoder().encode(sampleRatingResponse), encoding: .utf8) else {
                throw PromptClientError.encodingError
            }

            return """
            You gave me the sentence \"\(original)\" to translate into \(targetLanguage). 
            Here's my attempt: \"\(translation)\". 
            Rate it on CEFR A1-C2 scale and on 1-10 scale and give me tips. 
            Don't be harsh with the rating, considering the words an average person knows at each level. 
            Be encouraging in the short description and tips. 
            Output the your feedback into this json in the \(sourceLanguage) language and don't output anything else than this json, also skip markdown tags like json```, but you are allowed to use markdown INSIDE the json. 
            Please bolden the replaced words with markdown in the corrected translation. 
            Here's the json: \(json)
            """
        },
        generateSentence: { sourceLanguage, cefrLevel, context in
            let sampleSentenceResponse = LanguageSentence(sentence: "sentence_here")

            guard let json = try String(data: JSONEncoder().encode(sampleSentenceResponse), encoding: .utf8) else {
                throw PromptClientError.encodingError
            }

            let structure = #"{"sentence": "sentence_here"}"#
            return """
            Give me a random sentence which would take place in a \(context.name) context, at \(cefrLevel) CEFR level in \(sourceLanguage) 
            in json in the structure \(json). 
            Also don't write anything else apart from the json, not even the markdown/formatting quotes.
            """
        }
    )
}
