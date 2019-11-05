import UIKit

final class Tab: UIView {
    var selected = false { didSet { update() } }
    private weak var icon: Image!
    private weak var target: AnyObject!
    private weak var base: UIView!
    private let action: Selector
    
    required init?(coder: NSCoder) { nil }
    init(_ image: String, target: AnyObject, action: Selector) {
        self.target = target
        self.action = action
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = .button
        
        let base = UIView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.isUserInteractionEnabled = false
        base.layer.cornerRadius = 4
        addSubview(base)
        self.base = base
        
        let icon = Image(image, template: true)
        addSubview(icon)
        self.icon = icon
        
        widthAnchor.constraint(equalToConstant: 65).isActive = true
        heightAnchor.constraint(equalToConstant: 65).isActive = true
        
        base.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        base.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        base.widthAnchor.constraint(equalToConstant: 30).isActive = true
        base.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        icon.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        icon.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        icon.topAnchor.constraint(equalTo: topAnchor).isActive = true
        icon.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        update()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with: UIEvent?) {
        if !selected && bounds.contains(touches.first!.location(in: self)) {
            _ = target.perform(action)
        }
        super.touchesEnded(touches, with: with)
    }
    
    private func update() {
        base.backgroundColor = selected ? UIColor(named: "haze")! : .clear
        icon.tintColor = selected ? .black : UIColor(named: "haze")!
        icon.alpha = selected ? 1 : 0.7
    }
}
