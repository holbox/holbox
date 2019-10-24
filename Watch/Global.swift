import holbox
import Foundation

final class Global: ObservableObject {
    @Published var session: Session!
    @Published var project: Int?
    @Published var card: Int?
    var mode = Mode.off
}
