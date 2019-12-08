import UIKit

final class Column: Text, UITextViewDelegate {
    let index: Int
    private weak var kanban: Kanban!
    
    required init?(coder: NSCoder) { nil }
    init(_ kanban: Kanban, index: Int) {
        self.index = index
        self.kanban = kanban
        super.init()
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        isScrollEnabled = false
        isEditable = false
        isSelectable = false
        textContainerInset = .init(top: 15, left: 15, bottom: 15, right: 15)
        accessibilityLabel = .key("Column")
        font = .systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 20), weight: .medium)
        (textStorage as! Storage).fonts = [
            .plain: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 20), weight: .bold), UIColor(named: "haze")!),
            .emoji: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 20), weight: .regular), UIColor(named: "haze")!),
            .bold: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 20), weight: .bold), UIColor(named: "haze")!),
            .tag: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 20), weight: .bold), UIColor(named: "haze")!)]
        delegate = self
        textContainer.maximumNumberOfLines = 1
        (layoutManager as! Layout).padding = 2
        layer.cornerRadius = 8
        layer.borderColor = UIColor(named: "haze")!.cgColor
        layer.borderWidth = 0
        text = app.session.name(app.project, list: index)
        width = widthAnchor.constraint(greaterThanOrEqualToConstant: 0)
        height = heightAnchor.constraint(equalToConstant: 60)
        
        let maxWidth = widthAnchor.constraint(lessThanOrEqualToConstant: 250)
        maxWidth.priority = .defaultLow
        maxWidth.isActive = true
        resize()
        
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(gesture(_:))))
    }
    
    func textView(_: UITextView, shouldChangeTextIn: NSRange, replacementText: String) -> Bool {
        if replacementText == "\n" {
            resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidChange(_: UITextView) {
        resize()
    }
    
    func textViewDidEndEditing(_: UITextView) {
        isEditable = false
        isSelectable = false
        layer.borderWidth = 0
        if text != app.session.name(app.project, list: index) {
            app.session.name(app.project, list: index, name: text)
            app.alert(.key("Column"), message: text)
            kanban.charts()
        }
    }
    
    private func resize() {
        layoutManager.ensureLayout(for: textContainer)
        width.constant = min(max(ceil(layoutManager.usedRect(for: textContainer).size.width), 30) + 30, 250)
    }
    
    @objc private func gesture(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            isEditable = true
            isSelectable = true
            layer.borderWidth = 2
            becomeFirstResponder()
            selectedRange = .init(location: 0, length: text.utf16.count)
        }
    }
}
