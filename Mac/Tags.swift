import AppKit

final class Tags: NSView {
    private final class Tag: NSView {
        private let name: String
        
        required init?(coder: NSCoder) { nil }
        init(_ name: String, count: Int) {
            self.name = name
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            setAccessibilityElement(true)
            setAccessibilityRole(.button)
            
            let label = Label([("\(count)", 13, .medium, NSColor(named: "haze")!),
                               (" #" + name, 14, .bold, NSColor(named: "haze")!)])
            label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
            setAccessibilityLabel(label.stringValue)
            addSubview(label)
            
            heightAnchor.constraint(equalToConstant: 34).isActive = true
            rightAnchor.constraint(equalTo: label.rightAnchor, constant: 10).isActive = true
            
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        }
        
        override func resetCursorRects() {
            addCursorRect(bounds, cursor: .pointingHand)
        }
        
        override func mouseDown(with: NSEvent) {
            alphaValue = 0.3
            super.mouseDown(with: with)
        }
        
        override func mouseUp(with: NSEvent) {
            if bounds.contains(convert(with.locationInWindow, from: nil)) && with.clickCount == 1 {
                app.main.bar.find.search("#"+name)
            }
            alphaValue = 1
            super.mouseUp(with: with)
        }
    }

    
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
                let tag = Tag($0.0, count: $0.1)
                addSubview(tag)
                
                rightAnchor.constraint(greaterThanOrEqualTo: tag.rightAnchor, constant: 10).isActive = true
                tag.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
                tag.topAnchor.constraint(equalTo: top).isActive = true
                top = tag.bottomAnchor
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
