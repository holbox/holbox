import AppKit

class Chart: NSView {
    final class Kanban: Chart {
        var width = CGFloat()
        var space = CGFloat()
        
        override func draw(_ rect: NSRect) {
            let cards = (0 ..< app.session.lists(index)).reduce(into: [Int]()) {
                $0.append(app.session.cards(index, list: $1))
            }
            let total = CGFloat(cards.reduce(0, +))
            let height = rect.height - (width / 2)
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
        override func draw(_ rect: NSRect) {
            let waiting = CGFloat(app.session.cards(index, list: 0))
            let done = CGFloat(app.session.cards(index, list: 1))
            let total = waiting + done
            let start = CGFloat()
            let first = start + (.pi * 2) * (done / total)
            let second = first + (.pi * 2) * (waiting / total)
            
            let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
            let radius = min(rect.width, rect.height) / 2
            let on = CAShapeLayer()
            on.fillColor = NSColor(named: "haze")!.cgColor
            on.lineWidth = 0
            on.path = {
                $0.move(to: center)
                $0.addArc(center: center, radius: radius - 3, startAngle: start, endAngle: first, clockwise: false)
                $0.move(to: center)
                return $0
            } (CGMutablePath())
            layer!.addSublayer(on)
            
            let off = CAShapeLayer()
            off.fillColor = NSColor(named: "haze")!.withAlphaComponent(0.3).cgColor
            off.lineWidth = 0
            off.path = {
                $0.move(to: center)
                $0.addArc(center: center, radius: radius - 3, startAngle: first, endAngle: second, clockwise: false)
                $0.move(to: center)
                return $0
            } (CGMutablePath())
            layer!.addSublayer(off)
        }
    }
    
    final class Shopping: Chart {
        var width = CGFloat()
        
        override func draw(_ rect: NSRect) {
            let products = CGFloat(app.session.cards(index, list: 0))
            let needed = CGFloat(app.session.cards(index, list: 1))
            let size = rect.width - width
            let start = width / 2
            let first = start + (((products - needed) / products) * size)
            let second = first + ((needed / products) * size)
            let yFirst = rect.midY + (width / 5)
            let ySecond = rect.midY - (width / 5)
            
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
    
    private let index: Int
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int) {
        self.index = index
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
    }
}
