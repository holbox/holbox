import UIKit

final class Cart: UIView {
    private let index: Int
    private let width = CGFloat(1)
    private let space = CGFloat(1)
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int) {
        self.index = index
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
    }
    
    override func draw(_: CGRect) {
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        let radius = min(7, bounds.height / 4)
        
        let outer = CALayer()
        outer.borderWidth = 1
        outer.borderColor = .haze()
        outer.cornerRadius = radius
        outer.frame = .init(x: 10, y: bounds.midY - radius, width: bounds.width - 20, height: radius * 2)
        outer.masksToBounds = true
        layer.addSublayer(outer)
        
        let groceries = (0 ..< app.session.cards(index, list: 2)).map { app.session.content(index, list: 2, card: $0) }
        if !groceries.isEmpty {
            let items = Int(((bounds.width - 22) + space) / (width + space)) + 1
            let counter = items - .init((CGFloat(groceries.filter { $0 == "0" }.count) / .init(groceries.count)) * .init(items))
            (0 ..< items).forEach {
                let x = ((width + space) * .init($0)) + 2
                let shape = CAShapeLayer()
                shape.strokeColor = $0 < counter ? .haze() : .haze(0.2)
                shape.lineWidth = width
                shape.fillColor = .clear
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
