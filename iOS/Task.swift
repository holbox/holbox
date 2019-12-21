import UIKit

final class Task: UIView, UITextViewDelegate {
    var delta = CGFloat()
    let index: Int
    let list: Int
    private(set) weak var text: Text!
    private weak var todo: Todo!
    private weak var base: UIView!
    private weak var _swipe: UIView!
    private weak var _delete: UIView!
    private weak var _swipeRight: NSLayoutConstraint!
    private weak var _deleteLeft: NSLayoutConstraint!
    private var highlighted = false { didSet { update() } }
    private var active: Bool { (list == 1 && !highlighted) || (list == 0 && highlighted) }
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int, list: Int, _ todo: Todo) {
        self.index = index
        self.list = list
        self.todo = todo
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = .button
        
        let base = UIView()
        base.isUserInteractionEnabled = false
        base.translatesAutoresizingMaskIntoConstraints = false
        addSubview(base)
        self.base = base
        
        let _delete = UIView()
        _delete.isUserInteractionEnabled = false
        _delete.translatesAutoresizingMaskIntoConstraints = false
        _delete.layer.cornerRadius = 8
        _delete.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        _delete.backgroundColor = .haze(0.2)
        addSubview(_delete)
        self._delete = _delete
        
        let _swipe = UIView()
        _swipe.isUserInteractionEnabled = false
        _swipe.translatesAutoresizingMaskIntoConstraints = false
        _swipe.alpha = 0
        _swipe.backgroundColor = list == 0 ? .haze() : .haze(0.4)
        addSubview(_swipe)
        self._swipe = _swipe
        
        let trash = Image("trash")
        addSubview(trash)
        
        let text = Text(Storage())
        text.isScrollEnabled = false
        text.isUserInteractionEnabled = false
        text.isAccessibilityElement = false
        text.textContainerInset = .init(top: 10, left: 15, bottom: 10, right: 15)
        text.font = .regular(14)
        (text.textStorage as! Storage).attributes = [.plain: [.font: UIFont.regular(14), .foregroundColor: UIColor.white],
                                                     .emoji: [.font: UIFont.regular(20)],
                                                     .bold: [.font: UIFont.medium(18), .foregroundColor: UIColor.white],
                                                     .tag: [.font: UIFont.medium(12), .foregroundColor: UIColor.haze()]]
        (text.layoutManager as! Layout).owns = true
        (text.layoutManager as! Layout).padding = 2
        text.delegate = self
        text.text = app.session.content(app.project, list: list, card: index)
        addSubview(text)
        self.text = text
        
        bottomAnchor.constraint(greaterThanOrEqualTo: text.bottomAnchor).isActive = true
        heightAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
        
        let height = heightAnchor.constraint(equalToConstant: 0)
        height.priority = .defaultLow
        height.isActive = true
        
        base.topAnchor.constraint(equalTo: topAnchor).isActive = true
        base.rightAnchor.constraint(equalTo: _delete.leftAnchor).isActive = true
        base.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        base.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        
        _delete.topAnchor.constraint(equalTo: topAnchor).isActive = true
        _delete.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        _delete.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        _deleteLeft = _delete.leftAnchor.constraint(equalTo: rightAnchor)
        _deleteLeft.isActive = true
        
        _swipe.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        _swipe.topAnchor.constraint(equalTo: topAnchor).isActive = true
        _swipe.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        _swipeRight = _swipe.rightAnchor.constraint(equalTo: leftAnchor)
        _swipeRight.isActive = true
        
        trash.centerYAnchor.constraint(equalTo: _delete.centerYAnchor).isActive = true
        trash.leftAnchor.constraint(equalTo: _delete.leftAnchor, constant: 20).isActive = true
        
        text.topAnchor.constraint(equalTo: base.topAnchor).isActive = true
        text.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 20).isActive = true
        text.rightAnchor.constraint(equalTo: base.rightAnchor).isActive = true

        update()
        
        if list == 1 {
            backgroundColor = .haze(0.3)
        }
        
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(gesture(_:))))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with: UIEvent?) {
        highlighted = true
        super.touchesBegan(touches, with: with)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with: UIEvent?) {
        highlighted = false
        super.touchesCancelled(touches, with: with)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with: UIEvent?) {
        highlighted = false
        if bounds.contains(touches.first!.location(in: self)) {
            todo.isUserInteractionEnabled = false
            app.alert(list == 1 ? .key("Todo.restart") : .key("Todo.completed"), message: app.session.content(app.project, list: list, card: index))
            if list == 0 {
                app.session.completed(app.project, index: index)
            } else {
                app.session.restart(app.project, index: index)
            }
            
            _swipeRight.constant = app.main.bounds.width
            UIView.animate(withDuration: 0.35, animations: { [weak self] in
                self?.layoutIfNeeded()
                self?._swipe.alpha = 0.7
            }) { [weak self] _ in
                self?.todo?.refresh()
            }
        }
        super.touchesEnded(touches, with: with)
    }
    
    func textViewDidEndEditing(_: UITextView) {
        text.isUserInteractionEnabled = false
        if text.text != app.session.content(app.project, list: list, card: index) {
            app.session.content(app.project, list: list, card: index, content: text.text)
            app.alert(.key("Task"), message: text.text)
        }
    }
    
    func delete(_ delta: CGFloat) {
        _deleteLeft.constant = min(0, delta - self.delta)
        if _deleteLeft.constant < -120 {
            app.present(Delete.Card(index, list: list), animated: true) { [weak self] in
                self?.undelete()
            }
        } else {
            UIView.animate(withDuration: 0.35) { [weak self] in
                self?.layoutIfNeeded()
            }
        }
    }
    
    func undelete() {
        if isUserInteractionEnabled {
            delta = 0
            _deleteLeft.constant = 0
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.layoutIfNeeded()
            }
        }
    }
    
    private func update() {
        base.backgroundColor = highlighted ? .haze(0.2) : .clear
    }
    
    @objc private func gesture(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            text.isUserInteractionEnabled = true
            text.becomeFirstResponder()
            text.selectedRange = .init(location: 0, length: text.text.utf16.count)
        }
    }
}
