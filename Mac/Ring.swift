import AppKit

final class Ring: Chart {
    var current = CGFloat()
    var total = CGFloat()
    private weak var on: CAShapeLayer!
    private weak var percent: Label!
    private var last = CGFloat()
    private let formatter = NumberFormatter()
    private let middle = CGPoint(x: 50, y: 50)
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        formatter.numberStyle = .percent
        
        let off = CAShapeLayer()
        off.fillColor = .clear
        off.lineWidth = 4
        off.strokeColor = NSColor(named: "haze")!.withAlphaComponent(0.2).cgColor
        off.path = {
            $0.addArc(center: middle, radius: 40, startAngle: 0, endAngle: .pi * 2, clockwise: false)
            return $0
        } (CGMutablePath())
        layer!.addSublayer(off)
        
        let on = CAShapeLayer()
        on.fillColor = .clear
        on.lineWidth = 8
        on.lineCap = .round
        on.strokeColor = NSColor(named: "haze")!.cgColor
        on.path = {
            $0.addArc(center: middle, radius: 40, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            return $0
        } (CGMutablePath())
        on.strokeEnd = 0
        layer!.addSublayer(on)
        self.on = on
        
        let percent = Label([])
        percent.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        addSubview(percent)
        self.percent = percent
        
        heightAnchor.constraint(equalToConstant: 100).isActive = true
        widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        percent.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        percent.centerXAnchor.constraint(equalTo: leftAnchor, constant: middle.x).isActive = true
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
        
        self.percent.attributed([(self.formatter.string(from: NSNumber(value: Double(amount)))!, 14, .bold, NSColor(named: "haze")!),
        ("\n\(Int(self.current))/\(Int(self.total))", 11, .regular, NSColor(named: "haze")!)], align: .center)
    }
}
