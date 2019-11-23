import AppKit

class Chart: NSView {
    final class Kanban: Chart {
        var width = CGFloat()
        var space = CGFloat()
        
        override func draw() {
            let cards = (0 ..< app.session.lists(index)).reduce(into: [Int]()) {
                $0.append(app.session.cards(index, list: $1))
            }
            let total = CGFloat(cards.reduce(0, +))
            let height = bounds.height - (width / 2)
            cards.enumerated().forEach { card in
                let shape = CAShapeLayer()
                shape.strokeColor = NSColor(named: "haze")!.cgColor
                shape.lineWidth = width
                shape.fillColor = .clear
                let x = (.init(card.0) * (width + space)) + (width / 2)
                let y: CGFloat
                if total > 0 && card.1 > 0 {
                    shape.lineCap = .round
                    y = .init(card.1) / total * height
                } else {
                    y = 2
                }
                shape.path = {
                    $0.move(to: .init(x: x, y: -width))
                    $0.addLine(to: .init(x: x, y: y))
                    return $0
                } (CGMutablePath())
                layer!.addSublayer(shape)
            }
        }
    }
    
    final class Todo: Chart {
        override func draw() {
            let waiting = CGFloat(app.session.cards(index, list: 0))
            let done = CGFloat(app.session.cards(index, list: 1))
            let total = waiting + done
            let start = CGFloat()
            let first = start + (.pi * 2) * (done / total)
            let second = first + (.pi * 2) * (waiting / total)
            
            let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
            let radius = min(bounds.width, bounds.height) / 2
            let on = CAShapeLayer()
            on.fillColor = NSColor(named: "haze")!.cgColor
            on.lineWidth = 0
            on.path = {
                $0.move(to: center)
                $0.addArc(center: center, radius: radius, startAngle: start, endAngle: first, clockwise: false)
                $0.move(to: center)
                return $0
            } (CGMutablePath())
            layer!.addSublayer(on)
            
            let off = CAShapeLayer()
            off.fillColor = NSColor(named: "haze")!.withAlphaComponent(0.3).cgColor
            off.lineWidth = 0
            off.path = {
                $0.move(to: center)
                $0.addArc(center: center, radius: radius, startAngle: first, endAngle: second, clockwise: false)
                $0.move(to: center)
                return $0
            } (CGMutablePath())
            layer!.addSublayer(off)
        }
    }
    
    final class Shopping: Chart {
        var width = CGFloat()
        
        override func draw() {
            let products = CGFloat(app.session.cards(index, list: 0))
            let needed = CGFloat(app.session.cards(index, list: 1))
            let size = bounds.width - width
            let start = width / 2
            let first = start + (((products - needed) / products) * size)
            let second = first + ((needed / products) * size)
            let yFirst = bounds.midY + (width / 5)
            let ySecond = bounds.midY - (width / 5)
            
            if needed > 0 {
                let off = CAShapeLayer()
                off.strokeColor = NSColor(named: "haze")!.withAlphaComponent(0.3).cgColor
                off.lineWidth = width
                off.fillColor = .clear
                off.lineCap = .round
                off.path = {
                    $0.move(to: .init(x: first, y: ySecond))
                    $0.addLine(to: .init(x: second, y: ySecond))
                    return $0
                } (CGMutablePath())
                layer!.addSublayer(off)
            }
            
            if needed != products {
                let on = CAShapeLayer()
                on.strokeColor = NSColor(named: "haze")!.cgColor
                on.lineWidth = width
                on.fillColor = .clear
                on.lineCap = .round
                on.path = {
                    $0.move(to: .init(x: start, y: yFirst))
                    $0.addLine(to: .init(x: first, y: yFirst))
                    return $0
                } (CGMutablePath())
                layer!.addSublayer(on)
            }
        }
    }
    
    final class Spider: Chart {
        override func draw() {
            let cards = (0 ..< app.session.lists(index)).reduce(into: [Int]()) {
                $0.append(app.session.cards(index, list: $1))
            }
            let total = CGFloat(cards.max() ?? 1)
            let circ = (.pi * 2) / CGFloat(cards.count)
            let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
            let radius = bounds.width / 5
            
            let inner = CAShapeLayer()
            inner.fillColor = .clear
            inner.lineWidth = 2
            inner.lineCap = .round
            inner.strokeColor = .black
            
            let cross = CAShapeLayer()
            cross.fillColor = .clear
            cross.lineWidth = 2
            cross.lineCap = .round
            cross.strokeColor = NSColor(named: "haze")!.cgColor
            
            let shape = CAShapeLayer()
            shape.fillColor = NSColor(named: "haze")!.cgColor
            shape.lineWidth = 0
            
            let _shape = CGMutablePath(), _cross = CGMutablePath(), _inner = CGMutablePath()
            
            cards.enumerated().forEach { card in
                let size = max(.init(card.1) / total * (radius - 1), 10)
                let dummy = CGMutablePath()
                dummy.addArc(center: center, radius: size, startAngle: circ * .init(card.0), endAngle: circ * .init(card.0), clockwise: false)
                if card.0 == 0 {
                    _shape.move(to: dummy.currentPoint)
                } else {
                    _shape.addLine(to: dummy.currentPoint)
                }
                dummy.addArc(center: center, radius: radius, startAngle: circ * .init(card.0), endAngle: circ * .init(card.0), clockwise: false)
                
                _cross.move(to: center)
                _cross.addLine(to: dummy.currentPoint)
                
                dummy.addArc(center: center, radius: (size * 0.9), startAngle: circ * .init(card.0), endAngle: circ * .init(card.0), clockwise: false)
                
                _inner.move(to: center)
                _inner.addLine(to: dummy.currentPoint)
                
                dummy.addArc(center: center, radius: radius, startAngle: circ * .init(card.0), endAngle: circ * .init(card.0), clockwise: false)
                
                let label = Label(app.session.name(index, list: card.0), 14, .bold, NSColor(named: "haze")!)
                addSubview(label)
                
                if dummy.currentPoint.y == center.y {
                    label.centerYAnchor.constraint(equalTo: bottomAnchor, constant: -(dummy.currentPoint.y + 2)).isActive = true
                    label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor).isActive = true
                    label.leftAnchor.constraint(equalTo: leftAnchor, constant: dummy.currentPoint.x + 5).isActive = true
                } else if dummy.currentPoint.y > center.y {
                    label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -(dummy.currentPoint.y + 10)).isActive = true
                    label.leftAnchor.constraint(equalTo: leftAnchor, constant: dummy.currentPoint.x).isActive = true
                } else {
                    label.topAnchor.constraint(equalTo: bottomAnchor, constant: -(dummy.currentPoint.y - 10)).isActive = true
                    label.leftAnchor.constraint(equalTo: leftAnchor, constant: dummy.currentPoint.x).isActive = true
                }
            }
            
            shape.path = _shape
            cross.path = _cross
            inner.path = _inner
            layer!.addSublayer(shape)
            layer!.addSublayer(cross)
            layer!.addSublayer(inner)
        }
    }
    
    private let index: Int
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int) {
        self.index = index
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
    }
    
    override func draw(_: NSRect) {
        layer!.sublayers?.forEach { $0.removeFromSuperlayer() }
        subviews.forEach { $0.removeFromSuperview() }
        draw()
    }
    
    private func draw() {
        
    }
}
