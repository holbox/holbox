import UIKit

final class Text: UITextView {
    weak var width: NSLayoutConstraint! { didSet { oldValue?.isActive = false; width.isActive = true } }
    weak var height: NSLayoutConstraint! { didSet { oldValue?.isActive = false; height.isActive = true } }
    override var accessibilityValue: String? { get { text } set { } }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero, textContainer: Container())
        textContainerInset = .zero
        textContainer.widthTracksTextView = false
        textContainer.heightTracksTextView = false
        isAccessibilityElement = true
        translatesAutoresizingMaskIntoConstraints = false
        indicatorStyle = .white
        textColor = .white
        backgroundColor = .clear
        bounces = false
        tintColor = UIColor(named: "haze")!
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
