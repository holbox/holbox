import UIKit

final class Move: UIViewController {
    private weak var card: Card!
    private weak var _done: NSLayoutConstraint!
    private var _left: (Button, NSLayoutConstraint)!
    private var _right: (Button, NSLayoutConstraint)!
    private var _up: (Button, NSLayoutConstraint)!
    private var _down: (Button, NSLayoutConstraint)!
    
    required init?(coder: NSCoder) { nil }
    init(_ card: Card) {
        super.init(nibName: nil, bundle: nil)
        self.card = card
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .init(white: 0, alpha: 0.75)
        
        let _up = Button("arrow", target: self, action: #selector(up))
        
        let _down = Button("arrow", target: self, action: #selector(down))
        _down.icon.transform = .init(rotationAngle: .pi)
        
        let _left = Button("arrow", target: self, action: #selector(left))
        _left.icon.transform = .init(rotationAngle: .pi / -2)
        
        let _right = Button("arrow", target: self, action: #selector(right))
        _right.icon.transform = .init(rotationAngle: .pi / 2)
        
        let _done = Circle("check", self, #selector(close), .haze(), .black)
        _done.accessibilityLabel = .key("Move.done")
        view.addSubview(_done)
        
        let _delete = Circle("trash", self, #selector(remove), .haze(), .black)
        _delete.accessibilityLabel = .key("Move.delete")
        view.addSubview(_delete)
        
        let _edit = Circle("write", self, #selector(edit), .haze(), .black)
        _edit.accessibilityLabel = .key("Move.edit")
        view.addSubview(_edit)
        
        [_right, _left, _down, _up].forEach {
            view.addSubview($0)
            $0.widthAnchor.constraint(equalToConstant: 60).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 60).isActive = true
        }
        
        _up.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self._up = (_up, _up.centerYAnchor.constraint(equalTo: view.centerYAnchor))
        self._up.1.isActive = true
        
        _down.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self._down = (_down, _down.centerYAnchor.constraint(equalTo: view.centerYAnchor))
        self._down.1.isActive = true
        
        _left.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        self._left = (_left, _left.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        self._left.1.isActive = true
        
        _right.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        self._right = (_right, _right.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        self._right.1.isActive = true
        
        _edit.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        _edit.centerYAnchor.constraint(equalTo: _done.centerYAnchor).isActive = true
        
        _delete.rightAnchor.constraint(equalTo: view.centerXAnchor, constant: -60).isActive = true
        _delete.centerYAnchor.constraint(equalTo: _done.centerYAnchor).isActive = true
        
        _done.leftAnchor.constraint(equalTo: view.centerXAnchor, constant: 60).isActive = true
        self._done = _done.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 200)
        self._done.isActive = true
        update()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.layoutIfNeeded()
        _up.1.constant = -40
        _down.1.constant = 40
        _left.1.constant = -40
        _right.1.constant = 40
        _done.constant = -80
        UIView.animate(withDuration: 0.35) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _up.1.constant = 0
        _down.1.constant = 0
        _left.1.constant = 0
        _right.1.constant = 0
        _done.constant = 200
        card?.update(true)
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    private func translate() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.card.superview!.layoutIfNeeded()
        }) { [weak self] _ in
            guard let self = self else { return }
            self.card.kanban?.scroll.center(self.card.frame)
            self.card.kanban?.charts()
        }
    }
    
    private func update() {
        if card.index > 0 {
            _up.0.isUserInteractionEnabled = true
            _up.0.alpha = 1
        } else {
            _up.0.isUserInteractionEnabled = false
            _up.0.alpha = 0.4
        }
        
        if card.index < app.session.cards(app.project, list: card.column.index) - 1 {
            _down.0.isUserInteractionEnabled = true
            _down.0.alpha = 1
        } else {
            _down.0.isUserInteractionEnabled = false
            _down.0.alpha = 0.4
        }
        
        if card.column.index > 0 {
            _left.0.isUserInteractionEnabled = true
            _left.0.alpha = 1
        } else {
            _left.0.isUserInteractionEnabled = false
            _left.0.alpha = 0.4
        }
        
        if card.column.index < app.session.lists(app.project) - 1 {
            _right.0.isUserInteractionEnabled = true
            _right.0.alpha = 1
        } else {
            _right.0.isUserInteractionEnabled = false
            _right.0.alpha = 0.4
        }
    }
    
    private func sideways(_ delta: Int) {
        let column = card.superview!.subviews.compactMap { $0 as? Column }.first { $0.index == card.column.index + delta }!
        let index = min(card.index, app.session.cards(app.project, list: column.index))
        app.session.move(app.project, list: card.column.index, card: card.index, destination: column.index, index: index)
        card.superview!.subviews.compactMap { $0 as? Card }.filter { $0.column === card.column && $0.index > card.index }.forEach {
            $0.index -= 1
        }
        card.index = index
        card.child?.top = card.child?.topAnchor.constraint(equalTo: (card.top.secondItem as! UIView).bottomAnchor, constant: 10)
        card.superview!.subviews.compactMap { $0 as? Card }.first { $0.child === card }?.child = card.child
        
        if index == 0 {
            if column.index == 0 {
                card.top = card.topAnchor.constraint(equalTo: card.kanban._add.bottomAnchor, constant: 10)
            } else {
                card.top = card.topAnchor.constraint(equalTo: column.bottomAnchor, constant: 10)
            }
        } else {
            card.superview!.subviews.compactMap { $0 as? Card }.first { $0.column === column && $0.index == index - 1 }!.child = card
        }
        
        card.child = card.superview!.subviews.compactMap { $0 as? Card }.first { $0.column === column && $0.index == index }
        card.superview!.subviews.compactMap { $0 as? Card }.filter { $0.column === column && $0.index >= index }.forEach {
            $0.index += 1
        }
        
        card.column = column
        translate()
        update()
    }
    
    @objc private func up() {
        app.session.move(app.project, list: card.column.index, card: card.index, destination: card.column.index, index: card.index - 1)
        card.index -= 1
        let parent = card.superview!.subviews.compactMap { $0 as? Card }.first { $0.child === card }!
        parent.index += 1
        card.top = card.topAnchor.constraint(equalTo: (parent.top.secondItem as! UIView).bottomAnchor, constant: 10)
        card.superview!.subviews.compactMap { $0 as? Card }.first { $0.child === parent }?.child = card
        parent.child = card.child
        card.child = parent
        translate()
        update()
    }
    
    @objc private func down() {
        app.session.move(app.project, list: card.column.index, card: card.index, destination: card.column.index, index: card.index + 1)
        card.index += 1
        let child = card.child!
        child.index -= 1
        child.top = child.topAnchor.constraint(equalTo: (card.top.secondItem as! UIView).bottomAnchor, constant: 10)
        card.superview!.subviews.compactMap { $0 as? Card }.first { $0.child === card }?.child = child
        card.child = child.child
        child.child = card
        translate()
        update()
    }
    
    @objc private func right() {
        sideways(1)
    }
    
    @objc private func left() {
        sideways(-1)
    }
    
    @objc private func close() {
        presentingViewController!.dismiss(animated: true)
    }
    
    @objc private func remove() {
        if app.session.content(app.project, list: card.column.index, card: card.index).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            app.session.delete(app.project, list: card.column.index, card: card.index)
            card.kanban.refresh()
            close()
        } else {
            presentingViewController!.dismiss(animated: true)
            app.present(Delete.Card(card.index, list: card.column.index), animated: true)
        }
    }
    
    @objc private func edit() {
        presentingViewController!.dismiss(animated: true)
        card.edit()
    }
}
