import Foundation

struct Project {
    var id = 0
    var mode = Mode.off
    var name = ""
    var cards = [(String, [String])]()
    var time = Date()
}
