import AppKit

final class Ring: Chart {
    private let width = CGFloat(350)
    private let height = CGFloat(200)
    
    required init?(coder: NSCoder) { nil }
    init(_ current: (String, CGFloat), total: (String, CGFloat)) {
        super.init()
        let amount = current.1 / (total.1 > 0 ? total.1 : 1)
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
            (current.0 + "\n", 14, .regular, NSColor(named: "haze")!),
            ("\(Int(current.1))", 14, .bold, NSColor(named: "haze")!)
            ], align: .center)
        addSubview(done)
        
        let _total = Label([
            (total.0 + "\n", 14, .regular, NSColor(named: "haze")!),
            ("\(Int(total.1))", 14, .bold, NSColor(named: "haze")!)
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
