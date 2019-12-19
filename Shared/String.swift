import NaturalLanguage
import Foundation

extension String {
    static func key(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }
    
    var paragraphs: Int {
        var count = 0
        enumerateSubstrings(in: startIndex..., options: .byParagraphs) { string, _, _, _ in
            if string?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
                count += 1
            }
        }
        return count
    }
    
    var sentences: Int {
        var count = 0
        enumerateSubstrings(in: startIndex..., options: .bySentences) { string, _, _, _ in
            if string?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
                count += 1
            }
        }
        return count
    }
    
    var lines: Int {
        var count = 0
        enumerateSubstrings(in: startIndex..., options: .byLines) { string, _, _, _ in
            count += 1
        }
        return count
    }
    
    var words: Int {
        var count = 0
        enumerateSubstrings(in: startIndex..., options: .byWords) { string, _, _, _ in
            count += 1
        }
        return count
    }
    
    var language: String {
        if #available(OSX 10.15, *) {
            let tagger = NLTagger(tagSchemes: [.language])
            tagger.string = self
            switch tagger.tag(at: startIndex, unit: .document, scheme: .language).0?.rawValue {
            case "en": return .key("Language.english")
            case "de": return .key("Language.german")
            case "es": return .key("Language.spanish")
            case "fr": return .key("Language.french")
            default: break
            }
        }
        return ""
    }
    
    var sentiment: String {
        if #available(OSX 10.15, *) {
            let tagger = NLTagger(tagSchemes: [.sentimentScore])
            tagger.string = self
            let score = Double(tagger.tag(at: startIndex, unit: .paragraph, scheme: .sentimentScore).0?.rawValue ?? "0") ?? 0
            if score > 0 {
                return .key("Language.positive")
            } else if score < 0 {
                return .key("Language.negative")
            }
        }
        return .key("Language.neutral")
    }
}
