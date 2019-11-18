import AppKit

final class Tags: NSView {
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        let width = widthAnchor.constraint(equalToConstant: 0)
        width.priority = .defaultLow
        width.isActive = true
    }
    
    func refresh() {
        app.session.tags(app.project!) { [weak self] in
            self?.tags($0)
        }
    }
    
    private func tags(_ tags: [(String, Int)]) {
        var top = topAnchor
        tags.forEach {
            let label = Label([("\($0.1)", 14, .light, NSColor(named: "haze")!),
                               (" #" + $0.0, 16, .bold, NSColor(named: "haze")!)])
            label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
            addSubview(label)
            
            rightAnchor.constraint(greaterThanOrEqualTo: label.rightAnchor, constant: 50).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 60).isActive = true
            label.topAnchor.constraint(equalTo: top, constant: 20).isActive = true
            top = label.bottomAnchor
        }
        bottomAnchor.constraint(equalTo: top, constant: 20).isActive = true
    }
}
