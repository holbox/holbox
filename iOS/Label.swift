import UIKit

final class Label: UILabel { 
    required init?(coder: NSCoder) { nil }
    
    init(_ string: String, _ font: UIFont, _ color: UIColor) {
        super.init(frame: .zero)
        font = .systemFont(ofSize: UIFontMetrics.default.scaledValue(for: size), weight: weight)
        text = string
        textColor = color
        accessibilityLabel = string
        configure()
    }
    
    init(_ strings: [(String, UIFont, UIColor)], align: NSTextAlignment = .left) {
        super.init(frame: .zero)
        attributed(strings, align: align)
        configure()
    }
    
    func attributed(_ strings: [(String, UIFont, UIColor)], align: NSTextAlignment = .left) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = align
        attributedText = strings.reduce(into: NSMutableAttributedString(), {
            $0.append(.init(string: $1.0, attributes: [.font: $1.1, .foregroundColor: $1.2, .paragraphStyle: paragraph]))
        })
        accessibilityLabel = attributedText!.string
    }
    
    private func configure() {
        numberOfLines = 0
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = .staticText
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
}
