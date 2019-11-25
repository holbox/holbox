import UIKit

final class Button: UIView {
    private(set) weak var icon: Image!
    private weak var target: AnyObject!
    private let action: Selector
    
    required init?(coder: NSCoder) { nil }
    init(_ image: String, target: AnyObject, action: Selector, padding: CGFloat = 0) {
        self.target = target
        self.action = action
        super.init(frame: .zero)

        let icon = Image(image)
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = .button
        addSubview(icon)
        self.icon = icon
        
        icon.leftAnchor.constraint(equalTo: leftAnchor, constant: padding).isActive = true
        icon.rightAnchor.constraint(equalTo: rightAnchor, constant: -padding).isActive = true
        icon.topAnchor.constraint(equalTo: topAnchor, constant: padding).isActive = true
        icon.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding).isActive = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with: UIEvent?) {
        alpha = 0.3
        super.touchesBegan(touches, with: with)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with: UIEvent?) {
        alpha = 1
        super.touchesCancelled(touches, with: with)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with: UIEvent?) {
        alpha = 1
        if bounds.contains(touches.first!.location(in: self)) {
            _ = target.perform(action)
        }
        super.touchesEnded(touches, with: with)
    }
}
