import UIKit

final class Check: UIView {
    var on = false { didSet { update() } }
    private weak var target: AnyObject!
    private weak var icon: Image!
    private weak var label: Label!
    private weak var base: UIView!
    private let action: Selector
    override var accessibilityValue: String? { get { .init(on) } set { } }
    
    required init?(coder: NSCoder) { nil }
    init(_ text: String, target: AnyObject, action: Selector) {
        self.target = target
        self.action = action
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = .adjustable
        accessibilityLabel = text
        
        let base = UIView()
        base.isUserInteractionEnabled = false
        base.translatesAutoresizingMaskIntoConstraints = false
        base.layer.cornerRadius = 4
        addSubview(base)
        self.base = base
        
        let label = Label(text, 14, .medium, .black)
        label.isAccessibilityElement = false
        addSubview(label)
        self.label = label
        
        let icon = Image("check")
        addSubview(icon)
        self.icon = icon
        
        heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        base.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        base.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        base.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        base.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        icon.widthAnchor.constraint(equalToConstant: 30).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 30).isActive = true
        icon.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true
        icon.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 1).isActive = true
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: icon.leftAnchor, constant: -10).isActive = true
        
        update()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with: UIEvent?) {
        if bounds.contains(touches.first!.location(in: self)) {
            on.toggle()
            _ = target.perform(action, with: self)
        }
        super.touchesEnded(touches, with: with)
    }
    
    private func update() {
        icon.isHidden = !on
        label.textColor = on ? .black : .init(white: 1, alpha: 0.6)
        base.backgroundColor = on ? .haze : .init(white: 1, alpha: 0.05)
    }
}
