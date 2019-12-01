import UIKit

final class Move: UIViewController {
    private weak var card: Card?
    private weak var kanban: Kanban?
    private weak var _done: NSLayoutConstraint!
    private var _left: (Button, NSLayoutConstraint)!
    private var _right: (Button, NSLayoutConstraint)!
    private var _up: (Button, NSLayoutConstraint)!
    private var _down: (Button, NSLayoutConstraint)!
    
    required init?(coder: NSCoder) { nil }
    init(_ card: Card, kanban: Kanban) {
        super.init(nibName: nil, bundle: nil)
        self.card = card
        self.kanban = kanban
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .init(white: 0, alpha: 0.7)
        
        let _up = Button("arrow", target: self, action: #selector(up))
        
        let _down = Button("arrow", target: self, action: #selector(down))
        _down.icon.transform = .init(rotationAngle: .pi)
        
        let _left = Button("arrow", target: self, action: #selector(left))
        _left.icon.transform = .init(rotationAngle: .pi / -2)
        
        let _right = Button("arrow", target: self, action: #selector(right))
        _right.icon.transform = .init(rotationAngle: .pi / 2)
        
        let _done = Control(.key("Move.done"), self, #selector(close), .clear, UIColor(named: "haze")!)
        _done.base.layer.borderWidth = 1
        _done.base.layer.borderColor = UIColor(named: "haze")!.cgColor
        view.addSubview(_done)
        
        let _delete = Control(.key("Move.delete"), self, #selector(close), UIColor(named: "background")!, UIColor(named: "haze")!)
        _delete.base.layer.borderWidth = 1
        _delete.base.layer.borderColor = UIColor(named: "haze")!.cgColor
        view.addSubview(_delete)
        
        let _edit = Control(.key("Move.edit"), self, #selector(close), UIColor(named: "haze")!, .black)
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
        _edit.widthAnchor.constraint(equalToConstant: 120).isActive = true
        _edit.bottomAnchor.constraint(equalTo: _delete.topAnchor).isActive = true
        _edit.topAnchor.constraint(greaterThanOrEqualTo: _down.bottomAnchor).isActive = true
        
        _delete.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        _delete.widthAnchor.constraint(equalToConstant: 120).isActive = true
        _delete.bottomAnchor.constraint(equalTo: _done.topAnchor).isActive = true
        
        _done.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        _done.widthAnchor.constraint(equalToConstant: 120).isActive = true
        self._done = _done.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 250)
        self._done.isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.layoutIfNeeded()
        _up.1.constant = -40
        _down.1.constant = 40
        _left.1.constant = -40
        _right.1.constant = 40
        UIView.animate(withDuration: 0.4) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _done.constant = -100
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _up.1.constant = -40
        _down.1.constant = 40
        _left.1.constant = -40
        _right.1.constant = 40
        _done.constant = 250
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.card?.backgroundColor = .clear
            self?.view.layoutIfNeeded()
        }
    }
    
    private func translate() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.card?.superview!.layoutIfNeeded()
        }
    }
    
    private func update() {
        
    }
    
    @objc private func up() {
        
    }
    
    @objc private func down() {
        card!.index += 1
        let constant = card!.child!.top.constant
        card!.child!.top = card!.child!.topAnchor.constraint(equalTo: (card!.top.secondItem as! UIView).bottomAnchor, constant: card!.top.constant)
        card!.top = card!.topAnchor.constraint(equalTo: card!.child!.bottomAnchor, constant: constant)
        if let grandchild = card!.child!.child {
            grandchild.top = grandchild.topAnchor.constraint(equalTo: card!.bottomAnchor, constant: constant)
        }
        card!.superview!.subviews.compactMap { $0 as? Card }.first { $0.child === card }?.child = card!.child
        card!.child = card!.child!.child
        translate()
    }
    
    @objc private func right() {
        
    }
    
    @objc private func left() {
        
    }
    
    @objc private func close() {
        presentingViewController!.dismiss(animated: true)
    }
}
