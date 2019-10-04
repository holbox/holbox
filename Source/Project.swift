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
    private var lists = [List]()
    
    public init() { }
    
    public func add() {
        lists.append(.init())
    }
    
    public func edit(_ index: Int, name: String) {
        lists[index].name = name
    }
    
    public func name(_ index: Int) -> String { lists[index].name }
}
