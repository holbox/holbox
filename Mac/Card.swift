import AppKit

final class Card: NSView, NSTextViewDelegate {
    weak var child: Card?
    weak var top: NSLayoutConstraint! { willSet { top?.isActive = false } didSet { top.isActive = true } }
    weak var left: NSLayoutConstraint! { didSet { left.isActive = true } }
    weak var right: NSLayoutConstraint! { didSet { right.isActive = true } }
    let index: Int
    let column: Int
    private var dragging = false
    private var delta = CGFloat(0)
    private weak var content: Text!
    private weak var base: NSView!
    private weak var _delete: Button!
    override var mouseDownCanMoveWindow: Bool { false }

    required init?(coder: NSCoder) { nil }
    init(_ index: Int, column: Int) {
        self.index = index
        self.column = column
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let base = NSView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.wantsLayer = true
        base.layer!.cornerRadius = 8
        base.layer!.borderWidth = 1
        base.layer!.borderColor = .black
        addSubview(base)
        self.base = base
        
        let content = Text()
        content.font = .monospacedSystemFont(ofSize: 16, weight: .regular)
        content.string = app.session.content(app.project, list: column, card: index)
        content.tab = true
        content.intro = true
        content.standby = 0.8
        content.textContainer!.size.width = 360
        content.textContainer!.size.height = 5000
        addSubview(content)
        self.content = content
        
        let _delete = Button("delete", target: self, action: #selector(delete))
        _delete.alphaValue = 0
        addSubview(_delete)
        self._delete = _delete
        
        rightAnchor.constraint(equalTo: base.rightAnchor, constant: 40).isActive = true
        bottomAnchor.constraint(equalTo: base.bottomAnchor).isActive = true
        
        base.topAnchor.constraint(equalTo: topAnchor).isActive = true
        base.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        base.rightAnchor.constraint(equalTo: content.rightAnchor, constant: 10).isActive = true
        base.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: 10).isActive = true
        
        _delete.leftAnchor.constraint(equalTo: base.rightAnchor, constant: 10).isActive = true
        _delete.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        _delete.widthAnchor.constraint(equalToConstant: 30).isActive = true
        _delete.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        content.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        content.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        content.didChangeText()
        content.delegate = self
        
        addTrackingArea(.init(rect: .zero, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self, userInfo: nil))
    }
    
    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .pointingHand)
    }
    
    func textDidChange(_: Notification) {
        app.session.content(app.project, list: column, card: index, content: content.string)
    }
    
    func textDidBeginEditing(_: Notification) {
        base.layer!.borderColor = .haze
        base.layer!.borderWidth = 2
    }
    
    func textDidEndEditing(_: Notification) {
        base.layer!.borderColor = .black
        base.layer!.borderWidth = 1
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
            delta += abs(x) + abs(y)
            if delta > 40 {
                dragging = true
                right.isActive = false
                _delete.isHidden = true
                base.layer!.backgroundColor = NSColor.haze.withAlphaComponent(0.95).cgColor
                content.textColor = .black
                
                if let child = self.child {
                    child.top = child.topAnchor.constraint(equalTo: top.secondAnchor as! NSLayoutAnchor<NSLayoutYAxisAnchor>, constant: 20)
                    self.child = nil
                    NSAnimationContext.runAnimationGroup {
                        $0.duration = 1
                        $0.allowsImplicitAnimation = true
                        superview!.layoutSubtreeIfNeeded()
                    }
                }
            }
        }
    }
    
    func stop(_ x: CGFloat, _ y: CGFloat) {
        if dragging {
            if let column = superview!.subviews.compactMap({ $0 as? Column }).first(where: { $0.frame.minX < x && $0.frame.maxX > x })?.index {
                let index = superview!.subviews.compactMap { $0 as? Card }
                .filter { $0.column == column && $0 !== self }
                .sorted { $0.index < $1.index }
                .last { $0.frame.minY < y }?.index
                
            }
            NSAnimationContext.runAnimationGroup ({
                $0.duration = 0.6
                $0.allowsImplicitAnimation = true
                base.layer!.backgroundColor = .clear
                content.textColor = .white
            }) {
              app.main.project(app.project)
            }
        }
        dragging = false
        delta = 0
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
    
    @objc private func delete() {
        _delete.alphaValue = 0
        app.runModal(for: Delete.Card(index, list: column))
    }
}
