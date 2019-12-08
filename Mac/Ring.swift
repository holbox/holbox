import AppKit

final class Ring: Chart {
    var current = CGFloat()
    var total = CGFloat()
    private weak var on: CAShapeLayer!
    private weak var percent: Label!
    private weak var label: Label!
    private var last = CGFloat()
    private let width = CGFloat(190)
    private let height = CGFloat(140)
    private let formatter = NumberFormatter()
    private let center = CGPoint(x: 60, y: 70)
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        formatter.numberStyle = .percent
        
        let off = CAShapeLayer()
        off.fillColor = .clear
        off.lineWidth = 4
        off.strokeColor = NSColor(named: "haze")!.withAlphaComponent(0.2).cgColor
        off.path = {
            $0.addArc(center: center, radius: 40, startAngle: 0, endAngle: .pi * 2, clockwise: false)
            return $0
        } (CGMutablePath())
        layer!.addSublayer(off)
        
        let on = CAShapeLayer()
        on.fillColor = .clear
        on.lineWidth = 8
        on.lineCap = .round
        on.strokeColor = NSColor(named: "haze")!.cgColor
        on.path = {
            $0.addArc(center: center, radius: 40, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            return $0
        } (CGMutablePath())
        on.strokeEnd = 0
        layer!.addSublayer(on)
        self.on = on
        
        let percent = Label("", 18, .bold, NSColor(named: "haze")!)
        addSubview(percent)
        self.percent = percent
        
        let label = Label([])
        addSubview(label)
        self.label = label
        
        widthAnchor.constraint(equalToConstant: width).isActive = true
        heightAnchor.constraint(equalToConstant: height).isActive = true
        
        percent.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        percent.centerXAnchor.constraint(equalTo: leftAnchor, constant: center.x).isActive = true
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 120).isActive = true
    }
    
    func refresh() {
        let amount = CGFloat(current) / .init(total > 0 ? total : 1)
        guard amount != on.strokeEnd || last != total else { return }

        last = total
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 2
        animation.fromValue = on.strokeEnd
        animation.toValue = amount
        animation.timingFunction = .init(name: .easeOut)
        on.strokeEnd = amount
        on.add(animation, forKey: "strokeEnd")
        
        NSAnimationContext.runAnimationGroup ({
            $0.duration = 0.25
            $0.allowsImplicitAnimation = true
            label.alphaValue = 0
            percent.alphaValue = 0
        }) { [weak self] in
            guard let self = self else { return }
            self.label.attributed([("\(Int(self.current))\n", 22, .bold, NSColor(named: "haze")!),
                                    ("\(Int(self.total))", 14, .regular, NSColor(named: "haze")!)])
            self.percent.stringValue = self.formatter.string(from: NSNumber(value: Double(amount)))!

            NSAnimationContext.runAnimationGroup {
                $0.duration = 0.3
                $0.allowsImplicitAnimation = true
                self.label.alphaValue = 1
                self.percent.alphaValue = 1
            }
        }
    }
}
