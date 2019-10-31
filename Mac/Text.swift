import AppKit

final class Text: NSTextView {
    var edit = false
    var tab = false
    var intro = false
    var standby: NSColor? { didSet { textColor = standby } }
    override var acceptsFirstResponder: Bool { edit }
    override var mouseDownCanMoveWindow: Bool { !edit }
    override var canBecomeKeyView: Bool { edit }
    override var isEditable: Bool { get { edit } set { } }
    override var isSelectable: Bool { get { edit } set { } }
    override func accessibilityValue() -> String? { string }
    private weak var width: NSLayoutConstraint!
    private weak var height: NSLayoutConstraint!
    
    override var font: NSFont? { didSet {
        (textStorage as! Storage).fonts = [.plain: font!,
                                           .emoji: .systemFont(ofSize: font!.pointSize * 3, weight: .regular),
                                           .bold: .systemFont(ofSize: font!.pointSize * 2, weight: .bold)]
    } }
    
    
    required init?(coder: NSCoder) { nil }
    init() {
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
        
        width = widthAnchor.constraint(equalToConstant: 0)
        height = heightAnchor.constraint(equalToConstant: 0)
        height.isActive = true
        width.isActive = true
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
        width.constant = max(layoutManager!.usedRect(for: textContainer!).size.width + 20, 60)
        height.constant = layoutManager!.usedRect(for: textContainer!).size.height + 20
    }
    
    override func becomeFirstResponder() -> Bool {
        if standby != nil {
            textColor = .white
        }
        textContainer!.lineBreakMode = .byTruncatingMiddle
        delegate?.textDidBeginEditing?(.init(name: .init("")))
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        setSelectedRange(.init())
        if let standby = standby {
            textColor = standby
        }
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
