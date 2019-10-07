import Foundation

public final class Project {
    public struct List {
        fileprivate var cards = [Card]()
        fileprivate var name = ""
        
        fileprivate init () { }
    }
    
    public struct Card {
        fileprivate var content = ""
        
        fileprivate init () { }
    }

    public var name = ""
    public var count: Int { lists.count }
    var store = Store()
    var id = 0
    private var lists = [List]()
    
    public init() { }
    
    public func add() {
        lists.append(.init())
        store.save(self)
    }
    
    public func name(_ list: Int) -> String {
        lists[list].name
    }
    
    public func edit(_ list: Int, name: String) {
        lists[list].name = name
        store.save(self)
    }
    
    public func count(_ list: Int) -> Int {
        lists[list].cards.count
    }
    
    public func add(_ list: Int) {
        lists[list].cards.append(.init())
        store.save(self)
    }
    
    public func content(_ list: Int, _ card: Int) -> String {
        lists[list].cards[card].content
    }
    
    public func edit(_ list: Int, _ card: Int, content: String) {
        lists[list].cards[card].content = content
        store.save(self)
    }
}
