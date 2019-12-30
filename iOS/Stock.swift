import UIKit

final class Stock: UIView {
    private weak var off: CAShapeLayer!
    private weak var on: CAShapeLayer!
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        layer.cornerRadius = 6
        layer.borderWidth = 1
        layer.borderColor = .haze()
        layer.masksToBounds = true
        
        let off = CAShapeLayer()
        off.fillColor = .clear
        off.lineWidth = 10
        off.strokeColor = .haze(0.2)
        off.lineDashPattern = [NSNumber(value: 1), NSNumber(value: 1)]
        layer.addSublayer(off)
        self.off = off
        
        let on = CAShapeLayer()
        on.fillColor = .clear
        on.lineWidth = 10
        on.strokeColor = .haze()
        on.lineDashPattern = [NSNumber(value: 1), NSNumber(value: 1)]
        on.strokeEnd = 0
        layer.addSublayer(on)
        self.on = on
        
        heightAnchor.constraint(equalToConstant: 12).isActive = true
        resize()
    }
    
    func refresh() {
        let percent = .init((0 ..< app.session.cards(app.project, list: 2)).map { app.session.content(app.project, list: 2, card: $0) }.filter { $0 == "1" }.count)
            / CGFloat(app.session.cards(app.project, list: 0))
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 1.5
        animation.fromValue = on.strokeEnd
        animation.toValue = percent
        animation.timingFunction = .init(name: .easeOut)
        on.strokeEnd = percent
        on.add(animation, forKey: "strokeEnd")
    }
    
    func resize() {
        off.path = {
            $0.move(to: .init(x: 0, y: 6))
            $0.addLine(to: .init(x: app.main.frame.width, y: 6))
            return $0
        } (CGMutablePath())
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = 1
        animation.fromValue = on.path
        animation.toValue = off.path
        animation.timingFunction = .init(name: .easeOut)
        on.path = off.path
        on.add(animation, forKey: "path")
    }
}
