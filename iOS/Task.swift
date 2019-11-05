import UIKit

final class Task: UIView {
    let index: Int
    let list: Int
    private(set) weak var _deleteLeft: NSLayoutConstraint!
    private weak var label: Label!
    private weak var icon: Image!
    private weak var todo: Todo!
    private weak var circle: UIView!
    private weak var base: UIView!
    private weak var _delete: UIView!
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
            case .plain: return (.init(content[$1]), 16, .medium, active ? UIColor(named: "haze")! : .white)
            case .emoji: return (.init(content[$1]), 36, .regular, active ? UIColor(named: "haze")! : .white)
            case .bold: return (.init(content[$1]), 28, .bold, active ? UIColor(named: "haze")! : .white)
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
    
    /*
    override func mouseDown(with: NSEvent) {
        if base.bounds.contains(convert(with.locationInWindow, from: nil)) {
            highlighted = true
        }
        super.mouseDown(with: with)
    }
    
    override func mouseEntered(with: NSEvent) {
        super.mouseEntered(with: with)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            base.alphaValue = 1
            _delete.alphaValue = 1
        }
    }
    
    override func mouseExited(with: NSEvent) {
        super.mouseExited(with: with)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            base.alphaValue = 0
            _delete.alphaValue = 0
        }
    }
    
    override func mouseUp(with: NSEvent) {
        if base.bounds.contains(convert(with.locationInWindow, from: nil)) {
            app.alert(list == 1 ? .key("Todo.restart") : .key("Todo.completed"), message: app.session.content(app.project, list: list, card: index))
            app.session.move(app.project, list: list, card: index, destination: list == 1 ? 0 : 1, index: 0)
            todo.refresh()
        }
        highlighted = false
        super.mouseUp(with: with)
    }*/
    
    private func update() {
        icon.isHidden = !active
        circle.backgroundColor = active ? UIColor(named: "haze")! : UIColor(named: "background")!
    }
}
