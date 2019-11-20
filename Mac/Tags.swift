import AppKit

final class Tags: NSView {
    override var mouseDownCanMoveWindow: Bool { false }
    private var animate = false
    private var tags = [(String, Int)]()
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        let width = widthAnchor.constraint(equalToConstant: 0)
        width.priority = .defaultLow
        width.isActive = true
    }
    
    func refresh() {
        app.session.tags(app.project!, compare: tags, same: { [weak self] in
            self?.animate = true
        }) { [weak self] in
            guard let self = self else { return }
            self.tags = $0
            NSAnimationContext.runAnimationGroup({
                $0.duration = 0.3
                $0.allowsImplicitAnimation = self.animate
                self.alphaValue = 0
            }) { [weak self] in
                self?.render()
            }
        }
    }
    
    private func render() {
        alphaValue = 1
        subviews.forEach { $0.removeFromSuperview() }
        if !tags.isEmpty {
            var top = topAnchor
            tags.forEach {
                let label = Label([("\($0.1)", 13, .medium, NSColor(named: "haze")!),
                                   (" #" + $0.0, 14, .bold, NSColor(named: "haze")!)])
                label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
                addSubview(label)
                
                rightAnchor.constraint(greaterThanOrEqualTo: label.rightAnchor, constant: 20).isActive = true
                label.leftAnchor.constraint(equalTo: leftAnchor, constant: 40).isActive = true
                label.topAnchor.constraint(equalTo: top, constant: 20).isActive = true
                top = label.bottomAnchor
            }
            bottomAnchor.constraint(equalTo: top, constant: 20).isActive = true
        }
        NSAnimationContext.runAnimationGroup ({
            $0.duration = 0.6
            $0.allowsImplicitAnimation = animate
            superview!.layoutSubtreeIfNeeded()
        }) { [weak self] in
            self?.animate = true
        }
    }
}
