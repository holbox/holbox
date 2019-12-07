import AppKit

final class Ring: Chart {
    var current = CGFloat()
    var total = CGFloat()
    private let width = CGFloat(190)
    private let height = CGFloat(140)
    private let formatter = NumberFormatter()
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        formatter.numberStyle = .percent
        widthAnchor.constraint(equalToConstant: width).isActive = true
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func refresh() {
        layer!.sublayers?.forEach { $0.removeFromSuperlayer() }
        subviews.forEach { $0.removeFromSuperview() }
        
        let amount = CGFloat(current) / .init(total > 0 ? total : 1)
        let center = CGPoint(x: 60, y: height / 2)
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
            $0.addArc(center: center, radius: 40, startAngle: 0, endAngle: (.pi * -2) * amount, clockwise: true)
            return $0
        } (CGMutablePath())
        layer!.addSublayer(on)
        
        let percent = Label(formatter.string(from: NSNumber(value: Double(amount)))!, 18, .bold, NSColor(named: "haze")!)
        addSubview(percent)
        
        let label = Label([("\(Int(current))\n", 20, .bold, NSColor(named: "haze")!),
                           ("\(Int(total))", 14, .regular, NSColor(named: "haze")!)])
        addSubview(label)
        
        percent.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        percent.centerXAnchor.constraint(equalTo: leftAnchor, constant: center.x).isActive = true
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 120).isActive = true
    }
}
