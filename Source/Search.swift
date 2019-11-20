import Foundation

final class Search {
    private var ranges = [(Int, Int, NSRange)]()
    private let project: Project
    private let string: String
    
    init(_ project: Project, string: String, result: @escaping ([(Int, Int, NSRange)]) -> Void) {
        self.project = project
        self.string = string.trimmingCharacters(in: .whitespacesAndNewlines)
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.search()
            DispatchQueue.main.async { [weak self] in
                guard let ranges = self?.ranges else { return }
                result(ranges)
            }
        }
    }
    
    private func search() {
        if !string.isEmpty {
            (0 ..< project.cards.count).forEach { list in
                (0 ..< project.cards[list].1.count).forEach { card in
                    let item = project.cards[list].1[card]
                    var index = item.startIndex
                    while index < item.endIndex,
                        let range = item.range(of: string, options: .caseInsensitive, range: index ..< item.endIndex) {
                            ranges.append((list, card, .init(range, in: item)))
                            index = range.upperBound
                    }
                }
            }
        }
    }
}
