import UIKit

final class Card: Text, UITextViewDelegate {
    let index: Int
    let column: Int
    weak var left: NSLayoutConstraint! {
        didSet {
            left.constant = text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 10 : 0
            left.isActive = true
    } }
    private weak var kanban: Kanban?
    
    required init?(coder: NSCoder) { nil }
    init(_ kanban: Kanban, index: Int, column: Int) {
        self.index = index
        self.column = column
        self.kanban = kanban
        super.init()
        isScrollEnabled = false
        textContainerInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        isEditable = false
        accessibilityLabel = .key("Card")
        font = .systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 16), weight: .medium)
        (textStorage as! Storage).fonts = [
            .plain: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 16), weight: .medium), .white),
            .emoji: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 30), weight: .regular), .white),
            .bold: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 20), weight: .bold), .white),
            .tag: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 14), weight: .bold), UIColor(named: "haze")!)]
        delegate = self
        (layoutManager as! Layout).padding = 2
        layer.cornerRadius = 8
        layer.borderColor = UIColor(named: "haze")!.cgColor
        layer.borderWidth = 0
        width = widthAnchor.constraint(equalToConstant: 0)
        height = heightAnchor.constraint(equalToConstant: 0)
        update()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with: UIEvent?) {
        UIView.animate(withDuration: 0.35) { [weak self] in
            self?.alpha = 0.3
        }
        super.touchesBegan(touches, with: with)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with: UIEvent?) {
        UIView.animate(withDuration: 0.35) { [weak self] in
            self?.alpha = 1
        }
        super.touchesCancelled(touches, with: with)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with: UIEvent?) {
        if app.presentedViewController == nil && bounds.contains(touches.first!.location(in: self)) {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.backgroundColor = UIColor(named: "haze")!.withAlphaComponent(0.4)
            }
            kanban!.center(frame)
            app.present(Move(self), animated: true)
        }
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.alpha = 1
        }
        super.touchesEnded(touches, with: with)
    }
    
    func textViewDidChange(_: UITextView) {
        resize()
    }
    
    func textViewDidEndEditing(_: UITextView) {
        isEditable = false
        if text != app.session.content(app.project!, list: column, card: index) {
            app.session.content(app.project!, list: column, card: index, content: text)
            app.alert(.key("Card"), message: text)
        }
        update()
    }
    
    func edit() {
        isEditable = true
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.layer.borderWidth = 2
            self?.backgroundColor = .clear
        }) { [weak self] _ in
            self?.becomeFirstResponder()
        }
    }
    
    private func update() {
        let color: UIColor
        text = app.session.content(app.project!, list: column, card: index)
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            width.constant = 60
            height.constant = 40
            color = UIColor(named: "background")!
            left?.constant = 10
        } else {
            resize()
            color = .clear
            left?.constant = 0
        }
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.superview?.layoutIfNeeded()
            self?.backgroundColor = color
            self?.layer.borderWidth = 0
        }
    }
    
    private func resize() {
        textContainer.size.width = 200
        textContainer.size.height = 10_000
        layoutManager.ensureLayout(for: textContainer)
        width.constant = max(ceil(layoutManager.usedRect(for: textContainer).size.width), 40) + 20
        height.constant = max(ceil(layoutManager.usedRect(for: textContainer).size.height), 20) + 20
    }
    
    private func move(_ destination: Int, position: Int) {
//        app.session.move(app.project, list: column, card: index, destination: destination, index: position)
//        kanban.refresh()
    }
    
    @objc private func delete() {
//        app.alert(.key("Delete.deleted.card.\(app.mode.rawValue)"), message: app.session.content(app.project, list: column, card: index))
//        app.session.delete(app.project, list: column, card: index)
//        kanban.refresh()
    }
}
