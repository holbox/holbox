import UIKit

final class Spider: Chart {
    private let width = CGFloat(200)
    private let height = CGFloat(160)
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        let cards = (0 ..< app.session.lists(app.project!)).reduce(into: [Int]()) {
            $0.append(app.session.cards(app.project!, list: $1))
        }
        let total = CGFloat(cards.max() ?? 1)
        let circ = (.pi * 2) / CGFloat(cards.count)
        let center = CGPoint(x: width / 2, y: height / 2)
        let radius = width / 6
        
        let inner = CAShapeLayer()
        inner.fillColor = UIColor.clear.cgColor
        inner.lineWidth = 2
        inner.lineCap = .round
        inner.strokeColor = UIColor.black.cgColor
        
        let cross = CAShapeLayer()
        cross.fillColor = UIColor.clear.cgColor
        cross.lineWidth = 2
        cross.lineCap = .round
        cross.strokeColor = UIColor(named: "haze")!.cgColor
        
        let shape = CAShapeLayer()
        shape.fillColor = UIColor(named: "haze")!.cgColor
        shape.lineWidth = 0
        
        let _shape = CGMutablePath(), _cross = CGMutablePath(), _inner = CGMutablePath()
        
        cards.enumerated().forEach { card in
            let size = total > 0 ? max(.init(card.1) / total * (radius - 1), 10) : 20
            let dummy = CGMutablePath()
            dummy.addArc(center: center, radius: size, startAngle: circ * .init(card.0), endAngle: circ * .init(card.0), clockwise: false)
            if card.0 == 0 {
                _shape.move(to: dummy.currentPoint)
            } else {
                _shape.addLine(to: dummy.currentPoint)
            }
            dummy.addArc(center: center, radius: radius, startAngle: circ * .init(card.0), endAngle: circ * .init(card.0), clockwise: false)
            
            _cross.move(to: center)
            _cross.addLine(to: dummy.currentPoint)
            
            dummy.addArc(center: center, radius: (size * 0.9), startAngle: circ * .init(card.0), endAngle: circ * .init(card.0), clockwise: false)
            
            _inner.move(to: center)
            _inner.addLine(to: dummy.currentPoint)
            
            dummy.addArc(center: center, radius: radius, startAngle: circ * .init(card.0), endAngle: circ * .init(card.0), clockwise: false)
            
            let label = Label(app.session.name(app.project!, list: card.0), 12, .bold, UIColor(named: "haze")!)
            addSubview(label)
            
            if dummy.currentPoint.y == center.y {
                label.centerYAnchor.constraint(equalTo: bottomAnchor, constant: -(dummy.currentPoint.y + 2)).isActive = true
                label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor).isActive = true
                label.leftAnchor.constraint(equalTo: leftAnchor, constant: dummy.currentPoint.x + 5).isActive = true
            } else if dummy.currentPoint.y > center.y {
                label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -(dummy.currentPoint.y + 10)).isActive = true
                label.rightAnchor.constraint(equalTo: leftAnchor, constant: dummy.currentPoint.x).isActive = true
                label.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor).isActive = true
            } else {
                label.topAnchor.constraint(equalTo: bottomAnchor, constant: -(dummy.currentPoint.y - 10)).isActive = true
                label.leftAnchor.constraint(equalTo: leftAnchor, constant: dummy.currentPoint.x).isActive = true
            }
        }
        
        shape.path = _shape
        cross.path = _cross
        inner.path = _inner
        layer.addSublayer(shape)
        layer.addSublayer(cross)
        layer.addSublayer(inner)
        
        widthAnchor.constraint(equalToConstant: width).isActive = true
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
}
