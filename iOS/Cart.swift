import UIKit

final class Cart: Chart {
    private let index: Int
    private let width = CGFloat(4)
    private let space = CGFloat(6)
    private let radius = CGFloat(4)
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int) {
        self.index = index
        super.init()
    }
    
    override func draw(_: CGRect) {
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        let products = app.session.cards(index, list: 0)
        if products > 0 {
            let needed = app.session.cards(index, list: 1)
            let items = Int((bounds.width + space) / (width + space))
            let counter = items - .init((CGFloat(needed) / .init(products)) * .init(items))
            (0 ..< items).forEach {
                let x = (width / 2) + ((width + space) * .init($0))
                let shape = CAShapeLayer()
                shape.strokeColor = $0 < counter ? UIColor(named: "haze")!.cgColor
                    : UIColor(named: "haze")!.withAlphaComponent(0.1).cgColor
                shape.lineWidth = width
                shape.lineCap = .round
                shape.fillColor = UIColor.clear.cgColor
                shape.path = {
                    $0.move(to: .init(x: x, y: bounds.midY - radius))
                    $0.addLine(to: .init(x: x, y: bounds.midY + radius))
                    return $0
                } (CGMutablePath())
                layer.addSublayer(shape)
            }
        }
    }
}
