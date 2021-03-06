import UIKit

final class Timeline: UIView {
    private weak var dots: CAShapeLayer!
    private weak var time: CAShapeLayer!
    private weak var start: Label!
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        
        let now = Label(.key("Timeline.now"), .regular(12), .haze())
        addSubview(now)
        
        let start = Label("", .regular(12), .haze())
        addSubview(start)
        self.start = start
        
        let dots = CAShapeLayer()
        dots.fillColor = .clear
        dots.lineWidth = 2
        dots.strokeColor = .haze(0.3)
        dots.lineDashPattern = [NSNumber(value: 4), NSNumber(value: 4)]
        layer.addSublayer(dots)
        self.dots = dots
        
        let time = CAShapeLayer()
        time.fillColor = .clear
        time.lineWidth = 2
        time.lineCap = .round
        time.lineJoin = .round
        time.strokeColor = .haze()
        layer.addSublayer(time)
        self.time = time
        
        heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        start.topAnchor.constraint(equalTo: bottomAnchor, constant: -35).isActive = true
        start.leftAnchor.constraint(equalTo: leftAnchor, constant: 3).isActive = true
        start.rightAnchor.constraint(lessThanOrEqualTo: now.leftAnchor, constant: -10).isActive = true
        
        now.topAnchor.constraint(equalTo: bottomAnchor, constant: -35).isActive = true
        now.rightAnchor.constraint(equalTo: rightAnchor, constant: -3).isActive = true
    }
    
    func refresh() {
        let time = CGMutablePath()
        time.move(to: .init(x: 2, y: 70))
        
        let dates = (0 ..< app.session.cards(app.project, list: 2)).map { CGFloat(Int(app.session.content(app.project, list: 2, card: $0))!) }
        if dates.isEmpty {
            start.text = ""
        } else {
            let slots = (bounds.width - 60) / 10
            let interval = (.init(Date().timeIntervalSince1970) - dates.last!) / slots
            let tasks = (0 ... Int(slots)).reduce(into: [CGFloat]()) { tasks, slot in
                let mark = dates.last! + (.init(slot) * interval)
                tasks.append(.init(dates.filter { $0 >= mark && $0 < mark + interval }.count))
            }
            let max = tasks.max()!
            tasks.enumerated().forEach {
                time.addLine(to: .init(x: (((bounds.width - 60) / slots) * .init($0.0)) + 30, y: 70 - (40 * ($0.1 / max))))
            }
            
            start.text = Date(timeIntervalSince1970: .init(dates.last!)).interval
        }
        
        time.addLine(to: .init(x: bounds.maxX - 2, y: 70))
        
        let dots = CGMutablePath()
        dots.move(to: .init(x: 0, y: 78))
        dots.addLine(to: .init(x: bounds.maxX, y: 78))
        
        let timing = CABasicAnimation(keyPath: "path")
        timing.duration = 0.6
        timing.fromValue = self.time.path
        timing.toValue = time
        timing.timingFunction = .init(name: .easeOut)
        self.time.path = time
        self.time.add(timing, forKey: "path")
        
        let dotting = CABasicAnimation(keyPath: "path")
        dotting.duration = 0.6
        dotting.fromValue = self.dots.path
        dotting.toValue = dots
        dotting.timingFunction = .init(name: .easeOut)
        self.dots.path = dots
        self.dots.add(dotting, forKey: "path")
    }
}
