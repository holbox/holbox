import AppKit

final class Card: Text, NSTextViewDelegate {
    var index: Int
    weak var top: NSLayoutConstraint! {
        didSet {
            oldValue?.isActive = false
            top.isActive = true
        }
    }
    
    weak var child: Card! {
        didSet {
            child?.top = child?.topAnchor.constraint(equalTo: bottomAnchor, constant: 20)
        }
    }
    
    weak var column: Column! {
        didSet {
            right?.isActive = false
            left?.isActive = false
            
            right = column.rightAnchor.constraint(greaterThanOrEqualTo: rightAnchor)
            right.isActive = true
            
            left = leftAnchor.constraint(equalTo: column.leftAnchor)
            left.isActive = true
        }
    }
    
    private(set) weak var kanban: Kanban!
    private weak var left: NSLayoutConstraint!
    private weak var right: NSLayoutConstraint!
    private weak var _delete: Image!
    private var dragging = false
    private var deltaX = CGFloat(0)
    private var deltaY = CGFloat(0)
    override var mouseDownCanMoveWindow: Bool { false }

    required init?(coder: NSCoder) { nil }
    init(_ kanban: Kanban, index: Int) {
        self.index = index
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
        tab = true
        intro = true
        (layoutManager as! Layout).owns = true
        (layoutManager as! Layout).padding = 2
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
        guard let column = column?.index else { return }
        if string != app.session.content(app.project, list: column, card: index) {
            app.session.content(app.project, list: column, card: index, content: string)
            app.alert(.key("Card"), message: string)
            kanban.tags.refresh()
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
                if let parent = superview!.subviews.compactMap({ $0 as? Card }).first(where: { $0.child === self }) {
                    parent.child = child
                } else if column.index == 0 {
                    child?.top = child?.topAnchor.constraint(equalTo: kanban._add.bottomAnchor, constant: 40)
                } else {
                    child?.top = child?.topAnchor.constraint(equalTo: column.bottomAnchor, constant: 20)
                }
                child = nil
                superview!.subviews.compactMap { $0 as? Card }.filter { $0.column === column && $0.index > index }.forEach {
                    $0.index -= 1
                }
                NSAnimationContext.runAnimationGroup {
                    $0.duration = 0.4
                    $0.allowsImplicitAnimation = true
                    layer!.backgroundColor = .black
                    layer!.borderWidth = 5
                    superview!.layoutSubtreeIfNeeded()
                }
            }
        }
    }
    
    func stop() {
        if dragging {
            dragging = false
            top.isActive = false
            let columns = superview!.subviews.compactMap { $0 as? Column }.sorted { $0.index < $1.index }
            let destination = columns.filter { $0.frame.minX < frame.midX }.last ?? columns.first!
            let cards = superview!.subviews.compactMap { $0 as? Card }.filter { $0.column === destination }.filter { $0 !== self }
            let new = cards.filter { $0.frame.midY < frame.minY }.count
            app.session.move(app.project, list: column.index, card: index, destination: destination.index, index: new)
            index = new
            if index == 0 {
                if destination.index == 0 {
                    top = topAnchor.constraint(equalTo: kanban._add.bottomAnchor, constant: 40)
                } else {
                    top = topAnchor.constraint(equalTo: destination.bottomAnchor, constant: 20)
                }
                child = cards.first { $0.index == index }
            } else {
                let parent = cards.first { $0.index == index - 1 }!
                child = parent.child
                parent.child = self
            }
            cards.filter { $0.index >= index }.forEach {
                $0.index += 1
            }
            column = destination
            update(true)
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
                if !app.session.content(app.project, list: column.index, card: index).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
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
                app.session.delete(app.project, list: column.index, card: index)
                kanban.refresh()
            } else {
                _delete!.alphaValue = 0
                app.runModal(for: Delete.Card(index, list: column.index))
            }
        }
        super.mouseUp(with: with)
    }
    
    func update(_ animate: Bool) {
        let color: CGColor
        if app.session.content(app.project, list: column.index, card: index).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
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
                layer!.borderWidth = 0
                superview!.layoutSubtreeIfNeeded()
            }
        } else {
            layer!.backgroundColor = color
            string = app.session.content(app.project, list: column.index, card: index)
            didChangeText()
        }
    }
}
