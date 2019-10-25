import AppKit

final class Text: NSTextView {
    var edit = false
    var tab = false
    var intro = false
    var standby = CGFloat(0.2) { didSet { alphaValue = standby } }
    override var acceptsFirstResponder: Bool { edit }
    override var mouseDownCanMoveWindow: Bool { !edit }
    override var canBecomeKeyView: Bool { edit }
    override var isEditable: Bool { get { edit } set { } }
    override var isSelectable: Bool { get { edit } set { } }
    override func accessibilityValue() -> String? { string }
    private weak var width: NSLayoutConstraint!
    private weak var height: NSLayoutConstraint!
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero, textContainer: Container())
        textContainerInset.height = 10
        textContainerInset.width = 10
        setAccessibilityElement(true)
        setAccessibilityRole(.textField)
        translatesAutoresizingMaskIntoConstraints = false
        textColor = .white
        allowsUndo = true
        isRichText = false
        drawsBackground = false
        isContinuousSpellCheckingEnabled = app.session.spell
        isAutomaticTextCompletionEnabled = app.session.spell
        insertionPointColor = NSColor(named: "haze")!
        alphaValue = standby
        
        width = widthAnchor.constraint(equalToConstant: 0)
        height = heightAnchor.constraint(equalToConstant: 0)
        height.isActive = true
        width.isActive = true
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
        width.constant = max(layoutManager!.usedRect(for: textContainer!).size.width + 20, 60)
        height.constant = layoutManager!.usedRect(for: textContainer!).size.height + 20
    }
    
    override func becomeFirstResponder() -> Bool {
        alphaValue = 1
        textContainer!.lineBreakMode = .byTruncatingMiddle
        delegate?.textDidBeginEditing?(Notification(name: .init("")))
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        setSelectedRange(.init())
        alphaValue = standby
        textContainer!.lineBreakMode = .byTruncatingTail
        edit = false
        return super.resignFirstResponder()
    }
    
    override func keyDown(with: NSEvent) {
        switch with.keyCode {
        case 53: window!.makeFirstResponder(superview!)
        case 48:
            if tab {
                super.keyDown(with: with)
            } else {
                window!.makeFirstResponder(superview!)
            }
        case 36:
            if intro {
                super.keyDown(with: with)
            } else {
                window!.makeFirstResponder(superview!)
            }
        default: super.keyDown(with: with)
        }
    }
    
    override func mouseDown(with: NSEvent) {
        if !edit && with.clickCount == 2 {
            edit = true
            window!.makeFirstResponder(self)
        }
        super.mouseDown(with: with)
    }
}
