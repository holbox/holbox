import UIKit

final class Task: UIView {
    var delta = CGFloat()
    let index: Int
    let list: Int
    private weak var label: Label!
    private weak var icon: Image!
    private weak var todo: Todo!
    private weak var circle: UIView!
    private weak var base: UIView!
    private weak var _swipe: UIView!
    private weak var _delete: UIView!
    private weak var _swipeRight: NSLayoutConstraint!
    private weak var _deleteLeft: NSLayoutConstraint!
    private var highlighted = false { didSet { update() } }
    private var active: Bool { (list == 1 && !highlighted) || (list == 0 && highlighted) }
    
    required init?(coder: NSCoder) { nil }
    init(_ content: String, index: Int, list: Int, _ todo: Todo) {
        self.index = index
        self.list = list
        self.todo = todo
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = content
        
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
        _delete.backgroundColor = UIColor(named: "background")!
        addSubview(_delete)
        self._delete = _delete
        
        let _swipe = UIView()
        _swipe.isUserInteractionEnabled = false
        _swipe.translatesAutoresizingMaskIntoConstraints = false
        _swipe.alpha = 0
        _swipe.layer.cornerRadius = 8
        _swipe.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        _swipe.backgroundColor = list == 0 ? UIColor(named: "haze")! : UIColor(named: "background")!
        addSubview(_swipe)
        self._swipe = _swipe
        
        let _deleteTitle = Label(.key("Todo.delete"), 14, .bold, UIColor(named: "haze")!)
        _delete.addSubview(_deleteTitle)
        
        let circle = UIView()
        circle.isUserInteractionEnabled = false
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.layer.cornerRadius = 15
        base.addSubview(circle)
        self.circle = circle
        
        let icon = Image("check")
        base.addSubview(icon)
        self.icon = icon
        
        let label = Label(content.mark {
            switch $0 {
            case .plain: return (.init(content[$1]), 16, .medium, list == 1 ? UIColor(named: "haze")! : .white)
            case .emoji: return (.init(content[$1]), 36, .regular, list == 1 ? UIColor(named: "haze")! : .white)
            case .bold: return (.init(content[$1]), 28, .bold, list == 1 ? UIColor(named: "haze")! : .white)
            }
        })
        base.addSubview(label)
        self.label = label
        
        heightAnchor.constraint(greaterThanOrEqualTo: label.heightAnchor, constant: 2).isActive = true
        heightAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
        
        let height = heightAnchor.constraint(equalToConstant: 0)
        height.priority = .defaultLow
        height.isActive = true
        
        base.topAnchor.constraint(equalTo: topAnchor).isActive = true
        base.rightAnchor.constraint(equalTo: _delete.leftAnchor).isActive = true
        base.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        base.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
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
        
        _deleteTitle.centerYAnchor.constraint(equalTo: _delete.centerYAnchor).isActive = true
        _deleteTitle.leftAnchor.constraint(equalTo: _delete.leftAnchor, constant: 20).isActive = true
        
        circle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        circle.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 20).isActive = true
        circle.widthAnchor.constraint(equalToConstant: 30).isActive = true
        circle.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        icon.widthAnchor.constraint(equalToConstant: 30).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 30).isActive = true
        icon.centerXAnchor.constraint(equalTo: circle.centerXAnchor).isActive = true
        icon.centerYAnchor.constraint(equalTo: circle.centerYAnchor, constant: 1).isActive = true
        
        label.leftAnchor.constraint(equalTo: circle.rightAnchor, constant: 10).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: base.rightAnchor, constant: -20).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 450).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        update()
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
            app.alert(list == 1 ? .key("Todo.restart") : .key("Todo.completed"), message: app.session.content(app.project, list: list, card: index))
            app.session.move(app.project, list: list, card: index, destination: list == 1 ? 0 : 1, index: 0)
            _swipeRight.constant = bounds.width + 20
            UIView.animate(withDuration: 0.4, animations: { [weak self] in
                self?.layoutIfNeeded()
                self?._swipe.alpha = 0.9
            }) { [weak self] _ in self?.todo.refresh() }
        }
        super.touchesEnded(touches, with: with)
    }
    
    func delete(_ delta: CGFloat) {
        _deleteLeft.constant = min(0, delta - self.delta)
        if _deleteLeft.constant < -100 {
            isUserInteractionEnabled = false
            let alert = UIAlertController(title: .key("Delete.title.card.\(app.mode.rawValue)"), message: app.session.content(app.project, list: list, card: index), preferredStyle: .actionSheet)
            alert.addAction(.init(title: .key("Delete.confirm"), style: .destructive) { [weak self] _ in
                self?._deleteLeft.constant = -app.main.bounds.width - 100
                UIView.animate(withDuration: 0.4, animations: { [weak self] in
                    self?.layoutIfNeeded()
                    self?.alpha = 0.4
                }) { [weak self] _ in self?.confirm() }
            })
            alert.addAction(.init(title: .key("Delete.cancel"), style: .cancel) { [weak self] _ in
                self?.isUserInteractionEnabled = true
                self?.undelete()
            })
            alert.popoverPresentationController?.sourceView = self
            app.present(alert, animated: true)
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
            UIView.animate(withDuration: 0.35) { [weak self] in
                self?.layoutIfNeeded()
            }
        }
    }
    
    private func update() {
        icon.isHidden = !active
        circle.backgroundColor = active ? UIColor(named: "haze")! : UIColor(named: "background")!
    }
    
    private func confirm() {
        app.alert(.key("Delete.deleted.card.\(app.mode.rawValue)"), message: app.session.content(app.project, list: list, card: index))
        app.session.delete(app.project, list: list, card: index)
        todo.refresh()
    }
}
