import AppKit

final class Bars: Chart {
    private var totalWidth = CGFloat()
    private var totalHeight = CGFloat()
    private let height = CGFloat(200)
    private let width = CGFloat(15)
    private let space = CGFloat(55)
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        totalWidth = (.init(app.session.lists(app.project!)) * (width + space)) + 70
        totalHeight = height + 60 + width
        
        let cards = (0 ..< app.session.lists(app.project!)).reduce(into: [Int]()) {
            $0.append(app.session.cards(app.project!, list: $1))
        }
        let top = CGFloat(cards.max() ?? 1)
        
        let mask = CALayer()
        mask.masksToBounds = true
        mask.frame = .init(x: 0, y: 60, width: totalWidth, height: totalHeight - 60)
        layer!.addSublayer(mask)
        
        cards.enumerated().forEach { card in
            let shape = CAShapeLayer()
            shape.strokeColor = NSColor(named: "haze")!.cgColor
            shape.lineWidth = width
            shape.fillColor = .clear
            let x = (.init(card.0) * (width + space)) + (width / 2) + 80
            let y: CGFloat
            if card.1 > 0 {
                shape.lineCap = .round
                y = .init(card.1) / top * height
                
                if !cards.enumerated().contains(where: { $0.0 < card.0 && $0.1 == card.1 }) {
                    let line = CAShapeLayer()
                    line.strokeColor = NSColor(named: "haze")!.withAlphaComponent(0.3).cgColor
                    line.lineWidth = 2
                    line.lineCap = .round
                    line.fillColor = .clear
                    line.path = {
                        $0.move(to: .init(x: 60, y: y + 60))
                        $0.addLine(to: .init(x: totalWidth - 20, y: y + 60))
                        return $0
                    } (CGMutablePath())
                    layer!.addSublayer(line)
                    
                    let counter = Label("\(card.1)", 14, .bold, NSColor(named: "haze")!)
                    addSubview(counter)
                    
                    counter.centerYAnchor.constraint(equalTo: bottomAnchor, constant: -(y + 60)).isActive = true
                    counter.rightAnchor.constraint(equalTo: leftAnchor, constant: 50).isActive = true
                }
            } else {
                y = 2
            }
            shape.path = {
                $0.move(to: .init(x: x, y: -width))
                $0.addLine(to: .init(x: x, y: y))
                return $0
            } (CGMutablePath())
            mask.addSublayer(shape)
            
            let name = Label(app.session.name(app.project!, list: card.0), 12, .bold, NSColor(named: "haze")!)
            addSubview(name)
            
            name.centerXAnchor.constraint(equalTo: leftAnchor, constant: x).isActive = true
            name.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30).isActive = true
            
            widthAnchor.constraint(equalToConstant: totalWidth).isActive = true
            heightAnchor.constraint(equalToConstant: totalHeight).isActive = true
        }
    }
}
