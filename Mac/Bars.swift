import AppKit

final class Bars: Chart {
    private weak var right: NSLayoutConstraint! {
        didSet {
            oldValue?.isActive = false
            right.isActive = true
        }
    }
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        heightAnchor.constraint(equalToConstant: 190).isActive = true
        
        let width = widthAnchor.constraint(equalToConstant: 0)
        width.priority = .defaultLow
        width.isActive = true
    }
    
    func refresh() {
        let cards = (0 ..< app.session.lists(app.project)).map { CGFloat(app.session.cards(app.project, list: $0)) }
        let total = CGFloat(cards.reduce(0, +))
        let top = cards.max() ?? 1
        
        if subviews.count > cards.count {
            (cards.count ..< subviews.count).forEach {
                subviews[$0].removeFromSuperview()
            }
            if let last = subviews.last {
                right = rightAnchor.constraint(equalTo: last.rightAnchor, constant: 6)
            }
        } else {
            (subviews.count ..< cards.count).forEach {
                let line = Line()
                addSubview(line)
                
                line.topAnchor.constraint(equalTo: topAnchor).isActive = true
                line.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
                line.leftAnchor.constraint(equalTo: $0 == 0 ? leftAnchor : subviews[$0 - 1].rightAnchor, constant: 6).isActive = true
                
                if $0 == cards.count - 1 {
                    right = rightAnchor.constraint(equalTo: line.rightAnchor, constant: 6)
                }
            }
        }
        
        layoutSubtreeIfNeeded()

        (subviews as! [Line]).enumerated().forEach {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = 2
            animation.fromValue = $0.1.shape.strokeEnd
            animation.toValue = cards[$0.0] / max(top, 1)
            animation.timingFunction = .init(name: .easeOut)
            $0.1.shape.strokeEnd = cards[$0.0] / max(top, 1)
            $0.1.shape.add(animation, forKey: "strokeEnd")
            $0.1.label.attributed([("\(Int(cards[$0.0]))\n", 16, .medium, NSColor(named: "haze")!),
                                   ("\(total > 0 ? Int(cards[$0.0] / total * 100) : 0)", 12, .regular, NSColor(named: "haze")!),
                                   ("%\n", 8, .regular, NSColor(named: "haze")!),
                                   (app.session.name(app.project, list: $0.0), 10, .regular, NSColor(named: "haze")!)],
                                  align: .center)
        }
        
        NSAnimationContext.runAnimationGroup {
            $0.duration = 1.5
            $0.allowsImplicitAnimation = true
            layoutSubtreeIfNeeded()
        }
    }
}

private final class Line: NSView {
    private(set) weak var shape: CAShapeLayer!
    private(set) weak var label: Label!
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        wantsLayer = true
        translatesAutoresizingMaskIntoConstraints = false
        
        let shape = CAShapeLayer()
        shape.fillColor = .clear
        shape.strokeColor = NSColor(named: "haze")!.cgColor
        shape.lineWidth = 12
        shape.lineCap = .round
        shape.path = {
            $0.move(to: .init(x: 6, y: 6))
            $0.addLine(to: .init(x: 6, y: 100))
            return $0
        } (CGMutablePath())
        shape.strokeEnd = 0
        self.shape = shape
        
        let base = CAShapeLayer()
        base.fillColor = .clear
        base.strokeColor = NSColor(named: "haze")!.cgColor
        base.lineWidth = 12
        base.path = {
            $0.move(to: .init(x: 6, y: 6))
            $0.addLine(to: .init(x: 6, y: 10))
            return $0
        } (CGMutablePath())
        base.addSublayer(shape)
        
        let line = NSView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.layer = base
        line.wantsLayer = true
        addSubview(line)
        
        let label = Label([])
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.maximumNumberOfLines = 4
        addSubview(label)
        self.label = label
        
        line.widthAnchor.constraint(equalToConstant: 12).isActive = true
        line.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        line.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -78).isActive = true
        line.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        
        rightAnchor.constraint(equalTo: label.rightAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        label.topAnchor.constraint(equalTo: bottomAnchor, constant: -70).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 50).isActive = true
    }
}
