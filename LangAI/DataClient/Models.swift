import Foundation

struct LanguageSentence: Codable {
    let sentence: String
}

struct RatingResponse: Codable {
    let cefrRating: String
    let outOfTenScale: Int
    let shortDescription: String
    let correctedTranslation: String
    let feedbackAndTips: String

    enum CodingKeys: String, CodingKey {
        case cefrRating = "cefr_rating"
        case outOfTenScale = "out_of_ten_scale"
        case shortDescription = "short_description"
        case correctedTranslation = "corrected_translation"
        case feedbackAndTips = "feedback_and_tips"
    }
}

enum LanguageLearningTopic: String, Identifiable, CaseIterable {
    var id: LanguageLearningTopic {
        self
    }

    var name: String {
        switch self {
        case .professional:
            "Professional Job"
        case .everyday:
            "Everyday"
        case .literature:
            "Literature"
        case .exam:
            "Examination / Learning"
        }
    }

    case professional
    case everyday
    case literature
    case exam
}

enum Language: String, Identifiable, CaseIterable {
    var id: Self { self }

    var name: String {
        switch self {
        case .mandarin:
            return "Mandarin Chinese"
        case .spanish:
            return "Spanish"
        case .english:
            return "English"
        case .portuguese:
            return "Portuguese"
        case .russian:
            return "Russian"
        case .japanese:
            return "Japanese"
        case .turkish:
            return "Turkish"
        case .korean:
            return "Korean"
        case .french:
            return "French"
        case .german:
            return "German"
        case .vietnamese:
            return "Vietnamese"
        case .tamil:
            return "Tamil"
        case .cantonese:
            return "Cantonese"
        case .urdu:
            return "Urdu"
        case .indonesian:
            return "Indonesian"
        case .italian:
            return "Italian"
        case .arabic:
            return "Arabic"
        case .persian:
            return "Persian"
        case .polish:
            return "Polish"
        }
    }

    case mandarin
    case spanish
    case english
    case portuguese
    case russian
    case japanese
    case turkish
    case korean
    case french
    case german
    case vietnamese
    case tamil
    case cantonese
    case urdu
    case indonesian
    case italian
    case arabic
    case persian
    case polish
}

enum CEFRLevel: String, Identifiable, CaseIterable {
    var id: Self {
        self
    }

    var name: String {
        switch self {
        case .a1:
            "A1"
        case .a2:
            "A2"
        case .b1:
            "B1"
        case .b2:
            "B2"
        case .c1:
            "C1"
        case .c2:
            "C2"
        }
    }

    case a1
    case a2
    case b1
    case b2
    case c1
    case c2
}
