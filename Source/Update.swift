import Foundation

struct Update {
    var write = false
    var share = false
    var upload = [Int]()
    var download = [Int]()
    let session: Session
    let result: () -> Void
    
    init(_ session: Session, result: @escaping () -> Void) {
        self.session = session
        self.result = result
    }
}
