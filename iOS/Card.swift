import UIKit

final class Card: Text, UITextViewDelegate {
    var index: Int
    weak var top: NSLayoutConstraint! {
        didSet {
            oldValue?.isActive = false
            top.isActive = true
        }
    }
    
    weak var child: Card! {
        didSet {
            child?.top = child?.topAnchor.constraint(equalTo: bottomAnchor, constant: 10)
        }
    }
    
    weak var column: Column! {
        didSet {
            right?.isActive = false
            left?.isActive = false
            
            right = column.rightAnchor.constraint(greaterThanOrEqualTo: rightAnchor)
            right.isActive = true
            
            left = leftAnchor.constraint(equalTo: column.leftAnchor)
            left.isActive = true
        }
    }
    
    private(set) weak var kanban: Kanban!
    private weak var left: NSLayoutConstraint!
    private weak var right: NSLayoutConstraint!
    
    required init?(coder: NSCoder) { nil }
    init(_ kanban: Kanban, index: Int) {
        self.index = index
        self.kanban = kanban
        super.init(Storage())
        isScrollEnabled = false
        textContainerInset = .init(top: 15, left: 15, bottom: 15, right: 15)
        isEditable = false
        isSelectable = false
        accessibilityLabel = .key("Card")
        font = .regular(14)
        (textStorage as! Storage).attributes = [.plain: [.font: UIFont.regular(14), .foregroundColor: UIColor.white],
                                                .emoji: [.font: UIFont.regular(24)],
                                                .bold: [.font: UIFont.medium(20), .foregroundColor: UIColor.white],
                                                .tag: [.font: UIFont.medium(12), .foregroundColor: UIColor.haze()]]
        delegate = self
        (layoutManager as! Layout).padding = 2
        layer.cornerRadius = 8
        layer.borderColor = .haze()
        layer.borderWidth = 0
        width = widthAnchor.constraint(equalToConstant: 0)
        height = heightAnchor.constraint(equalToConstant: 0)
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
            app.window!.endEditing(true)
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.backgroundColor = .haze(0.2)
            }
            kanban.scroll.center(frame)
            app.present(Move(self), animated: true)
        }
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.alpha = 1
        }
        super.touchesEnded(touches, with: with)
    }
    
    func textViewDidChange(_: UITextView) {
        resize()
        kanban.scroll.center(frame)
    }
    
    func textViewDidEndEditing(_: UITextView) {
        guard let column = column?.index else { return }
        isEditable = false
        isSelectable = false
        if text != app.session.content(app.project, list: column, card: index) {
            app.session.content(app.project, list: column, card: index, content: text)
            app.alert(.key("Card"), message: text)
            kanban.tags.refresh()
        }
        update(true)
    }
    
    func edit() {
        isEditable = true
        isSelectable = true
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.layer.borderWidth = 1
            self?.backgroundColor = .clear
        }) { [weak self] _ in
            self?.becomeFirstResponder()
        }
    }
    
    func update(_ animate: Bool) {
        let color: UIColor
        text = app.session.content(app.project, list: column.index, card: index)
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            width.constant = 60
            height.constant = 40
            color = .haze(0.3)
            left.constant = 15
        } else {
            resize()
            color = .clear
            left.constant = 0
        }
        if animate {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.superview?.layoutIfNeeded()
                self?.backgroundColor = color
                self?.layer.borderWidth = 0
            }
        } else {
            backgroundColor = color
            layer.borderWidth = 0
        }
    }
    
    private func resize() {
        textContainer.size.width = 200
        textContainer.size.height = 100_000
        layoutManager.ensureLayout(for: textContainer)
        width.constant = max(ceil(layoutManager.usedRect(for: textContainer).size.width), 30) + 30
        height.constant = max(ceil(layoutManager.usedRect(for: textContainer).size.height), 10) + 30
    }
}
