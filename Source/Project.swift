import Foundation

struct Project {
    var id = 0
    var mode = Mode.off
    var name = ""
    var cards = [(String, [String])]()
    var time = Date()
    
    static func make(_ mode: Mode, counter: Int) -> Project {
        var project = Project()
        let factory: Factory
        switch mode {
        case .kanban: factory = Kanban()
        default: fatalError()
        }
        project.mode = mode
        project.id = counter
        project.name = factory.name
        project.cards = factory.lists.map { ($0, []) }
        return project
    }
}

private protocol Factory {
    var name: String { get }
    var lists: [String] { get }
}

private struct Kanban: Factory {
    let name = "New Board"
    let lists = ["Waiting", "Doing", "Done"]
}

private struct Todo {
    let name = "New List"
}
