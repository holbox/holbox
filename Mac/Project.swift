import AppKit

class Project: NSView {
    let project: Int
    
    required init?(coder: NSCoder) { nil }
    init(_ project: Int) {
        self.project = project
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
    }
}
