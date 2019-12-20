import UIKit

final class Ring: Chart {
    var current = CGFloat()
    var total = CGFloat()
    private weak var on: CAShapeLayer!
    private weak var percent: Label!
    private weak var label: Label!
    private var last = CGFloat()
    private let formatter = NumberFormatter()
    private let middle = CGPoint(x: 60, y: 70)
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        formatter.numberStyle = .percent
        
        let off = CAShapeLayer()
        off.fillColor = UIColor.clear.cgColor
        off.lineWidth = 4
        off.strokeColor = UIColor(named: "haze")!.withAlphaComponent(0.2).cgColor
        off.path = {
            $0.addArc(center: middle, radius: 40, startAngle: 0, endAngle: .pi * 2, clockwise: false)
            return $0
        } (CGMutablePath())
        layer.addSublayer(off)
        
        let on = CAShapeLayer()
        on.fillColor = UIColor.clear.cgColor
        on.lineWidth = 8
        on.lineCap = .round
        on.strokeColor = UIColor(named: "haze")!.cgColor
        on.path = {
            $0.addArc(center: middle, radius: 40, startAngle: 0, endAngle: .pi * 2, clockwise: false)
            return $0
        } (CGMutablePath())
        on.strokeEnd = 0
        layer.addSublayer(on)
        self.on = on
        
        let percent = Label("", 18, .bold, UIColor(named: "haze")!)
        addSubview(percent)
        self.percent = percent
        
        let label = Label([])
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        addSubview(label)
        self.label = label
        
        rightAnchor.constraint(equalTo: label.rightAnchor, constant: 5).isActive = true
        heightAnchor.constraint(equalToConstant: 140).isActive = true
        
        percent.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        percent.centerXAnchor.constraint(equalTo: leftAnchor, constant: middle.x).isActive = true
        
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
        
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.label.alpha = 0
            self?.percent.alpha = 0
        }) { [weak self] _ in
            guard let self = self else { return }
            self.label.attributed([("\(Int(self.current))\n", 22, .bold, UIColor(named: "haze")!),
                                    ("\(Int(self.total))", 14, .regular, UIColor(named: "haze")!)])
            self.percent.text = self.formatter.string(from: .init(value: Double(amount)))!
            
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.label.alpha = 1
                self?.percent.alpha = 1
            }
        }
    }
}
