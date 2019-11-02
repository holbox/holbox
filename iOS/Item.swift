import UIKit

final class Item: UIView {
    var selected = false { didSet { update() } }
    var highlighted = false { didSet { update() } }
    let index: Int
    private weak var label: Label!
    private weak var target: AnyObject!
    private let action: Selector
    private let color: UIColor
   
    required init?(coder: NSCoder) { nil }
    init(_ title: String, index: Int, _ font: UIFont.Weight, _ size: CGFloat, _ color: UIColor , _ target: AnyObject, _ action: Selector) {
        self.index = index
        self.action = action
        self.target = target
        self.color = color
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = title
        layer.cornerRadius = 8

        let label = Label(title, size, font, color)
        addSubview(label)
        self.label = label
        
        heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with: UIEvent?) {
        highlighted = true
        super.touchesBegan(touches, with: with)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with: UIEvent?) {
        highlighted = false
        super.touchesCancelled(touches, with: with)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with: UIEvent?) {
        highlighted = false
        if !selected && bounds.contains(touches.first!.location(in: self)) {
            selected = true
            _ = target.perform(action, with: self)
        }
        super.touchesEnded(touches, with: with)
    }
    
    private func update() {
        backgroundColor = selected || highlighted ? UIColor(named: "haze")! : .clear
        label.textColor = selected || highlighted ? .black : color
    }
}
