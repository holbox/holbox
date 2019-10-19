import UIKit

final class Text: UITextView {
    override var accessibilityValue: String? { get { text } set { } }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero, textContainer: Container())
        textContainerInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        isAccessibilityElement = true
        translatesAutoresizingMaskIntoConstraints = false
        textColor = .white
        backgroundColor = .clear
        bounces = false
        tintColor = .haze
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
