import AppKit

final class Cart: Chart {
    private let index: Int
    private let width = CGFloat(12)
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int) {
        self.index = index
        super.init()
    }
    
    override func draw(_: NSRect) {
        layer!.sublayers?.forEach { $0.removeFromSuperlayer() }
        let products = CGFloat(app.session.cards(index, list: 0))
        let needed = CGFloat(app.session.cards(index, list: 1))
        let size = bounds.width - width
        let start = width / 2
        let first = start + (((products - needed) / products) * size)
        let second = first + ((needed / products) * size)
        let yFirst = bounds.midY + (width / 5)
        let ySecond = bounds.midY - (width / 5)
        
        if needed > 0 {
            let off = CAShapeLayer()
            off.strokeColor = NSColor(named: "haze")!.withAlphaComponent(0.2).cgColor
            off.lineWidth = width
            off.fillColor = .clear
            off.lineCap = .round
            off.path = {
                $0.move(to: .init(x: first, y: ySecond))
                $0.addLine(to: .init(x: second, y: ySecond))
                return $0
            } (CGMutablePath())
            layer!.addSublayer(off)
        }
        
        if needed != products {
            let on = CAShapeLayer()
            on.strokeColor = NSColor(named: "haze")!.cgColor
            on.lineWidth = width
            on.fillColor = .clear
            on.lineCap = .round
            on.path = {
                $0.move(to: .init(x: start, y: yFirst))
                $0.addLine(to: .init(x: first, y: yFirst))
                return $0
            } (CGMutablePath())
            layer!.addSublayer(on)
        }
    }
}
