import UIKit

final class Circle: UIView {
    weak var target: AnyObject!
    private let action: Selector
    
    required init?(coder: NSCoder) { nil }
    
    init(_ title: String, _ target: AnyObject, _ action: Selector, _ background: UIColor, _ text: UIColor) {
        self.target = target
        self.action = action
        super.init(frame: .zero)
        configure(background)
        accessibilityLabel = title
        
        let label = Label(title, 14, .bold, text)
        label.isAccessibilityElement = false
        addSubview(label)
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    init(image: String, _ target: AnyObject, _ action: Selector, _ background: UIColor, _ tint: UIColor) {
        self.target = target
        self.action = action
        super.init(frame: .zero)
        configure(background)
        
        let image = Image(image, template: true)
        image.tintColor = tint
        addSubview(image)
        
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
    
    private func configure(_ background: UIColor) {
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = .button
        backgroundColor = background
        layer.cornerRadius = 30
        
        widthAnchor.constraint(equalToConstant: 60).isActive = true
        heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
}
