import AppKit

final class Card: NSView, NSTextViewDelegate {
    weak var child: Card?
    weak var top: NSLayoutConstraint! { willSet { top?.isActive = false } didSet { top.isActive = true } }
    weak var left: NSLayoutConstraint! { didSet { left.isActive = true } }
    weak var right: NSLayoutConstraint! { didSet { right.isActive = true } }
    let index: Int
    let column: Int
    private weak var empty: Image?
    private weak var content: Text!
    private weak var base: NSView!
    private weak var _delete: Button!
    private weak var kanban: Kanban!
    private var dragging = false
    private var deltaX = CGFloat(0)
    private var deltaY = CGFloat(0)
    override var mouseDownCanMoveWindow: Bool { false }

    required init?(coder: NSCoder) { nil }
    init(_ kanban: Kanban, index: Int, column: Int) {
        self.index = index
        self.column = column
        self.kanban = kanban
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        
        let base = NSView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.wantsLayer = true
        base.layer!.cornerRadius = 16
        base.layer!.borderColor = NSColor(named: "haze")!.cgColor
        addSubview(base)
        self.base = base
        
        let content = Text()
        content.setAccessibilityLabel(.key("Card"))
        content.font = .systemFont(ofSize: 16, weight: .medium)
        content.string = app.session.content(app.project, list: column, card: index)
        content.tab = true
        content.intro = true
        content.standby = .init(white: 1, alpha: 0.8)
        content.textContainer!.size.width = 300
        content.textContainer!.size.height = 5000
        addSubview(content)
        self.content = content

        let _delete = Button("delete", target: self, action: #selector(delete))
        _delete.alphaValue = 0
        addSubview(_delete)
        self._delete = _delete
        
        rightAnchor.constraint(equalTo: base.rightAnchor, constant: 30).isActive = true
        bottomAnchor.constraint(equalTo: base.bottomAnchor).isActive = true
        
        base.topAnchor.constraint(equalTo: topAnchor).isActive = true
        base.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        base.rightAnchor.constraint(equalTo: content.rightAnchor, constant: 10).isActive = true
        base.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: 10).isActive = true
        
        _delete.leftAnchor.constraint(equalTo: base.rightAnchor).isActive = true
        _delete.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        _delete.widthAnchor.constraint(equalToConstant: 30).isActive = true
        _delete.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        content.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        content.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        content.didChangeText()
        content.delegate = self
        
        addTrackingArea(.init(rect: .zero, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self))
        update()
    }
    
    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .pointingHand)
    }
    
    func textDidBeginEditing(_: Notification) {
        base.layer!.borderWidth = 2
        empty?.removeFromSuperview()
    }
    
    func textDidEndEditing(_: Notification) {
        base.layer!.borderWidth = 0
        app.session.content(app.project, list: column, card: index, content: content.string)
        update()
    }
    
    func edit() {
        content.edit = true
        window!.makeFirstResponder(content)
    }
    
    func drag(_ x: CGFloat, _ y: CGFloat) {
        if dragging {
            top.constant += y
            left.constant += x
        } else {
            deltaX += x
            deltaY += y
            if abs(deltaX) + abs(deltaY) > 15 {
                dragging = true
                right.isActive = false
                _delete.isHidden = true
                top.constant += deltaY
                left.constant += deltaX
                base.layer!.backgroundColor = NSColor(named: "haze")!.cgColor
                content.textColor = .black
                
                layer!.removeFromSuperlayer()
                superview!.layer!.addSublayer(layer!)
                superview!.subviews.compactMap { $0 as? Card }.forEach { card in
                    card.trackingAreas.forEach(card.removeTrackingArea(_:))
                }
                
                if let child = self.child {
                    child.top = child.topAnchor.constraint(equalTo: top.secondAnchor as! NSLayoutAnchor<NSLayoutYAxisAnchor>, constant: 20)
                    self.child = nil
                    NSAnimationContext.runAnimationGroup {
                        $0.duration = 0.3
                        $0.allowsImplicitAnimation = true
                        superview!.layoutSubtreeIfNeeded()
                    }
                }
            }
        }
    }
    
    func stop(_ x: CGFloat, _ y: CGFloat) {
        if dragging {
            let destination = max(superview!.subviews.compactMap { $0 as? Column }.filter { $0.frame.minX < x }.count - 1, 0)
            app.session.move(app.project, list: column, card: index, destination: destination, index:
                superview!.subviews.compactMap { $0 as? Card }.filter { $0.column == destination && $0 !== self }.filter { $0.frame.midY < y }.count)
            NSAnimationContext.runAnimationGroup ({
                $0.duration = 0.3
                $0.allowsImplicitAnimation = true
                alphaValue = 0.1
            }) { [weak self] in self?.kanban.refresh() }
        }
        dragging = false
        deltaX = 0
        deltaY = 0
    }
    
    override func mouseEntered(with: NSEvent) {
        super.mouseEntered(with: with)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            _delete.alphaValue = 1
        }
    }
    
    override func mouseExited(with: NSEvent) {
        super.mouseExited(with: with)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            _delete.alphaValue = 0
        }
    }
    
    private func update() {
        self.empty?.removeFromSuperview()
        if app.session.content(app.project, list: column, card: index).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let empty = Image("empty")
            addSubview(empty, positioned: .below, relativeTo: content)
            self.empty = empty
            
            empty.widthAnchor.constraint(equalToConstant: 34).isActive = true
            empty.heightAnchor.constraint(equalToConstant: 34).isActive = true
            empty.leftAnchor.constraint(equalTo: content.leftAnchor, constant: 11).isActive = true
            empty.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        }
    }
    
    @objc private func delete() {
        _delete.alphaValue = 0
        app.runModal(for: Delete.Card(kanban, index: index, list: column))
    }
}
