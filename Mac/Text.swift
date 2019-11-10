import AppKit

final class Text: NSTextView {
    var tab = false
    var intro = false
    var standby: NSColor? { didSet { applyStandby() } }
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
        resize.configure(self)
    }
    
    override var textColor: NSColor? { didSet {
        guard let storage = textStorage, let color = textColor else { return }
        storage.removeAttribute(.foregroundColor, range: .init(location: 0, length: storage.length))
        storage.addAttribute(.foregroundColor, value: color, range: .init(location: 0, length: storage.length))
    } }
    
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
        if standby != nil {
            textColor = .white
            alphaValue = 1
        }
        textContainer!.lineBreakMode = .byTruncatingMiddle
        delegate?.textDidBeginEditing?(.init(name: .init("")))
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        setSelectedRange(.init())
        textContainer!.lineBreakMode = .byTruncatingTail
        applyStandby()
        edit.resign()
        return super.resignFirstResponder()
    }
    
    override func keyDown(with: NSEvent) {
        switch with.keyCode {
        case 12:
            if with.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command {
                app.terminate(nil)
            } else {
                super.keyUp(with: with)
            }
        case 53: window!.makeFirstResponder(superview!)
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
        if !edit.active && with.clickCount == 2 {
            edit.click()
            window!.makeFirstResponder(self)
        }
        super.mouseDown(with: with)
    }
    
    override func layout() {
        super.layout()
        resize.layout(self)
    }
    
    private func applyStandby() {
        if let standby = standby {
            textColor = standby
        }
    }
}
