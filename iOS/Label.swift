import UIKit

final class Label: UILabel {
    override var accessibilityLabel: String? { get { attributedText!.string } set { } } 
    
    required init?(coder: NSCoder) { nil }
    init(_ string: String = "") {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = .staticText
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    func font(_ size: CGFloat, _ weight: UIFont.Weight) {
        font = .systemFont(ofSize: UIFontMetrics.default.scaledValue(for: size), weight: weight)
    }
}
