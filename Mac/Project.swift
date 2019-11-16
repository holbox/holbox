import AppKit

final class Project: NSView {
    private final class Chart: NSView {
        required init?(coder: NSCoder) { nil }
        init(_ index: Int) {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            wantsLayer = true
            
            let cards = (0 ..< app.session.lists(index)).reduce(into: [Int]()) {
                $0.append(app.session.cards(index, list: $1))
            }
            let total = CGFloat(cards.reduce(0, +))
            cards.enumerated().forEach { card in
                let shape = CAShapeLayer()
                shape.fillColor = .clear
                shape.strokeColor = NSColor(named: "haze")!.cgColor
                shape.lineWidth = 10
                let x = CGFloat(card.0 * 20) + 10
                let y: CGFloat
                if total > 0 && card.1 > 0 {
                    shape.lineCap = .round
                    y = .init(card.1) / total * 30
                } else {
                    y = 2
                }
                shape.path = {
                    $0.move(to: .init(x: x, y: -10))
                    $0.addLine(to: .init(x: x, y: y))
                    return $0
                } (CGMutablePath())
                layer!.addSublayer(shape)
            }
            heightAnchor.constraint(equalToConstant: 45).isActive = true
            widthAnchor.constraint(equalToConstant: 20 * .init(cards.count)).isActive = true
        }
    }

    weak var top: NSLayoutConstraint! { didSet { top.isActive = true } }
    weak var left: NSLayoutConstraint! { didSet { left.isActive = true } }
    let order: Int
    private let index: Int
    override var mouseDownCanMoveWindow: Bool { false }
    
    private var detail: String {
        switch app.session.mode(index) {
        case .kanban:
            return "\(app.session.lists(index)) " + .key("Project.columns") + "\n" +
                "\((0 ..< app.session.lists(index)).reduce(into: 0) { $0 += app.session.cards(index, list: $1) }) " + .key("Project.cards") + "\n"
        case .todo:
            return "\((0 ..< app.session.lists(index)).reduce(into: 0) { $0 += app.session.cards(index, list: $1) }) " + .key("Project.tasks") + "\n"
        case .shopping:
            return "\((0 ..< app.session.lists(index)).reduce(into: 0) { $0 += app.session.cards(index, list: $1) }) " + .key("Project.products") + "\n"
        default: return ""
        }
    }
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int, order: Int) {
        self.index = index
        self.order = order
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setAccessibilityElement(true)
        setAccessibilityRole(.button)
        setAccessibilityLabel(app.session.name(index))
        wantsLayer = true
        layer!.cornerRadius = 6
        layer!.backgroundColor = NSColor(named: "background")!.cgColor
        
        let icon = Image({
            switch app.session.mode(index) {
            case .kanban: return "kanban"
            case .todo: return "todo"
            case .shopping: return "shopping"
            case .notes: return "notes"
            default: return ""
            }
        } ())
        addSubview(icon)
        
        let modified: String
        
        if #available(OSX 10.15, *) {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            modified = formatter.localizedString(for: app.session.time(index), relativeTo: .init())
        } else {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.dateStyle = Calendar.current.dateComponents([.day], from: app.session.time(index), to: .init()).day! == 0 ? .none : .short
            modified = formatter.string(from: app.session.time(index))
        }
        
        let label = Label(app.session.name(index), 16, .medium, NSColor(named: "haze")!)
        label.setAccessibilityElement(false)
        addSubview(label)
        
        let info = Label(detail + modified, 13, .light, NSColor(named: "haze")!)
        info.setAccessibilityElement(false)
        addSubview(info)
        
        let chart = Chart(index)
        addSubview(chart)
        
        widthAnchor.constraint(equalToConstant: 160).isActive = true
        heightAnchor.constraint(equalToConstant: 170).isActive = true
        
        icon.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10).isActive = true
        icon.leftAnchor.constraint(equalTo: label.leftAnchor, constant: 3).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 16).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        label.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -15).isActive = true
        
        info.topAnchor.constraint(equalTo: icon.topAnchor).isActive = true
        info.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 15).isActive = true
        info.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -15).isActive = true
        
        chart.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15).isActive = true
        chart.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
        
        addTrackingArea(.init(rect: .zero, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self))
    }
    
    override func resetCursorRects() { addCursorRect(bounds, cursor: .pointingHand) }
    
    override func mouseEntered(with: NSEvent) {
        super.mouseEntered(with: with)
        layer!.backgroundColor = NSColor(named: "haze")!.withAlphaComponent(0.4).cgColor
    }
    
    override func mouseExited(with: NSEvent) {
        super.mouseExited(with: with)
        layer!.backgroundColor = NSColor(named: "background")!.cgColor
    }
    
    override func mouseDown(with: NSEvent) {
        alphaValue = 0.3
        super.mouseDown(with: with)
    }
    
    override func mouseUp(with: NSEvent) {
        if bounds.contains(convert(with.locationInWindow, from: nil)) && with.clickCount == 1 {
            app.project = index
        }
        alphaValue = 1
        super.mouseUp(with: with)
    }
}
