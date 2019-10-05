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
    private var lists = [List]()
    
    public init() { }
    
    public func add() {
        lists.append(.init())
        store.save(self)
    }
    
    public func edit(_ index: Int, name: String) {
        lists[index].name = name
        store.save(self)
    }
    
    public func name(_ index: Int) -> String { lists[index].name }
}
