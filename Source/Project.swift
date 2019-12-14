import Foundation

struct Project {
    var mode = Mode.off
    var name = ""
    var cards = [(String, [String])]()
    var time = Date()
    
    static func make(_ mode: Mode) -> Project {
        var project = Project()
        let factory: Factory
        switch mode {
        case .kanban: factory = Kanban()
        case .todo: factory = Todo()
        case .shopping: factory = Shopping()
        case .notes: factory = Notes()
        default: fatalError()
        }
        project.mode = mode
        project.name = factory.name
        project.cards = factory.lists
        return project
    }
}

private protocol Factory {
    var name: String { get }
    var lists: [(String, [String])] { get }
}

private struct Kanban: Factory {
    let name = "NEW BOARD"
    let lists: [(String, [String])] = [("TODO", []), ("DOING", []), ("DONE", [])]
}

private struct Todo: Factory {
    let name = "NEW LIST"
    let lists: [(String, [String])] = [("", []), ("", [])]
}

private struct Shopping: Factory {
    let name = "GROCERIES"
    let lists: [(String, [String])] = [("", []), ("", [])]
}

private struct Notes: Factory {
    let name = "NOTE"
    let lists = [("\(Int(Date().timeIntervalSince1970))", [""])]
}
