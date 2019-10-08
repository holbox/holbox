import Foundation

struct Update {
    var write = false
    var share = false
    var upload = [Int]()
    var download = [Int]()
    var session = Session()
    var result: (Session) -> Void
}
