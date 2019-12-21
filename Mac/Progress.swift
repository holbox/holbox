import AppKit

final class Progress: NSView {
    private let index: Int
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int) {
        self.index = index
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
    }
    
    override func draw(_: CGRect) {
        layer!.sublayers?.forEach { $0.removeFromSuperlayer() }
        let waiting = CGFloat(app.session.cards(index, list: 0))
        let done = CGFloat(app.session.cards(index, list: 1))
        let total = waiting + done
        let first = (.pi * 2) * (done / total)
        let second = first + (.pi * 2) * (waiting / total)
        
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius = min(bounds.width, bounds.height) / 2.2
        
        let border = CAShapeLayer()
        border.fillColor = .clear
        border.strokeColor = .haze()
        border.lineWidth = 2
        border.path = {
            $0.addArc(center: center, radius: radius - 1, startAngle: 0, endAngle: .pi * 2, clockwise: false)
            return $0
        } (CGMutablePath())
        layer!.addSublayer(border)
        
        let on = CAShapeLayer()
        on.fillColor = .haze()
        on.lineWidth = 0
        on.path = {
            $0.move(to: center)
            $0.addArc(center: center, radius: radius - 6, startAngle: 0, endAngle: first, clockwise: false)
            $0.move(to: center)
            return $0
        } (CGMutablePath())
        layer!.addSublayer(on)
        
        let off = CAShapeLayer()
        off.fillColor = .haze(0.2)
        off.lineWidth = 0
        off.path = {
            $0.move(to: center)
            $0.addArc(center: center, radius: radius - 6, startAngle: first, endAngle: second, clockwise: false)
            $0.move(to: center)
            return $0
        } (CGMutablePath())
        layer!.addSublayer(off)
    }
}
