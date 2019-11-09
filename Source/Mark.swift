import Foundation

public extension String {
    enum Mode {
        case plain
        case bold
        case emoji
    }
    
    func mark<T>(_ transform: (Mode, Range<Index>) throws -> T) rethrows -> [T] {
        try indices.reduce(into: [(Mode, Range<Index>)]()) {
            var mode = Mode.plain
            var range = $1 ..< index(after: $1)
            if let position = $1.samePosition(in: unicodeScalars),
            unicodeScalars[position].emoji {
                mode = .emoji
            } else if self[$1] == "#" {
                mode = .bold
            } else if let last = $0.last {
                if last.0 == .bold && !self[last.1.upperBound ... $1].contains("\n") {
                    mode = .bold
                } else if last.0 == .emoji {
                    if let previous = $0.suffix(2).first {
                        if previous.0 == .bold && !self[previous.1.upperBound ... $1].contains("\n") {
                            mode = .bold
                        }
                    }
                }
            }
            if mode == $0.last?.0 {
                range = $0.removeLast().1.lowerBound ..< range.upperBound
            }
            $0.append((mode, range))
        }.map(transform)
    }
}

extension Unicode.Scalar {
    var emoji: Bool { properties.isEmojiPresentation || properties.generalCategory == .otherSymbol }
}
