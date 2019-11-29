import AppKit

final class Card: Text, NSTextViewDelegate {
    weak var child: Card?
    weak var top: NSLayoutConstraint! { willSet { top?.isActive = false } didSet { top.isActive = true } }
    weak var left: NSLayoutConstraint! { didSet { left.isActive = true } }
    weak var right: NSLayoutConstraint! { didSet { right.isActive = true } }
    let index: Int
    let column: Int
    private weak var _delete: Image!
    private weak var kanban: Kanban?
    private var dragging = false
    private var deltaX = CGFloat(0)
    private var deltaY = CGFloat(0)
    override var mouseDownCanMoveWindow: Bool { false }

    required init?(coder: NSCoder) { nil }
    init(_ kanban: Kanban, index: Int, column: Int) {
        self.index = index
        self.column = column
        self.kanban = kanban
        super.init(.Expand(280, 10000), Block())
        wantsLayer = true
        layer!.cornerRadius = 8
        layer!.borderColor = NSColor(named: "haze")!.cgColor
        layer!.borderWidth = 0
        setAccessibilityLabel(.key("Card"))
        textContainerInset.height = 20
        textContainerInset.width = 20
        font = NSFont(name: "Times New Roman", size: 16)
        (textStorage as! Storage).fonts = [
            .plain: (.systemFont(ofSize: 16, weight: .medium), .white),
            .emoji: (NSFont(name: "Times New Roman", size: 30)!, .white),
            .bold: (.systemFont(ofSize: 20, weight: .bold), .white),
            .tag: (.systemFont(ofSize: 14, weight: .bold), NSColor(named: "haze")!)]
        string = app.session.content(app.project!, list: column, card: index)
        tab = true
        intro = true
        (layoutManager as! Layout).owns = true
        (layoutManager as! Layout).padding = 2
        didChangeText()
        delegate = self

        let _delete = Image("delete")
        _delete.alphaValue = 0
        addSubview(_delete)
        self._delete = _delete
        
        _delete.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        _delete.topAnchor.constraint(equalTo: topAnchor).isActive = true
        _delete.widthAnchor.constraint(equalToConstant: 35).isActive = true
        _delete.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        addTrackingArea(.init(rect: .zero, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self))
    }
    
    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .pointingHand)
    }
    
    func textDidBeginEditing(_: Notification) {
        layer!.borderWidth = 2
        layer!.backgroundColor = .clear
    }
    
    func textDidEndEditing(_: Notification) {
        layer!.borderWidth = 0
        if string != app.session.content(app.project!, list: column, card: index) {
            app.session.content(app.project!, list: column, card: index, content: string)
            app.alert(.key("Card"), message: string)
            kanban?.tags.refresh()
        }
        update(true)
    }
    
    func edit() {
        edit.activate()
        _delete.alphaValue = 0
        window!.makeFirstResponder(self)
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
                top.constant += deltaY
                left.constant += deltaX
                
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
            app.session.move(app.project!, list: column, card: index, destination: destination, index:
                superview!.subviews.compactMap { $0 as? Card }.filter { $0.column == destination && $0 !== self }.filter { $0.frame.midY < y }.count)
            kanban?.refresh()
        } else {
            deltaX = 0
            deltaY = 0
        }
    }
    
    override func mouseEntered(with: NSEvent) {
        if !dragging && window!.firstResponder != self {
            super.mouseEntered(with: with)
            NSAnimationContext.runAnimationGroup {
                $0.duration = 0.5
                $0.allowsImplicitAnimation = true
                layer!.backgroundColor = window!.firstResponder == self ? .clear : NSColor(named: "background")!.cgColor
                _delete.alphaValue = 1
            }
        }
    }
    
    override func mouseExited(with: NSEvent) {
        if !dragging && window!.firstResponder != self {
            super.mouseExited(with: with)
            NSAnimationContext.runAnimationGroup {
                $0.duration = 0.5
                $0.allowsImplicitAnimation = true
                _delete.alphaValue = 0
                if !app.session.content(app.project!, list: column, card: index).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    layer!.backgroundColor = .clear
                }
            }
        }
    }
    
    override func mouseUp(with: NSEvent) {
        if !dragging && window!.firstResponder != self && _delete != nil
            && _delete!.frame.contains(convert(with.locationInWindow, from: nil)) && with.clickCount == 1 {
            window!.makeFirstResponder(superview!)
            if string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                app.session.delete(app.project!, list: column, card: index)
                kanban?.refresh()
            } else {
                _delete!.alphaValue = 0
                app.runModal(for: Delete.Card(index, list: column))
            }
        }
        super.mouseUp(with: with)
    }
    
    func update(_ animate: Bool) {
        let color: CGColor
        if app.session.content(app.project!, list: column, card: index).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            color = NSColor(named: "background")!.cgColor
            left.constant = 20
        } else {
            color = .clear
            left.constant = 0
        }
        if animate {
            NSAnimationContext.runAnimationGroup {
                $0.duration = 0.4
                $0.allowsImplicitAnimation = true
                layer!.backgroundColor = color
                superview!.layoutSubtreeIfNeeded()
            }
        } else {
            layer!.backgroundColor = color
        }
    }
}
