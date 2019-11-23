import Foundation

final class Search {
    private var ranges = [(Int, Int, NSRange)]()
    private let project: Project
    private let string: String
    
    init(_ project: Project, string: String, result: @escaping ([(Int, Int, NSRange)]) -> Void) {
        self.project = project
        self.string = string.trimmingCharacters(in: .whitespacesAndNewlines)
        DispatchQueue.global(qos: .background).async { [weak self] in
            switch project.mode {
            case .shopping: self?.product()
            default: self?.search()
            }
            DispatchQueue.main.async { [weak self] in
                guard let ranges = self?.ranges else { return }
                result(ranges)
            }
        }
    }
    
    private func search() {
        if !string.isEmpty {
            (0 ..< project.cards.count).forEach { list in
                (0 ..< project.cards[list].1.count).forEach {
                    item(list, $0, project.cards[list].1[$0])
                }
            }
        }
    }
    
    private func product() {
        if !string.isEmpty {
            (0 ..< project.cards[1].1.count).forEach {
                item(1, $0, project.cards[0].1[Int(project.cards[1].1[$0])!].components(separatedBy: "\n").dropFirst().joined(separator: "\n"))
            }
            (0 ..< project.cards[0].1.count).forEach {
                item(0, $0, project.cards[0].1[$0])
            }
        }
    }
    
    private func item(_ list: Int, _ card: Int, _ content: String) {
        var index = content.startIndex
        while index < content.endIndex,
            let range = content.range(of: string, options: .caseInsensitive, range: index ..< content.endIndex) {
                ranges.append((list, card, .init(range, in: content)))
                index = range.upperBound
        }
    }
}
