import AppKit

class Chart: NSView {
    final class Lines: Chart {
        private let index: Int
        private let width = CGFloat(6)
        private let space = CGFloat(20)
        
        required init?(coder: NSCoder) { nil }
        init(_ index: Int) {
            self.index = index
            super.init()
        }
        
        override func draw(_: NSRect) {
            layer!.sublayers?.forEach { $0.removeFromSuperlayer() }
            let cards = (0 ..< app.session.lists(index)).reduce(into: [Int]()) {
                $0.append(app.session.cards(index, list: $1))
            }
            let total = CGFloat(cards.max() ?? 1)
            let height = bounds.height - (width / 2) - width - space
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
        private let index: Int
        
        required init?(coder: NSCoder) { nil }
        init(_ index: Int) {
            self.index = index
            super.init()
        }
        
        override func draw(_: NSRect) {
            layer!.sublayers?.forEach { $0.removeFromSuperlayer() }
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
            off.fillColor = NSColor(named: "haze")!.withAlphaComponent(0.2).cgColor
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
        private let index: Int
        private let width = CGFloat(12)
        
        required init?(coder: NSCoder) { nil }
        init(_ index: Int) {
            self.index = index
            super.init()
        }
        
        override func draw(_: NSRect) {
            layer!.sublayers?.forEach { $0.removeFromSuperlayer() }
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
                off.strokeColor = NSColor(named: "haze")!.withAlphaComponent(0.2).cgColor
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
        private let width = CGFloat(300)
        private let height = CGFloat(250)
        
        required init?(coder: NSCoder) { nil }
        override init() {
            super.init()
            
            let cards = (0 ..< app.session.lists(app.project!)).reduce(into: [Int]()) {
                $0.append(app.session.cards(app.project!, list: $1))
            }
            let total = CGFloat(cards.max() ?? 1)
            let circ = (.pi * 2) / CGFloat(cards.count)
            let center = CGPoint(x: width / 2, y: height / 2)
            let radius = width / 5
            
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
                let size = total > 0 ? max(.init(card.1) / total * (radius - 1), 10) : 20
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
                
                let label = Label(app.session.name(app.project!, list: card.0), 12, .bold, NSColor(named: "haze")!)
                addSubview(label)
                
                if dummy.currentPoint.y == center.y {
                    label.centerYAnchor.constraint(equalTo: bottomAnchor, constant: -(dummy.currentPoint.y + 2)).isActive = true
                    label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor).isActive = true
                    label.leftAnchor.constraint(equalTo: leftAnchor, constant: dummy.currentPoint.x + 5).isActive = true
                } else if dummy.currentPoint.y > center.y {
                    label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -(dummy.currentPoint.y + 10)).isActive = true
                    label.rightAnchor.constraint(equalTo: leftAnchor, constant: dummy.currentPoint.x).isActive = true
                    label.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor).isActive = true
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
            
            widthAnchor.constraint(equalToConstant: width).isActive = true
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    final class Kanban: Chart {
        private var totalWidth = CGFloat()
        private var totalHeight = CGFloat()
        private let height = CGFloat(200)
        private let width = CGFloat(15)
        private let space = CGFloat(55)
        
        required init?(coder: NSCoder) { nil }
        override init() {
            super.init()
            totalWidth = (.init(app.session.lists(app.project!)) * (width + space)) + 70
            totalHeight = height + 60 + width
            
            let cards = (0 ..< app.session.lists(app.project!)).reduce(into: [Int]()) {
                $0.append(app.session.cards(app.project!, list: $1))
            }
            let top = CGFloat(cards.max() ?? 1)
            
            let mask = CALayer()
            mask.masksToBounds = true
            mask.frame = .init(x: 0, y: 60, width: totalWidth, height: totalHeight - 60)
            layer!.addSublayer(mask)
            
            cards.enumerated().forEach { card in
                let shape = CAShapeLayer()
                shape.strokeColor = NSColor(named: "haze")!.cgColor
                shape.lineWidth = width
                shape.fillColor = .clear
                let x = (.init(card.0) * (width + space)) + (width / 2) + 80
                let y: CGFloat
                if card.1 > 0 {
                    shape.lineCap = .round
                    y = .init(card.1) / top * height
                    
                    if !cards.enumerated().contains(where: { $0.0 < card.0 && $0.1 == card.1 }) {
                        let line = CAShapeLayer()
                        line.strokeColor = NSColor(named: "haze")!.withAlphaComponent(0.3).cgColor
                        line.lineWidth = 2
                        line.lineCap = .round
                        line.fillColor = .clear
                        line.path = {
                            $0.move(to: .init(x: 60, y: y + 60))
                            $0.addLine(to: .init(x: totalWidth - 20, y: y + 60))
                            return $0
                        } (CGMutablePath())
                        layer!.addSublayer(line)
                        
                        let counter = Label("\(card.1)", 14, .bold, NSColor(named: "haze")!)
                        addSubview(counter)
                        
                        counter.centerYAnchor.constraint(equalTo: bottomAnchor, constant: -(y + 60)).isActive = true
                        counter.rightAnchor.constraint(equalTo: leftAnchor, constant: 50).isActive = true
                    }
                } else {
                    y = 2
                }
                shape.path = {
                    $0.move(to: .init(x: x, y: -width))
                    $0.addLine(to: .init(x: x, y: y))
                    return $0
                } (CGMutablePath())
                mask.addSublayer(shape)
                
                let name = Label(app.session.name(app.project!, list: card.0), 12, .bold, NSColor(named: "haze")!)
                addSubview(name)
                
                name.centerXAnchor.constraint(equalTo: leftAnchor, constant: x).isActive = true
                name.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30).isActive = true
                
                widthAnchor.constraint(equalToConstant: totalWidth).isActive = true
                heightAnchor.constraint(equalToConstant: totalHeight).isActive = true
            }
        }
    }
    
    final class Ring: Chart {
        private let width = CGFloat(350)
        private let height = CGFloat(200)
        
        required init?(coder: NSCoder) { nil }
        init(_ title: String) {
            super.init()
            
            let cards = (0 ..< app.session.lists(app.project!)).reduce(into: [Int]()) {
                $0.append(app.session.cards(app.project!, list: $1))
            }
            let total = CGFloat(cards.reduce(0, +))
            let amount = .init(cards.last!) / (total > 0 ? total : 1)
        
            let center = CGPoint(x: 120, y: height / 2)
            let off = CAShapeLayer()
            off.fillColor = .clear
            off.lineWidth = 8
            off.strokeColor = NSColor(named: "haze")!.withAlphaComponent(0.2).cgColor
            off.path = {
                $0.addArc(center: center, radius: 60, startAngle: 0, endAngle: .pi * 2, clockwise: false)
                return $0
            } (CGMutablePath())
            layer!.addSublayer(off)
            
            let on = CAShapeLayer()
            on.fillColor = .clear
            on.lineWidth = 16
            on.lineCap = .round
            on.strokeColor = NSColor(named: "haze")!.cgColor
            on.path = {
                $0.addArc(center: center, radius: 60, startAngle: 0, endAngle: (.pi * -2) * amount, clockwise: true)
                return $0
            } (CGMutablePath())
            layer!.addSublayer(on)
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .percent
            
            let percent = Label(formatter.string(from: NSNumber(value: Double(amount)))!, 20, .bold, NSColor(named: "haze")!)
            addSubview(percent)
            
            let done = Label([
                (title + "\n", 14, .regular, NSColor(named: "haze")!),
                ("\(cards.last!)", 14, .bold, NSColor(named: "haze")!)
                ], align: .center)
            addSubview(done)
            
            let _total = Label([
                (.key("Chart.total") + "\n", 14, .regular, NSColor(named: "haze")!),
                ("\(Int(total))", 14, .bold, NSColor(named: "haze")!)
                ], align: .center)
            addSubview(_total)
            
            percent.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            percent.centerXAnchor.constraint(equalTo: leftAnchor, constant: center.x).isActive = true
            
            done.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            done.leftAnchor.constraint(equalTo: leftAnchor, constant: 220).isActive = true
            
            _total.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            _total.leftAnchor.constraint(equalTo: done.rightAnchor, constant: 20).isActive = true
            
            widthAnchor.constraint(equalToConstant: width).isActive = true
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    private init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
    }
}
