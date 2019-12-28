import AppKit

final class Ring: NSView {
    private weak var on: CAShapeLayer!
    private weak var percent: Label!
    private let middle = CGPoint(x: 33, y: 33)
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let off = CAShapeLayer()
        off.fillColor = .haze()
        off.path = {
            $0.addArc(center: middle, radius: 26, startAngle: 0, endAngle: .pi * 2, clockwise: false)
            return $0
        } (CGMutablePath())
        layer = off
        wantsLayer = true
        
        let on = CAShapeLayer()
        on.fillColor = .clear
        on.lineWidth = 3
        on.lineCap = .round
        on.strokeColor = .haze()
        on.path = {
            $0.addArc(center: middle, radius: 30, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            return $0
        } (CGMutablePath())
        on.strokeEnd = 0
        layer!.addSublayer(on)
        self.on = on
        
        let percent = Label([])
        percent.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        addSubview(percent)
        self.percent = percent
        
        heightAnchor.constraint(equalToConstant: 66).isActive = true
        widthAnchor.constraint(equalToConstant: 66).isActive = true
        
        percent.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        percent.centerXAnchor.constraint(equalTo: leftAnchor, constant: middle.x).isActive = true
    }
    
    func refresh() {
        let current = CGFloat(app.session.cards(app.project, list: 1))
        let total = CGFloat(app.session.cards(app.project, list: 0) + app.session.cards(app.project, list: 1))
        let amount: CGFloat
        if total > 0 {
            amount = CGFloat(current) / .init(total > 0 ? total : 1)
            percent.attributed([("\(Int(amount * 100))", .medium(16), .black), ("%", .regular(10), .black)])
        } else {
            amount = 0
            percent.attributed([])
        }
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 2
        animation.fromValue = on.strokeEnd
        animation.toValue = amount
        animation.timingFunction = .init(name: .easeOut)
        on.strokeEnd = amount
        on.add(animation, forKey: "strokeEnd")
    }
}
