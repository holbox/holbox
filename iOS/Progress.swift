import UIKit

final class Progress: Chart {
    private let index: Int
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int) {
        self.index = index
        super.init()
    }
    
    override func draw(_: CGRect) {
        layer.sublayers!.forEach { $0.removeFromSuperlayer() }
        let waiting = CGFloat(app.session.cards(index, list: 0))
        let done = CGFloat(app.session.cards(index, list: 1))
        let total = waiting + done
        let start = CGFloat()
        let first = start + (.pi * 2) * (done / total)
        let second = first + (.pi * 2) * (waiting / total)
        
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius = min(bounds.width, bounds.height) / 2
        let on = CAShapeLayer()
        on.fillColor = UIColor(named: "haze")!.cgColor
        on.lineWidth = 0
        on.path = {
            $0.move(to: center)
            $0.addArc(center: center, radius: radius, startAngle: start, endAngle: first, clockwise: false)
            $0.move(to: center)
            return $0
        } (CGMutablePath())
        layer.addSublayer(on)
        
        let off = CAShapeLayer()
        off.fillColor = UIColor(named: "haze")!.withAlphaComponent(0.2).cgColor
        off.lineWidth = 0
        off.path = {
            $0.move(to: center)
            $0.addArc(center: center, radius: radius, startAngle: first, endAngle: second, clockwise: false)
            $0.move(to: center)
            return $0
        } (CGMutablePath())
        layer.addSublayer(off)
    }
}
