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
        
        let height = heightAnchor.constraint(equalToConstant: 0)
        height.priority = .defaultLow
        height.isActive = true
    }
    
    func refresh() {
        app.session.tags(app.project, compare: tags, same: { [weak self] in
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
        subviews.forEach { $0.removeFromSuperview() }
        if !tags.isEmpty {
            var top = topAnchor
            tags.forEach {
                let tag = Tag($0.0, count: $0.1)
                addSubview(tag)
                
                rightAnchor.constraint(greaterThanOrEqualTo: tag.rightAnchor, constant: 10).isActive = true
                tag.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
                tag.topAnchor.constraint(equalTo: top).isActive = true
                top = tag.bottomAnchor
            }
            bottomAnchor.constraint(equalTo: top).isActive = true
        }
        layoutSubtreeIfNeeded()
        NSAnimationContext.runAnimationGroup ({
            $0.duration = 0.6
            $0.allowsImplicitAnimation = animate
            alphaValue = 1
            superview!.layoutSubtreeIfNeeded()
        }) { [weak self] in
            self?.animate = true
        }
    }
}
