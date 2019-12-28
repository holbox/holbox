import UIKit

final class Circle: UIView {
    weak var target: AnyObject!
    private let action: Selector
    
    required init?(coder: NSCoder) { nil }
    
    init(_ image: String, _ target: AnyObject, _ action: Selector, _ background: UIColor, _ tint: UIColor) {
        self.target = target
        self.action = action
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = .button
        
        let base = UIView()
        base.isUserInteractionEnabled = false
        base.translatesAutoresizingMaskIntoConstraints = false
        base.backgroundColor = background
        base.layer.cornerRadius = 20
        addSubview(base)
        
        let image = Image(image, template: true)
        image.tintColor = tint
        addSubview(image)
        
        widthAnchor.constraint(equalToConstant: 60).isActive = true
        heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        base.widthAnchor.constraint(equalToConstant: 40).isActive = true
        base.heightAnchor.constraint(equalToConstant: 40).isActive = true
        base.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        base.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        image.topAnchor.constraint(equalTo: topAnchor).isActive = true
        image.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        image.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        image.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
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
