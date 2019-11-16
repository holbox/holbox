import UIKit

final class Button: UIView {
    private weak var target: AnyObject!
    private let action: Selector
    
    required init?(coder: NSCoder) { nil }
    init(_ image: String, target: AnyObject, action: Selector) {
        self.target = target
        self.action = action
        super.init(frame: .zero)

        let icon = Image(image)
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = .button
        addSubview(icon)
        
        icon.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        icon.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        icon.topAnchor.constraint(equalTo: topAnchor).isActive = true
        icon.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    @available(iOS 13.0, *) init(_ system: String, _ tint: UIColor, target: AnyObject, action: Selector) {
        self.target = target
        self.action = action
        super.init(frame: .zero)

        let icon = Image(system, tint)
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = .button
        addSubview(icon)
        
        icon.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        icon.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        icon.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
        icon.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15).isActive = true
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
