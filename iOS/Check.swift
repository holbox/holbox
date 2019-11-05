import UIKit

final class Check: UIView {
    var on = false { didSet { update() } }
    private weak var target: AnyObject!
    private weak var icon: Image!
    private weak var label: Label!
    private weak var circle: UIView!
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
        
        let circle = UIView()
        circle.isUserInteractionEnabled = false
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.layer.cornerRadius = 15
        addSubview(circle)
        self.circle = circle
        
        let label = Label(text, 15, .semibold, .init(white: 1, alpha: 0.7))
        label.isAccessibilityElement = false
        addSubview(label)
        self.label = label
        
        let icon = Image("check")
        addSubview(icon)
        self.icon = icon
        
        heightAnchor.constraint(equalToConstant: 60).isActive = true
        widthAnchor.constraint(equalToConstant: 160).isActive = true
        
        circle.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true
        circle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        circle.widthAnchor.constraint(equalToConstant: 30).isActive = true
        circle.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        icon.widthAnchor.constraint(equalToConstant: 30).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 30).isActive = true
        icon.centerXAnchor.constraint(equalTo: circle.centerXAnchor).isActive = true
        icon.centerYAnchor.constraint(equalTo: circle.centerYAnchor, constant: 1).isActive = true
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        
        update()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with: UIEvent?) {
        alpha = 0.4
        super.touchesBegan(touches, with: with)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with: UIEvent?) {
        alpha = 1
        super.touchesCancelled(touches, with: with)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with: UIEvent?) {
        alpha = 1
        if bounds.contains(touches.first!.location(in: self)) {
            on.toggle()
            _ = target.perform(action, with: self)
        }
        super.touchesEnded(touches, with: with)
    }
    
    private func update() {
        icon.isHidden = !on
        circle.backgroundColor = on ? UIColor(named: "haze")! : .init(white: 0, alpha: 0.3)
    }
}
