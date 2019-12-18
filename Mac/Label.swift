import AppKit

final class Label: NSTextField {
    override var acceptsFirstResponder: Bool { false }
    override var canBecomeKeyView: Bool { false }
    override var mouseDownCanMoveWindow: Bool { true }
    override func acceptsFirstMouse(for: NSEvent?) -> Bool { false }
    required init?(coder: NSCoder) { nil }

    init(_ string: String, _ size: CGFloat, _ weight: NSFont.Weight, _ color: NSColor) {
        super.init(frame: .zero)
        font = NSFont(name: {
            switch $0 {
            case .light: return "Rubik-Light"
            case .medium: return "Rubik-Medium"
            case .bold: return "Rubik-Bold"
            default: return "Rubik-Regular"
            }
        } (weight), size: size)!
        stringValue = string
        textColor = color
        setAccessibilityLabel(string)
        configure()
    }
    
    init(_ strings: [(String, CGFloat, NSFont.Weight, NSColor)], align: NSTextAlignment = .left) {
        super.init(frame: .zero)
        attributed(strings, align: align)
        configure()
    }
    
    func attributed(_ strings: [(String, CGFloat, NSFont.Weight, NSColor)], align: NSTextAlignment = .left) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = align
        attributedStringValue = strings.reduce(into: NSMutableAttributedString(), {
            $0.append(.init(string: $1.0, attributes: [.font: NSFont(name: {
                switch $0 {
                case .light: return "Rubik-Light"
                case .medium: return "Rubik-Medium"
                case .bold: return "Rubik-Bold"
                default: return "Rubik-Regular"
                }
            } ($1.2), size: $1.1)!, .foregroundColor: $1.3, .paragraphStyle: paragraph]))
        })
        setAccessibilityLabel(attributedStringValue.string)
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        isBezeled = false
        isEditable = false
        isSelectable = false
        setAccessibilityElement(true)
        setAccessibilityRole(.staticText)
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
}
