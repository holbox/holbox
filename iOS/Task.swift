import UIKit

final class Task: UIView, UITextViewDelegate {
    var delta = CGFloat()
    private weak var todo: Todo!
    private weak var text: Text!
    private weak var icon: Image!
    private weak var circle: UIView!
    private weak var base: UIView!
    private weak var _swipe: UIView!
    private weak var _delete: UIView!
    private weak var _swipeRight: NSLayoutConstraint!
    private weak var _deleteLeft: NSLayoutConstraint!
    private var highlighted = false { didSet { update() } }
    private var active: Bool { (list == 1 && !highlighted) || (list == 0 && highlighted) }
    private let index: Int
    private let list: Int
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int, list: Int, _ todo: Todo) {
        self.index = index
        self.list = list
        self.todo = todo
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = .button
        
        let content = app.session.content(app.project, list: list, card: index)
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
        _swipe.backgroundColor = list == 0 ? UIColor(named: "haze")! : UIColor(named: "haze")!.withAlphaComponent(0.4)
        addSubview(_swipe)
        self._swipe = _swipe
        
        let trash = Image("trash")
        addSubview(trash)
        
        let circle = UIView()
        circle.isUserInteractionEnabled = false
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.layer.cornerRadius = 13
        addSubview(circle)
        self.circle = circle
        
        let icon = Image("check")
        addSubview(icon)
        self.icon = icon
        
        let text = Text()
        text.isScrollEnabled = false
        text.isUserInteractionEnabled = false
        text.isAccessibilityElement = false
        text.textContainerInset = .init(top: 10, left: 15, bottom: 10, right: 15)
        text.font = .systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 16), weight: .medium)
        if list == 0 {
            (text.textStorage as! Storage).fonts = [
                .plain: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 16), weight: .bold), .white),
                .emoji: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 30), weight: .regular), .white),
                .bold: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 20), weight: .bold), UIColor(named: "haze")!),
                .tag: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 16), weight: .bold), UIColor(named: "haze")!)]
        } else {
            (text.textStorage as! Storage).fonts = [
                .plain: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 16), weight: .bold), UIColor(named: "haze")!.withAlphaComponent(0.7)),
                .emoji: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 30), weight: .regular), UIColor(named: "haze")!.withAlphaComponent(0.7)),
                .bold: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 20), weight: .bold), UIColor(named: "haze")!.withAlphaComponent(0.5)),
                .tag: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 16), weight: .bold), UIColor(named: "haze")!.withAlphaComponent(0.5))]
        }
        text.delegate = self
        (text.layoutManager as! Layout).padding = 2
        text.text = content
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
        
        circle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        circle.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 10).isActive = true
        circle.widthAnchor.constraint(equalToConstant: 26).isActive = true
        circle.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        icon.widthAnchor.constraint(equalToConstant: 14).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 14).isActive = true
        icon.centerXAnchor.constraint(equalTo: circle.centerXAnchor).isActive = true
        icon.centerYAnchor.constraint(equalTo: circle.centerYAnchor).isActive = true
        
        text.topAnchor.constraint(equalTo: base.topAnchor).isActive = true
        text.leftAnchor.constraint(equalTo: circle.rightAnchor).isActive = true
        text.rightAnchor.constraint(equalTo: base.rightAnchor).isActive = true

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
            todo.isUserInteractionEnabled = false
            app.alert(list == 1 ? .key("Todo.restart") : .key("Todo.completed"), message: app.session.content(app.project, list: list, card: index))
            app.session.move(app.project, list: list, card: index, destination: list == 1 ? 0 : 1, index: 0)
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
    
    func delete(_ delta: CGFloat) {
        _deleteLeft.constant = min(0, delta - self.delta)
        if _deleteLeft.constant < -160 {
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
        icon.isHidden = !active
        circle.backgroundColor = active ? UIColor(named: "haze")! : UIColor(named: "haze")!.withAlphaComponent(0.1)
        base.backgroundColor = highlighted ? UIColor(named: "background") : .clear
    }
}
