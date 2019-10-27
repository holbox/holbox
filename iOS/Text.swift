import UIKit

final class Text: UITextView {
    override var accessibilityValue: String? { get { text } set { } }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero, textContainer: Container())
        textContainerInset = .init(top: 40, left: 30, bottom: 30, right: 30)
        isAccessibilityElement = true
        translatesAutoresizingMaskIntoConstraints = false
        indicatorStyle = .black
        textColor = .white
        backgroundColor = .clear
        bounces = false
        tintColor = UIColor(named: "haze")!
        font = .systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 25), weight: .medium)
        keyboardType = .alphabet
        keyboardAppearance = .dark
        keyboardDismissMode = .interactive
        spellCheckingType = app.session.spell ? .yes : .no
        autocorrectionType = app.session.spell ? .yes : .no
        autocapitalizationType = app.session.spell ? .sentences : .none
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        var rect = super.caretRect(for: position)
        rect.size.width = 3
        return rect
    }
}
