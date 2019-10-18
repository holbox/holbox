import UIKit

final class Label: UILabel {
    override var accessibilityLabel: String? { get { attributedText!.string } set { } } 
    required init?(coder: NSCoder) { nil }
    
    init(_ string: String, _ size: CGFloat, _ weight: UIFont.Weight, _ color: UIColor) {
        super.init(frame: .zero)
        font = .systemFont(ofSize: UIFontMetrics.default.scaledValue(for: size), weight: weight)
        text = string
        textColor = color
        configure()
    }
    
    init(_ strings: [(String, CGFloat, UIFont.Weight, UIColor)]) {
        super.init(frame: .zero)
        attributedText = strings.reduce(into: NSMutableAttributedString(), {
            $0.append(.init(string: $1.0, attributes: [.font: UIFont.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: $1.1), weight: $1.2), .foregroundColor: $1.3]))
        })
        configure()
    }
    
    private func configure() {
        numberOfLines = 0
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = .staticText
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
}
