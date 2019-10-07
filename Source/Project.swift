import Foundation

final class Project {
    struct List {
        var name = ""
        var cards = [String]()
    }
    
    var id = 0
    var mode = Mode.off
    var name = ""
    var lists = [List]()
    var time = Date()
}
