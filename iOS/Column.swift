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
        textContainerInset = .init(top: 20, left: 20, bottom: 20, right: 20)
        accessibilityLabel = .key("Column")
        font = .medium(14)
        textColor = .haze()
        delegate = self
        textContainer.maximumNumberOfLines = 1
        (layoutManager as! Layout).padding = 2
        layer.cornerRadius = 8
        layer.borderColor = .haze()
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
            app.present(Edit(self), animated: true)
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
        width.constant = min(max(ceil(layoutManager.usedRect(for: textContainer).size.width), 20) + 40, 250)
    }
}
