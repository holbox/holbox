import UIKit

final class Task: UIView {
    var highlighted = false { didSet { update() } }
    let index: Int
    let list: Int
    private weak var label: Label!
    private weak var icon: Image!
    private weak var todo: Todo!
    private weak var circle: UIView!
    private weak var base: UIView!
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
        base.alpha = 0
        base.layer.cornerRadius = 10
        base.backgroundColor = UIColor(named: "background")!
        addSubview(base)
        self.base = base
        
        let circle = UIView()
        circle.isUserInteractionEnabled = false
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.layer.cornerRadius = 15
        addSubview(circle)
        self.circle = circle
        
        let icon = Image("check")
        addSubview(icon)
        self.icon = icon
        
        let label = Label(content.mark {
            switch $0 {
            case .plain: return (.init(content[$1]), 16, .medium, active ? UIColor(named: "haze")! : .white)
            case .emoji: return (.init(content[$1]), 36, .regular, active ? UIColor(named: "haze")! : .white)
            case .bold: return (.init(content[$1]), 28, .bold, active ? UIColor(named: "haze")! : .white)
            }
        })
        addSubview(label)
        self.label = label
        
        bottomAnchor.constraint(greaterThanOrEqualTo: label.bottomAnchor, constant: 20).isActive = true
        
        base.topAnchor.constraint(equalTo: topAnchor).isActive = true
        base.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        base.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        base.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        circle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        circle.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        circle.widthAnchor.constraint(equalToConstant: 30).isActive = true
        circle.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        icon.widthAnchor.constraint(equalToConstant: 30).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 30).isActive = true
        icon.centerXAnchor.constraint(equalTo: circle.centerXAnchor).isActive = true
        icon.centerYAnchor.constraint(equalTo: circle.centerYAnchor, constant: 1).isActive = true
        
        label.leftAnchor.constraint(equalTo: circle.rightAnchor, constant: 10).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: base.rightAnchor, constant: -20).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true

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
        circle.backgroundColor = active ? UIColor(named: "haze")! : UIColor(named: "haze")!.withAlphaComponent(0.2)
    }
}
