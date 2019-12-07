import AppKit

final class Lines: Chart {
    private let index: Int
    private let width = CGFloat(8)
    private let space = CGFloat(11)
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int) {
        self.index = index
        super.init()
    }
    
    override func draw(_: CGRect) {
        layer!.sublayers!.forEach { $0.removeFromSuperlayer() }
        let cards = (0 ..< app.session.lists(index)).map { app.session.cards(index, list: $0) }
        let total = CGFloat(cards.max() ?? 1)
        let height = bounds.height - (width / 2) - width - space
        cards.enumerated().forEach { card in
            let shape = CAShapeLayer()
            shape.strokeColor = NSColor(named: "haze")!.cgColor
            shape.lineWidth = width
            shape.fillColor = .clear
            let x = (.init(card.0) * (width + space)) + (width / 2)
            let y: CGFloat
            if total > 0 && card.1 > 0 {
                shape.lineCap = .round
                y = .init(card.1) / total * height
            } else {
                y = 2
            }
            shape.path = {
                $0.move(to: .init(x: x, y: -width))
                $0.addLine(to: .init(x: x, y: y))
                return $0
            } (CGMutablePath())
            layer!.addSublayer(shape)
        }
    }
}
