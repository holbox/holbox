import Foundation

final class Search {
    private let project: Project
    private let string: String
    
    init(_ project: Project, string: String, result: @escaping ([(Int, Int, Range<String.Index>)]) -> Void) {
        self.project = project
        self.string = string
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let ranges = self?.search() else { return }
            DispatchQueue.main.async { [weak self] in
                self?.done(ranges, result: result)
            }
        }
    }
    
    private func search() -> [(Int, Int, Range<String.Index>)] {
        var ranges = [(Int, Int, Range<String.Index>)]()
        if !string.isEmpty {
            (0 ..< project.cards.count).forEach { list in
                (0 ..< project.cards[list].1.count).forEach { card in
                    let item = project.cards[list].1[card]
                    var index = item.startIndex
                    while index < item.endIndex,
                        let range = item.range(of: string, options: .caseInsensitive, range: index ..< item.endIndex) {
                            ranges.append((list, card, range))
                            index = range.upperBound
                    }
                }
            }
        }
        return ranges
    }
    
    private func done(_ ranges: [(Int, Int, Range<String.Index>)], result: @escaping ([(Int, Int, Range<String.Index>)]) -> Void) {
        result(ranges)
    }
}
