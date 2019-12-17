import AppKit

final class Timeline: Chart {
    private weak var dots: CAShapeLayer!
    private weak var time: CAShapeLayer!
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        
        let dots = CAShapeLayer()
        dots.fillColor = .clear
        dots.lineWidth = 2
        dots.strokeColor = NSColor(named: "haze")!.withAlphaComponent(0.3).cgColor
        dots.lineDashPattern = [NSNumber(value: 4), NSNumber(value: 4)]
        layer!.addSublayer(dots)
        self.dots = dots
        
        let time = CAShapeLayer()
        time.fillColor = .clear
        time.lineWidth = 2
        time.lineCap = .round
        time.lineJoin = .round
        time.strokeColor = NSColor(named: "haze")!.cgColor
        layer!.addSublayer(time)
        self.time = time
        
        widthAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
        heightAnchor.constraint(equalToConstant: 200).isActive = true
        layoutSubtreeIfNeeded()
    }
    
    func refresh() {
        let time = CGMutablePath()
        time.move(to: .init(x: 2, y: 15))
        
        let dates = (0 ..< app.session.cards(app.project, list: 2)).map { CGFloat(Int(app.session.content(app.project, list: 2, card: $0))!) }
        if !dates.isEmpty {
            let slots = (bounds.width - 60) / 3
            let interval = (.init(Date().timeIntervalSince1970) - dates.last!) / slots
            let tasks = (0 ... Int(slots)).reduce(into: [CGFloat]()) { tasks, slot in
                let mark = dates.last! + (.init(slot) * interval)
                tasks.append(.init(dates.filter { $0 >= mark && $0 < mark + interval }.count))
            }
            let max = tasks.max()!
            tasks.enumerated().forEach {
                time.addLine(to: .init(x: (((bounds.width - 60) / slots) * .init($0.0)) + 30, y: ((bounds.height - 25) * ($0.1 / max)) + 15))
            }
        }
        
        time.addLine(to: .init(x: bounds.maxX - 2, y: 15))
        
        let dots = CGMutablePath()
        dots.move(to: .init(x: 0, y: 3))
        dots.addLine(to: .init(x: bounds.maxX, y: 3))
        
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
