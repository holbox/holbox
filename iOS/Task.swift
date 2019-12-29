import UIKit

final class Task: UIView, UITextViewDelegate {
    var index = 0
    var list = 0
    private (set) weak var text: Text!
    private weak var _delete: Image!
    private weak var todo: Todo!
    private weak var time: Label!
    private weak var line: UIView!
    private weak var top: NSLayoutConstraint!
    
    weak var _parent: UIView! {
        didSet {
            top?.isActive = false
            top = topAnchor.constraint(equalTo: _parent.bottomAnchor, constant: _parent is Border ? 30 : 0)
            top.isActive = true
        }
    }
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int, list: Int, todo: Todo) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = .key("Task")
        layer.cornerRadius = 6
        layer.borderWidth = 1
        layer.borderColor = .clear
        clipsToBounds = true
        self.index = index
        self.list = list
        self.todo = todo
        
        let text = Text(Storage())
        text.isScrollEnabled = false
        text.isUserInteractionEnabled = false
        text.isAccessibilityElement = false
        text.textContainerInset = .init(top: 15, left: 15, bottom: 15, right: 15)
        text.font = .regular(14)
        (text.textStorage as! Storage).attributes = [.plain: [.font: UIFont.regular(14), .foregroundColor: UIColor.white],
                                                     .emoji: [.font: UIFont.regular(18)],
                                                     .bold: [.font: UIFont.medium(16), .foregroundColor: UIColor.white],
                                                     .tag: [.font: UIFont.medium(12), .foregroundColor: UIColor.haze()]]
        (text.layoutManager as! Layout).owns = true
        (text.layoutManager as! Layout).padding = 2
        text.delegate = self
        text.text = app.session.content(app.project, list: list, card: index)
        addSubview(text)
        self.text = text
        
        let _delete = Image("clear")
        _delete.isAccessibilityElement = true
        _delete.accessibilityTraits = .button
        _delete.accessibilityLabel = .key("Delete")
        addSubview(_delete)
        self._delete = _delete
        
        let line = UIView()
        line.backgroundColor = .haze()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.isUserInteractionEnabled = false
        line.layer.cornerRadius = 1.5
        addSubview(line)
        self.line = line
        
        let time = Label("", .regular(12), .haze())
        time.textAlignment = .right
        addSubview(time)
        self.time = time
        
        bottomAnchor.constraint(equalTo: text.bottomAnchor).isActive = true
        
        text.topAnchor.constraint(equalTo: topAnchor).isActive = true
        text.leftAnchor.constraint(equalTo: time.rightAnchor).isActive = true
        text.rightAnchor.constraint(equalTo: _delete.leftAnchor).isActive = true
        
        _delete.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        _delete.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        _delete.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _delete.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        line.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
        line.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15).isActive = true
        line.rightAnchor.constraint(equalTo: text.leftAnchor).isActive = true
        line.widthAnchor.constraint(equalToConstant: 3).isActive = true
        
        time.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        time.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        time.widthAnchor.constraint(equalToConstant: 60).isActive = true

        update()
        
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(gesture(_:))))
    }
    
    func textViewDidEndEditing(_: UITextView) {
        text.isUserInteractionEnabled = false
        if text.text != app.session.content(app.project, list: list, card: index) {
            app.session.content(app.project, list: list, card: index, content: text.text)
            app.alert(.key("Task"), message: text.text)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with: UIEvent?) {
        layer.borderColor = .haze()
        super.touchesBegan(touches, with: with)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with: UIEvent?) {
        layer.borderColor = .clear
        super.touchesCancelled(touches, with: with)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with: UIEvent?) {
        layer.borderColor = .clear
        if bounds.contains(touches.first!.location(in: self)) {
            if _delete.frame.contains(touches.first!.location(in: self)) {
                app.present(Delete.Task(index, list: list), animated: true)
            } else if !text.isFirstResponder {
                if list == 0 {
                    completed()
                } else {
                    restart()
                }
            }
        }
        super.touchesEnded(touches, with: with)
    }
    
    private func update() {
        time.text = list == 0 ? "" : Date(timeIntervalSince1970: TimeInterval(app.session.content(app.project, list: 2, card: index))!).interval
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.line.alpha = self?.list == 0 ? 1 : 0
        }
    }
    
    private func completed() {
        app.alert(.key("Todo.completed"), message: app.session.content(app.project, list: list, card: index))
        app.session.completed(app.project, index: index)
        let tasks = superview!.subviews.compactMap { $0 as? Task }
        tasks.first { $0._parent === self }?._parent = _parent
        if let child = tasks.first(where: { $0.list == 1 && $0.index == 0 }) {
            _parent = child._parent
            child._parent = self
        } else {
            if let _last = todo._last {
                if _last !== self {
                    _parent =  _last
                }
            }
            todo._last = self
        }
        tasks.forEach {
            if $0.list == 1 {
                $0.index += 1
            } else if $0.index > index {
                $0.index -= 1
            }
        }
        index = 0
        list = 1
        reorder()
        todo.charts()
    }
    
    private func restart() {
        app.alert(.key("Todo.restart"), message: app.session.content(app.project, list: list, card: index))
        app.session.restart(app.project, index: index)
        let tasks = superview!.subviews.compactMap { $0 as? Task }
        if let child = tasks.first(where: { $0.list == 0 && $0.index == 0 }) {
            if let next = tasks.first(where: { $0._parent === self }) {
                next._parent = _parent
            } else {
                todo._last = _parent is Task ? (_parent as! Task) : self
            }
            _parent = todo.border
            child._parent = self
        } else {
            if todo._last === self {
               todo._last = (_parent as? Task) ?? self
            } else {
                tasks.first { $0._parent === self }?._parent = _parent
            }
            _parent = todo.border
            tasks.first(where: { $0.list == 1 && (($0.index == 0 && index > 0) || ($0.index == 1 && index == 0)) })?._parent = self
        }
        tasks.forEach {
            if $0.list == 0 {
                $0.index += 1
            } else if $0.index > index {
                $0.index -= 1
            }
        }
        index = 0
        list = 0
        reorder()
        todo.charts()
    }
    
    private func reorder() {
        update()
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.backgroundColor = .haze(0.3)
            self?.superview!.layoutIfNeeded()
        }) { _ in
            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.backgroundColor = .clear
            }
        }
    }
    
    @objc private func gesture(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            text.isUserInteractionEnabled = true
            text.becomeFirstResponder()
            text.selectedRange = .init(location: 0, length: text.text.utf16.count)
        }
    }
}
