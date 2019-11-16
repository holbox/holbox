import Foundation

public final class Session {
    var store = Store()
    var rating = Calendar.current.date(byAdding: .day, value: 1, to: .init())!
    var items = [Int : Project]()
    var perks = [Perk]()
    var settings = Settings()
    var refreshed = Date().timeIntervalSince1970

    public var projects: [Int] {
        items.filter { $1.mode != .off }.sorted { $0.1.name.caseInsensitiveCompare($1.1.name) == .orderedAscending }.map { $0.0 }
    }
    
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
        Date().timeIntervalSince1970 > refreshed + 10
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
    
    public class func load(result: @escaping (Session) -> Void) {
        Store().load(result)
    }
    
    public func refresh(done: @escaping () -> Void) {
        if refreshable {
            refreshed = Date().timeIntervalSince1970
            store.refresh(self, done: done)
        } else {
            DispatchQueue.main.async {
                done()
            }
        }
    }
    
    public func rated() {
        rating = Calendar.current.date(byAdding: .month, value: 3, to: .init())!
        store.save(self)
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
            ($0[0], $0[1])
        } (items[project]!.cards[0].1[index].components(separatedBy: "\n"))
    }
    
    public func reference(_ project: Int, index: Int) -> (String, String) {
        product(project, index: Int(items[project]!.cards[1].1[index])!)
    }
    
    public func contains(_ project: Int, reference: Int) -> Bool {
        items[project]!.cards[1].1.contains(.init(reference))
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
    
    public func add(_ project: Int, emoji: String, description: String) {
        guard let item = product(emoji, description: description) else { return }
        items[project]!.cards[0].1.append(item)
        save(project)
    }
    
    public func add(_ project: Int, reference: Int) {
        guard !contains(project, reference: reference) else { return }
        items[project]!.cards[1].1.append(.init(reference))
        save(project)
    }
    
    public func content(_ project: Int, list: Int, card: Int, content: String) {
        guard items[project]!.cards[list].1[card] != content else { return }
        items[project]!.cards[list].1[card] = content
        save(project)
    }
    
    public func product(_ project: Int, index: Int, emoji: String, description: String) {
        guard let item = product(emoji, description: description), items[project]!.cards[0].1[index] != item else { return }
        items[project]!.cards[0].1[index] = item
        save(project)
    }
    
    public func move(_ project: Int, list: Int, card: Int, destination: Int, index: Int) {
        guard list != destination || card != index else { return }
        items[project]!.cards[destination].1.insert(items[project]!.cards[list].1.remove(at: card), at: index)
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
    
    public func tags(_ project: Int, result: @escaping ([String : Int]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let tags = self.items[project]!.cards.reduce([String : Int]()) {
                $1.1.reduce($0) { list, string in
                    string.indices.reduce(into: (list, nil) as ([String : Int], String?)) {
                        if $0.1 != nil {
                            if string[$1] != "#" && String(string[$1]).rangeOfCharacter(from: .whitespacesAndNewlines) == nil {
                                $0.1!.append(string[$1])
                                if $1 == string.index(before: string.endIndex) {
                                    $0.0[$0.1!] = ($0.0[$0.1!] ?? 0) + 1
                                }
                            } else if !$0.1!.isEmpty {
                                $0.0[$0.1!] = ($0.0[$0.1!] ?? 0) + 1
                                $0.1 = string[$1] == "#" ? "" : nil
                            }
                        } else if string[$1] == "#" {
                            $0.1 = ""
                        }
                    }.0
                }
            }
            DispatchQueue.main.async {
                result(tags)
            }
        }
    }
    
    private func product(_ emoji: String, description: String) -> String? {
        let emoji = {
            $0.unicodeScalars.first?.emoji == true ? $0 : ""
        } (emoji.trimmingCharacters(in: .whitespacesAndNewlines))
        let description = description.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !emoji.isEmpty || !description.isEmpty else { return nil }
        return emoji + "\n" + description
    }
    
    private func save(_ project: Int) {
        items[project]!.time = .init()
        store.save(self, id: project, project: items[project]!)
    }
}
