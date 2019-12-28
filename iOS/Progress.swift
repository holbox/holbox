import UIKit

final class Progress: UIView {
    private let index: Int
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int) {
        self.index = index
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
    }
    
    override func draw(_: CGRect) {
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        let waiting = CGFloat(app.session.cards(index, list: 0))
        let done = CGFloat(app.session.cards(index, list: 1))
        let total = waiting + done
        let first = (.pi * 2) * (done / total)
        
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius = min(bounds.width, bounds.height) / 2.5
        
        let border = CAShapeLayer()
        border.fillColor = UIColor.clear.cgColor
        border.lineWidth = 2
        border.strokeColor = .haze()
        border.path = {
            $0.addArc(center: center, radius: radius - 1, startAngle: 0, endAngle: .pi * 2, clockwise: false)
            return $0
        } (CGMutablePath())
        layer.addSublayer(border)
        
        let off = CAShapeLayer()
        off.fillColor = .haze(0.2)
        off.lineWidth = 0
        off.path = {
            $0.move(to: center)
            $0.addArc(center: center, radius: radius - 6, startAngle: 0, endAngle: .pi * 2, clockwise: false)
            $0.move(to: center)
            return $0
        } (CGMutablePath())
        layer.addSublayer(off)
        
        let on = CAShapeLayer()
        on.fillColor = .haze()
        on.lineWidth = 0
        on.path = {
            $0.move(to: center)
            $0.addArc(center: center, radius: radius - 6, startAngle: 0, endAngle: first, clockwise: false)
            $0.move(to: center)
            return $0
        } (CGMutablePath())
        layer.addSublayer(on)
    }
}
