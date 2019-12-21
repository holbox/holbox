import UIKit

final class Column: Text, UITextViewDelegate {
    let index: Int
    private weak var kanban: Kanban!
    
    required init?(coder: NSCoder) { nil }
    init(_ kanban: Kanban, index: Int) {
        self.index = index
        self.kanban = kanban
        super.init(.init())
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        isScrollEnabled = false
        isEditable = false
        isSelectable = false
        textContainerInset = .init(top: 15, left: 15, bottom: 15, right: 15)
        accessibilityLabel = .key("Column")
        font = .systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 15), weight: .medium)
//        (textStorage as! Storage).fonts = [
//            .plain: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 15), weight: .bold), UIColor(named: "haze")!),
//            .emoji: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 15), weight: .regular), UIColor(named: "haze")!),
//            .bold: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 15), weight: .bold), UIColor(named: "haze")!),
//            .tag: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 15), weight: .bold), UIColor(named: "haze")!)]
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
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with: UIEvent?) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.alpha = 0.3
        }
        super.touchesBegan(touches, with: with)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with: UIEvent?) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.alpha = 1
        }
        super.touchesCancelled(touches, with: with)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with: UIEvent?) {
        if app.presentedViewController == nil && bounds.contains(touches.first!.location(in: self)) {
            app.window!.endEditing(true)
            kanban.scroll.center(frame)
            app.present(Columner(self), animated: true)
        }
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.alpha = 1
        }
        super.touchesEnded(touches, with: with)
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
        kanban.scroll.center(frame)
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
    
    func edit() {
        isEditable = true
        isSelectable = true
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.layer.borderWidth = 2
        }) { [weak self] _ in
            guard let self = self else { return }
            self.becomeFirstResponder()
            self.selectedRange = .init(location: 0, length: self.text.utf16.count)
        }
    }
    
    private func resize() {
        layoutManager.ensureLayout(for: textContainer)
        width.constant = min(max(ceil(layoutManager.usedRect(for: textContainer).size.width), 30) + 30, 250)
    }
}
