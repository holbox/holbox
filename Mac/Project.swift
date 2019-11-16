import AppKit

final class Project: NSView {
    private final class Button: NSView {
        private let index: Int
        
        required init?(coder: NSCoder) { nil }
        init(_ index: Int) {
            self.index = index
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            setAccessibilityElement(true)
            setAccessibilityRole(.button)
            setAccessibilityLabel(app.session.name(index))
            wantsLayer = true
            layer!.cornerRadius = 6
            layer!.backgroundColor = NSColor(named: "background")!.cgColor
            
            let label = Label(app.session.name(index), 16, .medium, NSColor(named: "haze")!)
            label.setAccessibilityElement(false)
            addSubview(label)
            
            rightAnchor.constraint(equalTo: label.rightAnchor, constant: 10).isActive = true
            bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 10).isActive = true
            
            label.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
            
            addTrackingArea(.init(rect: .zero, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self))
        }
        
        override func resetCursorRects() { addCursorRect(bounds, cursor: .pointingHand) }
        
        override func mouseEntered(with: NSEvent) {
            super.mouseEntered(with: with)
            layer!.backgroundColor = NSColor(named: "haze")!.withAlphaComponent(0.7).cgColor
        }
        
        override func mouseExited(with: NSEvent) {
            super.mouseExited(with: with)
            layer!.backgroundColor = NSColor(named: "background")!.cgColor
        }
        
        override func mouseDown(with: NSEvent) {
            alphaValue = 0.5
            super.mouseDown(with: with)
        }
        
        override func mouseUp(with: NSEvent) {
            if bounds.contains(convert(with.locationInWindow, from: nil)) && with.clickCount == 1 {
                app.project = index
            }
            alphaValue = 1
            super.mouseUp(with: with)
        }
    }
    
    private final class Chart: NSView {
        required init?(coder: NSCoder) { nil }
        init(_ index: Int) {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            wantsLayer = true
            
            let cards = (0 ..< app.session.lists(index)).reduce(into: [Int]()) {
                $0.append(app.session.cards(index, list: $1))
            }
            let total = CGFloat(cards.reduce(0, +))
            cards.enumerated().forEach { card in
                let shape = CAShapeLayer()
                shape.fillColor = .clear
                shape.strokeColor = NSColor(named: "haze")!.withAlphaComponent(0.3).cgColor
                shape.lineWidth = 10
                let x = CGFloat(card.0 * 30) + 10
                let y: CGFloat
                if total > 0 && card.1 > 0 {
                    shape.lineCap = .round
                    y = .init(card.1) / total * 50
                } else {
                    y = 2
                }
                shape.path = {
                    $0.move(to: .init(x: x, y: -10))
                    $0.addLine(to: .init(x: x, y: y))
                    return $0
                } (CGMutablePath())
                layer!.addSublayer(shape)
            }
            heightAnchor.constraint(equalToConstant: 65).isActive = true
            widthAnchor.constraint(equalToConstant: 27 * .init(cards.count)).isActive = true
        }
    }

    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        
        let button = Button(index)
        addSubview(button)
        
        let info = Label([("hello world", 14, .light, .init(white: 1, alpha: 0.5))])
        info.setAccessibilityElement(false)
        addSubview(info)
        
        let chart = Chart(index)
        addSubview(chart)
        
        rightAnchor.constraint(greaterThanOrEqualTo: info.rightAnchor).isActive = true
        rightAnchor.constraint(greaterThanOrEqualTo: chart.rightAnchor).isActive = true
        bottomAnchor.constraint(greaterThanOrEqualTo: info.bottomAnchor, constant: 20).isActive = true
        bottomAnchor.constraint(greaterThanOrEqualTo: chart.bottomAnchor, constant: 20).isActive = true
        
        button.topAnchor.constraint(equalTo: topAnchor).isActive = true
        button.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        
        info.topAnchor.constraint(equalTo: button.topAnchor, constant: 10).isActive = true
        info.leftAnchor.constraint(greaterThanOrEqualTo: button.rightAnchor, constant: 10).isActive = true
        info.leftAnchor.constraint(greaterThanOrEqualTo: chart.rightAnchor, constant: 10).isActive = true
        
        chart.topAnchor.constraint(equalTo: button.bottomAnchor).isActive = true
        chart.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
    }
}
