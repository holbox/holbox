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
        textContainerInset = .init(top: 20, left: 20, bottom: 20, right: 20)
        isEditable = false
        isSelectable = false
        accessibilityLabel = .key("Card")
        font = .regular(14)
        (textStorage as! Storage).attributes = [.plain: [.font: UIFont.regular(14), .foregroundColor: UIColor.white],
                                                .emoji: [.font: UIFont.regular(24)],
                                                .bold: [.font: UIFont.bold(20), .foregroundColor: UIColor.white],
                                                .tag: [.font: UIFont.medium(12), .foregroundColor: UIColor.haze()]]
        delegate = self
        (layoutManager as! Layout).padding = 2
        layer.cornerRadius = 8
        layer.borderColor = .clear
        layer.borderWidth = 1
        width = widthAnchor.constraint(equalToConstant: 0)
        height = heightAnchor.constraint(equalToConstant: 0)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with: UIEvent?) {
        UIView.animate(withDuration: 0.35) { [weak self] in
            self?.backgroundColor = .haze(0.2)
        }
        super.touchesBegan(touches, with: with)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with: UIEvent?) {
        UIView.animate(withDuration: 0.35) { [weak self] in
            self?.backgroundColor = .clear
        }
        super.touchesCancelled(touches, with: with)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with: UIEvent?) {
        if app.presentedViewController == nil && bounds.contains(touches.first!.location(in: self)) {
            app.window!.endEditing(true)
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.layer.borderColor = .haze()
                self?.backgroundColor = .haze(0.3)
            }
            kanban.scroll.center(frame)
            app.present(Move(self), animated: true)
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.layer.borderColor = .haze()
            self?.backgroundColor = .clear
        }
    }
    
    func edit() {
        isEditable = true
        isSelectable = true
        becomeFirstResponder()
    }
    
    func update(_ animate: Bool) {
        let color: UIColor
        text = app.session.content(app.project, list: column.index, card: index)
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            width.constant = 60
            height.constant = 60
            color = .haze(0.3)
            left.constant = 20
        } else {
            resize()
            color = .clear
            left.constant = 0
        }
        if animate {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.superview?.layoutIfNeeded()
                self?.backgroundColor = color
                self?.layer.borderColor = .clear
            }
        } else {
            backgroundColor = color
            layer.borderColor = .clear
        }
    }
    
    private func resize() {
        textContainer.size.width = 200
        textContainer.size.height = 100_000
        layoutManager.ensureLayout(for: textContainer)
        width.constant = max(ceil(layoutManager.usedRect(for: textContainer).size.width), 20) + 40
        height.constant = max(ceil(layoutManager.usedRect(for: textContainer).size.height), 20) + 40
    }
}
