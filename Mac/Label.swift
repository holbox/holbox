import AppKit

final class Label: NSTextField {
    override var acceptsFirstResponder: Bool { false }
    override var canBecomeKeyView: Bool { false }
    override var mouseDownCanMoveWindow: Bool { true }
    override func accessibilityLabel() -> String? { attributedStringValue.string }
    
    required init?(coder: NSCoder) { nil }
    init(_ string: String = "") {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        stringValue = string
        isBezeled = false
        isEditable = false
        isSelectable = false
        setAccessibilityElement(true)
        setAccessibilityRole(.staticText)
    }
    
    override func acceptsFirstMouse(for: NSEvent?) -> Bool { false }
}
