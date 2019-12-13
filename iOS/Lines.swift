import UIKit

final class Lines: Chart {
    private let index: Int
    private let width = CGFloat(10)
    private let space = CGFloat(15)
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int) {
        self.index = index
        super.init()
    }
    
    override func draw(_: CGRect) {
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        let cards = (0 ..< app.session.lists(index)).map { app.session.cards(index, list: $0) }
        let total = CGFloat(cards.max() ?? 1)
        let height = bounds.height - width
        var x = (bounds.width - ((.init(cards.count) * (width + space)) - space)) / 2
        cards.forEach { card in
            let shape = CAShapeLayer()
            shape.strokeColor = UIColor(named: "haze")!.cgColor
            shape.lineWidth = width
            shape.fillColor = UIColor.clear.cgColor
            let y: CGFloat
            if total > 0 && card > 0 {
                shape.lineCap = .round
                y = .init(card) / total * height
            } else {
                y = 2
            }
            shape.path = {
                $0.move(to: .init(x: x + (width / 2), y: bounds.height - (width / 2)))
                $0.addLine(to: .init(x: x + (width / 2), y: bounds.height - y - (width / 2)))
                return $0
            } (CGMutablePath())
            layer.addSublayer(shape)
            x += width + space
        }
    }
}
