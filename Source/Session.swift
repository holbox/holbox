import Foundation

public final class Session {
    var user = ""
    var store = Store()
    var rating = Calendar.current.date(byAdding: .day, value: 1, to: .init())!
    var items = [Int : Project]()
    var perks = [Perk]()
    var settings = Settings()
    var refreshed = Date().timeIntervalSince1970
    private var search: Search?
    private let queue = DispatchQueue(label: "", qos: .background, target: .global(qos: .background))
    
    public var rate: Bool {
        Date() >= rating
    }
    
    public var available: Int {
        max(capacity - count, 0)
    }
    
    public var count: Int {
        items.values.filter { $0.mode != .off }.count
    }
    
    public var spell: Bool {
        settings.spell
    }
    
    public var refreshable: Bool {
        Date().timeIntervalSince1970 > refreshed + 5
    }
    
    public var capacity: Int {
        var result = 1
        perks.forEach {
            switch $0 {
            case .two: result += 2
            case .ten: result += 10
            case .hundred: result += 100
            }
        }
        return result
    }
    
    public init() { }
    
    public func load(completion: @escaping () -> Void) {
        store.load(self, completion: completion)
    }
    
    public func refresh(done: @escaping ([Int]) -> Void) {
        if refreshable {
            refreshed = Date().timeIntervalSince1970
            store.refresh(self, done: done)
        } else {
            DispatchQueue.main.async {
                done([])
            }
        }
    }
    
    public func rated() {
        rating = Calendar.current.date(byAdding: .month, value: 3, to: .init())!
        store.save(self)
    }
    
    public func projects(_ filter: String = "") -> [Int] {
        items
            .filter { $1.mode != .off }
            .filter { filter.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || $1.name.localizedCaseInsensitiveContains(filter.trimmingCharacters(in: .whitespacesAndNewlines)) }
            .sorted { $0.1.name.caseInsensitiveCompare($1.1.name) == .orderedAscending
                || ($0.1.name.caseInsensitiveCompare($1.1.name) == .orderedSame && $0.1.time > $1.1.time) }
            .map { $0.0 }
    }
    
    public func lists(_ project: Int) -> Int {
        items[project]!.cards.count
    }
    
    public func cards(_ project: Int, list: Int) -> Int {
        items[project]!.cards[list].1.count
    }
    
    public func purchased(_ perk: Perk) -> Bool {
        perks.contains(perk)
    }
    
    public func mode(_ project: Int) -> Mode {
        items[project]!.mode
    }
    
    public func name(_ project: Int) -> String {
        items[project]!.name
    }
    
    public func time(_ project: Int) -> Date {
        items[project]!.time
    }
    
    public func name(_ project: Int, list: Int) -> String {
        items[project]!.cards[list].0
    }
    
    public func content(_ project: Int, list: Int, card: Int) -> String {
        items[project]!.cards[list].1[card]
    }
    
    public func product(_ project: Int, index: Int) -> (String, String) {
        {
            ($0[0], $0.dropFirst().joined(separator: "\n"))
        } (items[project]!.cards[0].1[index].components(separatedBy: "\n"))
    }
    
    public func reference(_ project: Int, index: Int) -> (String, String) {
        product(project, index: Int(items[project]!.cards[1].1[index])!)
    }
    
    public func name(_ project: Int, name: String) {
        let name = name.replacingOccurrences(of: "\n", with: "")
        guard items[project]!.name != name else { return }
        items[project]!.name = name
        save(project)
    }
    
    public func add(_ project: Int) {
        items[project]!.cards.append((.init(), .init()))
        save(project)
    }
    
    public func name(_ project: Int, list: Int, name: String) {
        let name = name.replacingOccurrences(of: "\n", with: "")
        guard items[project]!.cards[list].0 != name else { return }
        items[project]!.cards[list].0 = name
        save(project)
    }
    
    public func add(_ project: Int, list: Int) {
        items[project]!.cards[list].1.insert(.init(), at: 0)
        save(project)
    }
    
    public func add(_ project: Int, list: Int, content: String) {
        items[project]!.cards[list].1.insert(content, at: 0)
        save(project)
    }
    
    public func content(_ project: Int, list: Int, card: Int, content: String) {
        guard items[project]!.cards[list].1[card] != content else { return }
        items[project]!.cards[list].1[card] = content
        save(project)
    }
    
    public func move(_ project: Int, list: Int, card: Int, destination: Int, index: Int) {
        guard list != destination || card != index else { return }
        items[project]!.cards[destination].1.insert(items[project]!.cards[list].1.remove(at: card), at: index)
        save(project)
    }
    
    public func completed(_ project: Int, index: Int) {
        items[project]!.cards[1].1.insert(items[project]!.cards[0].1.remove(at: index), at: 0)
        items[project]!.cards[2].1.insert("\(Int(Date().timeIntervalSince1970))", at: 0)
        save(project)
    }
    
    public func restart(_ project: Int, index: Int) {
        items[project]!.cards[0].1.insert(items[project]!.cards[1].1.remove(at: index), at: 0)
        items[project]!.cards[2].1.remove(at: index)
        save(project)
    }
    
    public func add(_ mode: Mode) -> Int {
        let id = items.filter { $0.1.mode != .off }.sorted { $0.0 < $1.0 }.reduce(into: 0) {
            if $1.0 == $0 {
                $0 = $1.0 + 1
            }
        }
        items[id] = .make(mode)
        save(id)
        return id
    }
    
    public func delete(_ project: Int) {
        items[project]!.mode = .off
        save(project)
    }
    
    public func delete(_ project: Int, list: Int) {
        items[project]!.cards.remove(at: list)
        save(project)
    }
    
    public func delete(_ project: Int, list: Int, card: Int) {
        items[project]!.cards[list].1.remove(at: card)
        save(project)
    }
    
    public func delete(_ project: Int, product: Int) {
        items[project]!.cards[0].1.remove(at: product)
        items[project]!.cards[1].1 = items[project]!.cards[1].1.compactMap {
            switch Int($0)! {
            case product: return nil
            case let index where index > product: return .init(index - 1)
            default: return $0
            }
        }
        save(project)
    }
    
    public func purchase(_ perk: Perk) {
        guard !perks.contains(perk) else { return }
        perks.append(perk)
        store.save(self)
    }
    
    public func spell(_ spell: Bool) {
        settings.spell = spell
        store.save(self)
    }
    
    public func tags(_ project: Int, compare: [(String, Int)], same: @escaping () -> Void, update: @escaping ([(String, Int)]) -> Void) {
        queue.async {
            let tags = self.items[project]!.cards.reduce([String : Int]()) {
                $1.1.reduce($0) { list, string in
                    string.indices.reduce(into: (list, nil) as ([String : Int], String?)) {
                        if $0.1 != nil {
                            if string[$1] != "#" && String(string[$1]).rangeOfCharacter(from: .whitespacesAndNewlines) == nil {
                                $0.1!.append(string[$1])
                                if $1 == string.index(before: string.endIndex) {
                                    $0.0[$0.1!.lowercased()] = ($0.0[$0.1!.lowercased()] ?? 0) + 1
                                }
                            } else if !$0.1!.isEmpty {
                                $0.0[$0.1!.lowercased()] = ($0.0[$0.1!.lowercased()] ?? 0) + 1
                                $0.1 = string[$1] == "#" ? "" : nil
                            } else {
                                $0.1 = nil
                            }
                        } else if string[$1] == "#" {
                            $0.1 = ""
                        }
                    }.0
                }
            }.sorted {
                if $0.1 == $1.1 {
                    return $0.0 < $1.0
                }
                return $0.1 > $1.1
            }
            var index = 0
            var similar = compare.count == tags.count
            while similar && index < compare.count {
                similar = compare[index].0 == tags[index].0 && compare[index].1 == tags[index].1
                index += 1
            }
            DispatchQueue.main.async {
                if similar {
                    same()
                } else {
                    update(tags)
                }
            }
        }
    }
    
    public func search(_ project: Int, string: String, result: @escaping ([(Int, Int, NSRange)]) -> Void) {
        search = .init(items[project]!, string: string, result: result)
    }
    
    public func csv(_ project: Int, result: @escaping (Data) -> Void) {
        queue.async {
            var string = self.items[project]!.cards.reduce(into: "") {
                $0 += $0.isEmpty ? self.csv($1.0) : "," + self.csv($1.0)
            }
            (0 ..< (self.items[project]!.cards.map { $0.1 }.max { $0.count < $1.count }?.count ?? 0)).forEach { index in
                string += "\n"
                self.items[project]!.cards.enumerated().forEach {
                    string += $0.0 > 0 ? "," : ""
                    string += $0.1.1.count > index ? self.csv($0.1.1[index]) : ""
                }
            }
            DispatchQueue.main.async {
                result(Data(string.utf8))
            }
        }
    }
    
    func update(_ user: String) {
        self.user = user
        store.save(self)
    }
    
    private func save(_ project: Int) {
        items[project]!.time = .init()
        store.save(self, id: project, project: items[project]!)
    }
    
    private func csv(_ string: String) -> String {
        "\"" + string.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }
}
