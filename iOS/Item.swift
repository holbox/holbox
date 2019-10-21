import UIKit

final class Item: UIView {
    let index: Int
    private weak var label: Label!
    private weak var target: AnyObject!
    private let action: Selector
   
    required init?(coder: NSCoder) { nil }
    init(_ title: String, index: Int, _ target: AnyObject, _ action: Selector) {
        self.index = index
        self.action = action
        self.target = target
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = title
        layer.cornerRadius = 8
        
        let label = Label(title, 16, .bold, .white)
        addSubview(label)
        self.label = label
        
        heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with: UIEvent?) {
        backgroundColor = .haze
        label.textColor = .black
        super.touchesBegan(touches, with: with)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with: UIEvent?) {
        backgroundColor = .clear
        label.textColor = .white
        super.touchesCancelled(touches, with: with)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with: UIEvent?) {
        if bounds.contains(touches.first!.location(in: self)) {
            _ = target.perform(action, with: self)
        } else {
            backgroundColor = .clear
            label.textColor = .white
        }
        super.touchesEnded(touches, with: with)
    }
}
