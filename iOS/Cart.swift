import UIKit

final class Cart: Chart {
    private let index: Int
    private let width = CGFloat(1)
    private let space = CGFloat(1)
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int) {
        self.index = index
        super.init()
    }
    
    override func draw(_: CGRect) {
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        let radius = min(10, bounds.height / 3)
        
        let outer = CALayer()
        outer.borderWidth = 1
        outer.borderColor = UIColor(named: "haze")!.cgColor
        outer.cornerRadius = radius
        outer.frame = .init(x: 10, y: bounds.midY - radius, width: bounds.width - 20, height: radius * 2)
        outer.masksToBounds = true
        layer.addSublayer(outer)
        
        let products = app.session.cards(index, list: 0)
        if products > 0 {
            let needed = app.session.cards(index, list: 1)
            let items = Int(((bounds.width - 22) + space) / (width + space)) + 1
            let counter = items - .init((CGFloat(needed) / .init(products)) * .init(items))
            (0 ..< items).forEach {
                let x = ((width + space) * .init($0)) + 2
                let shape = CAShapeLayer()
                shape.strokeColor = $0 < counter ? UIColor(named: "haze")!.cgColor
                    : UIColor(named: "haze")!.withAlphaComponent(0.2).cgColor
                shape.lineWidth = width
                shape.fillColor = UIColor.clear.cgColor
                shape.path = {
                    $0.move(to: .init(x: x, y: 0))
                    $0.addLine(to: .init(x: x, y: radius * 2))
                    return $0
                } (CGMutablePath())
                outer.addSublayer(shape)
            }
        }
    }
}
