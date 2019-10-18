import UIKit

final class Button: UIView {
    private weak var target: AnyObject!
    private let action: Selector
    
    required init?(coder: NSCoder) { nil }
    init(_ image: String, target: AnyObject, action: Selector) {
        self.target = target
        self.action = action
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = .button
        
        let icon = Image(image)
        addSubview(icon)
        
        icon.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        icon.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        icon.topAnchor.constraint(equalTo: topAnchor).isActive = true
        icon.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
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
        if bounds.contains(touches.first!.location(in: self)) {
            _ = target.perform(action)
        }
        alpha = 1
        super.touchesEnded(touches, with: with)
    }
}
