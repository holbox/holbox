import UIKit

final class Text: UITextView {
    override var accessibilityValue: String? { get { text } set { } }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero, textContainer: Container())
        textContainerInset = .init(top: 20, left: 20, bottom: 20, right: 20)
        isAccessibilityElement = true
        translatesAutoresizingMaskIntoConstraints = false
        indicatorStyle = .white
        verticalScrollIndicatorInsets.top = 20
        textColor = .white
        backgroundColor = .clear
        bounces = false
        tintColor = UIColor(named: "haze")!
        font = .systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 25), weight: .medium)
        keyboardAppearance = .dark
        keyboardDismissMode = .interactive
        spellCheckingType = app.session.spell ? .yes : .no
        autocorrectionType = app.session.spell ? .yes : .no
        autocapitalizationType = app.session.spell ? .sentences : .none
        
//        (textStorage as! Storage).fonts = [.plain: font!,
//                                           .emoji: .systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 50), weight: .regular),
//                                           .bold: .systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 32), weight: .bold)]
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        var rect = super.caretRect(for: position)
        rect.size.width = 3
        return rect
    }
}
