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
                    y = .init(card.1) / total * 60
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
            heightAnchor.constraint(equalToConstant: 75).isActive = true
            widthAnchor.constraint(equalToConstant: 20 * .init(cards.count)).isActive = true
        }
    }

    weak var top: NSLayoutConstraint! { didSet { top.isActive = true } }
    weak var left: NSLayoutConstraint! { didSet { left.isActive = true } }
    let order: Int
    private weak var _delete: Image!
    private let index: Int
    override var mouseDownCanMoveWindow: Bool { false }
    
    private var detail: String {
        switch app.session.mode(index) {
        case .kanban: return detailKanban
        case .todo: return detailTodo
        case .shopping: return detailShopping
        case .notes: return detailNotes
        default: return ""
        }
    }
    
    private var detailKanban: String {
        "\(app.session.lists(index)) " + .key("Project.columns") + "\n" +
        "\((0 ..< app.session.lists(index)).reduce(into: 0) { $0 += app.session.cards(index, list: $1) }) " + .key("Project.cards") + "\n"
    }
    
    private var detailTodo: String {
        let waiting = app.session.cards(index, list: 0)
        let done = app.session.cards(index, list: 1)
        return "\(waiting + done) " + .key("Project.tasks") + "\n"
            + "\(waiting) " + .key("Project.waiting") + "\n"
            + "\(done) " + .key("Project.done") + "\n"
    }
    
    private var detailShopping: String {
        let needed = app.session.cards(index, list: 0)
        let purchased = app.session.cards(index, list: 1)
        return "\(needed + purchased) " + .key("Project.products") + "\n"
            + "\(needed) " + .key("Project.needed") + "\n"
            + "\(purchased) " + .key("Project.purchased") + "\n"
    }
    
    private var detailNotes: String {
        "\(app.session.lists(index)) " + .key("Project.notes") + "\n"
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
        
        let label = Label(app.session.name(index), 18, .bold, NSColor(named: "haze")!)
        label.setAccessibilityElement(false)
        addSubview(label)
        
        let info = Label(detail + .key("Project.modified") + " " + modified, 13, .light, NSColor(named: "haze")!)
        info.setAccessibilityElement(false)
        addSubview(info)
        
        let chart = Chart(index)
        addSubview(chart)
        
        let _delete = Image("delete")
        _delete.alphaValue = 0
        addSubview(_delete)
        self._delete = _delete
        
        widthAnchor.constraint(equalToConstant: 200).isActive = true
        heightAnchor.constraint(equalToConstant: 220).isActive = true
        
        icon.bottomAnchor.constraint(equalTo: chart.bottomAnchor).isActive = true
        icon.leftAnchor.constraint(equalTo: leftAnchor, constant: 18).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 16).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        label.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -25).isActive = true
        
        info.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15).isActive = true
        info.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        info.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -15).isActive = true
        
        chart.bottomAnchor.constraint(equalTo: info.topAnchor, constant: -10).isActive = true
        chart.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 12).isActive = true
        
        _delete.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        _delete.topAnchor.constraint(equalTo: topAnchor).isActive = true
        _delete.widthAnchor.constraint(equalToConstant: 35).isActive = true
        _delete.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        addTrackingArea(.init(rect: .zero, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self))
    }
    
    override func resetCursorRects() { addCursorRect(bounds, cursor: .pointingHand) }
    
    override func mouseEntered(with: NSEvent) {
        super.mouseEntered(with: with)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.4
            $0.allowsImplicitAnimation = true
            layer!.backgroundColor = NSColor(named: "haze")!.withAlphaComponent(0.3).cgColor
            _delete.alphaValue = 1
        }
    }
    
    override func mouseExited(with: NSEvent) {
        super.mouseExited(with: with)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            _delete.alphaValue = 0
            layer!.backgroundColor = NSColor(named: "background")!.cgColor
        }
    }
    
    override func mouseDown(with: NSEvent) {
        alphaValue = 0.4
        super.mouseDown(with: with)
    }
    
    override func mouseUp(with: NSEvent) {
        if bounds.contains(convert(with.locationInWindow, from: nil)) && with.clickCount == 1 {
            if _delete.frame.contains(convert(with.locationInWindow, from: nil)) {
                app.runModal(for: Delete.Project(index))
            } else {
                app.project = index
            }
        }
        alphaValue = 1
        super.mouseUp(with: with)
    }
}
