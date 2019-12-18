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
}
