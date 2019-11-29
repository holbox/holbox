import UIKit

final class Ring: Chart {
    private let width = CGFloat(190)
    private let height = CGFloat(140)
    
    required init?(coder: NSCoder) { nil }
    init(_ current: Int, total: Int) {
        super.init()
        let amount = CGFloat(current) / .init(total > 0 ? total : 1)
        let center = CGPoint(x: 60, y: height / 2)
        let off = CAShapeLayer()
        off.fillColor = UIColor.clear.cgColor
        off.lineWidth = 4
        off.strokeColor = UIColor(named: "haze")!.withAlphaComponent(0.2).cgColor
        off.path = {
            $0.addArc(center: center, radius: 40, startAngle: 0, endAngle: .pi * 2, clockwise: false)
            return $0
        } (CGMutablePath())
        layer.addSublayer(off)
        
        let on = CAShapeLayer()
        on.fillColor = UIColor.clear.cgColor
        on.lineWidth = 8
        on.lineCap = .round
        on.strokeColor = UIColor(named: "haze")!.cgColor
        on.path = {
            $0.addArc(center: center, radius: 40, startAngle: 0, endAngle: (.pi * -2) * amount, clockwise: true)
            return $0
        } (CGMutablePath())
        layer.addSublayer(on)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        
        let percent = Label(formatter.string(from: NSNumber(value: Double(amount)))!, 18, .bold, UIColor(named: "haze")!)
        addSubview(percent)
        
        let label = Label([("\(current)\n", 18, .bold, UIColor(named: "haze")!),
                           ("\(total)", 14, .regular, UIColor(named: "haze")!)])
        addSubview(label)
        
        percent.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        percent.centerXAnchor.constraint(equalTo: leftAnchor, constant: center.x).isActive = true
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 120).isActive = true
        
        widthAnchor.constraint(equalToConstant: width).isActive = true
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
}
