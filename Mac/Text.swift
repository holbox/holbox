import AppKit

final class Text: NSTextView {
    var tab = false
    var intro = false
    var clear = false
    let edit: Edit
    private let resize: Resize
    override var acceptsFirstResponder: Bool { edit.active }
    override var mouseDownCanMoveWindow: Bool { !edit.active }
    override var canBecomeKeyView: Bool { edit.active }
    override var isEditable: Bool { get { edit.active } set { } }
    override var isSelectable: Bool { get { edit.active } set { } }
    override func accessibilityValue() -> String? { string }
    
    required init?(coder: NSCoder) { nil }
    init(_ resize: Resize, _ edit: Edit) {
        self.resize = resize
        self.edit = edit
        super.init(frame: .zero, textContainer: Container())
        textContainerInset.height = 10
        textContainerInset.width = 10
        setAccessibilityElement(true)
        setAccessibilityRole(.textField)
        translatesAutoresizingMaskIntoConstraints = false
        allowsUndo = true
        isRichText = false
        drawsBackground = false
        isContinuousSpellCheckingEnabled = app.session.spell
        isAutomaticTextCompletionEnabled = app.session.spell
        insertionPointColor = NSColor(named: "haze")!
        selectedTextAttributes = [.backgroundColor: NSColor(named: "haze")!, .foregroundColor: NSColor.black]
        
        resize.configure(self)
    }
    
    override final func drawInsertionPoint(in rect: NSRect, color: NSColor, turnedOn: Bool) {
        var rect = rect
        rect.size.width = 3
        super.drawInsertionPoint(in: rect, color: color, turnedOn: turnedOn)
    }
    
    override func setNeedsDisplay(_ rect: NSRect, avoidAdditionalLayout: Bool) {
        var rect = rect
        rect.size.width += 3
        super.setNeedsDisplay(rect, avoidAdditionalLayout: avoidAdditionalLayout)
    }
    
    override func didChangeText() {
        super.didChangeText()
        resize.update(self)
    }
    
    override func becomeFirstResponder() -> Bool {
        textContainer!.lineBreakMode = .byTruncatingMiddle
        delegate?.textDidBeginEditing?(.init(name: .init("")))
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        setSelectedRange(.init())
        textContainer!.lineBreakMode = .byTruncatingTail
        edit.resign()
        return super.resignFirstResponder()
    }
    
    override func keyDown(with: NSEvent) {
        switch with.keyCode {
        case 3, 5, 45:
            if with.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command {
                window!.keyDown(with: with)
            } else {
                super.keyDown(with: with)
            }
        case 12:
            if with.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command {
                app.terminate(nil)
            } else {
                super.keyDown(with: with)
            }
        case 53:
            if clear {
                string = ""
                delegate?.textDidChange?(.init(name: .init("")))
            }
            window!.makeFirstResponder(superview!)
        case 48:
            if tab {
                super.keyDown(with: with)
            } else {
                window!.keyDown(with: with)
                window!.makeFirstResponder(superview!)
            }
        case 36:
            if intro {
                super.keyDown(with: with)
            } else {
                window!.keyDown(with: with)
                window!.makeFirstResponder(superview!)
            }
        default: super.keyDown(with: with)
        }
    }
    
    override func mouseDown(with: NSEvent) {
        if edit.active {
            super.mouseDown(with: with)
        } else if with.clickCount == 2 {
            click()
        } else {
            superview!.mouseDown(with: with)
        }
    }
    
    override func rightMouseUp(with: NSEvent) {
        if edit.active {
            super.rightMouseUp(with: with)
        } else if bounds.contains(convert(with.locationInWindow, from: nil)) && with.clickCount == 1 {
            click()
        }
    }
    
    override func layout() {
        super.layout()
        resize.layout(self)
    }
    
    private func click() {
        edit.click()
        if edit.active {
            window!.makeFirstResponder(self)
        }
    }
}
