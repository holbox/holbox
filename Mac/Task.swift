import AppKit

final class Task: NSView {
    var highlighted = false { didSet { update() } }
    let index: Int
    let list: Int
    private weak var label: Label!
    private weak var icon: Image!
    private weak var _delete: Button!
    private weak var todo: Todo!
    private weak var circle: NSView!
    private weak var base: NSView!
    private var active: Bool { (list == 1 && !highlighted) || (list == 0 && highlighted) }
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init(_ content: String, index: Int, list: Int, _ todo: Todo) {
        self.index = index
        self.list = list
        self.todo = todo
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setAccessibilityElement(true)
        setAccessibilityRole(.button)
        setAccessibilityLabel(content)
        wantsLayer = true
        
        let base = NSView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.wantsLayer = true
        base.layer!.cornerRadius = 12
        addSubview(base)
        self.base = base
        
        let _delete = Button("delete", target: self, action: #selector(delete))
        _delete.alphaValue = 0
        addSubview(_delete)
        self._delete = _delete
        
        let circle = NSView()
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.wantsLayer = true
        circle.layer!.cornerRadius = 15
        circle.layer!.borderColor = .black
        circle.layer!.borderWidth = 2
        circle.layer!.allowsEdgeAntialiasing = true
        addSubview(circle)
        self.circle = circle
        
        let icon = Image("check")
        addSubview(icon)
        self.icon = icon
        
        let label = Label(content, 16, .medium, .white)
        addSubview(label)
        self.label = label
        
        bottomAnchor.constraint(greaterThanOrEqualTo: label.bottomAnchor, constant: 20).isActive = true
        
        base.topAnchor.constraint(equalTo: topAnchor).isActive = true
        base.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        base.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
        base.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        _delete.leftAnchor.constraint(equalTo: base.rightAnchor).isActive = true
        _delete.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        _delete.widthAnchor.constraint(equalToConstant: 30).isActive = true
        _delete.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        circle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        circle.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        circle.widthAnchor.constraint(equalToConstant: 30).isActive = true
        circle.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        icon.widthAnchor.constraint(equalToConstant: 30).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 30).isActive = true
        icon.centerXAnchor.constraint(equalTo: circle.centerXAnchor).isActive = true
        icon.centerYAnchor.constraint(equalTo: circle.centerYAnchor, constant: 1).isActive = true
        
        label.leftAnchor.constraint(equalTo: circle.rightAnchor, constant: 10).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: base.rightAnchor, constant: -20).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        
        addTrackingArea(.init(rect: .zero, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self))
        update()
    }
    
    override func resetCursorRects() { addCursorRect(bounds, cursor: .pointingHand) }
    
    override func mouseDown(with: NSEvent) {
        if base.bounds.contains(convert(with.locationInWindow, from: nil)) {
            highlighted = true
        }
        super.mouseDown(with: with)
    }
    
    override func mouseEntered(with: NSEvent) {
        super.mouseEntered(with: with)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            base.layer!.backgroundColor = NSColor(named: "background")!.cgColor
            _delete.alphaValue = 1
        }
    }
    
    override func mouseExited(with: NSEvent) {
        super.mouseExited(with: with)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            base.layer!.backgroundColor = .clear
            _delete.alphaValue = 0
        }
    }
    
    override func mouseUp(with: NSEvent) {
        if base.bounds.contains(convert(with.locationInWindow, from: nil)) {
            app.alert(list == 1 ? .key("Todo.restart") : .key("Todo.completed"), message: app.session.content(app.project, list: list, card: index))
            app.session.move(app.project, list: list, card: index, destination: list == 1 ? 0 : 1, index: 0)
            todo.refresh()
        }
        highlighted = false
        super.mouseUp(with: with)
    }
    
    private func update() {
        icon.isHidden = !active
        circle.layer!.backgroundColor = active ? NSColor(named: "haze")!.cgColor : NSColor(named: "background")!.cgColor
        label.textColor = active ? NSColor(named: "haze")! : .white
    }
    
    @objc private func delete() {
        window!.makeFirstResponder(self)
        _delete.alphaValue = 0
        app.runModal(for: Delete.Card(todo, index: index, list: list))
    }
}
