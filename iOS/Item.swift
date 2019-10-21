import UIKit

final class Item: UIView {
    var selected = false { didSet { update() } }
    let index: Int
    private weak var label: Label!
    private weak var target: AnyObject!
    private weak var base: UIView!
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
        
        let base = UIView()
        base.isUserInteractionEnabled = false
        base.translatesAutoresizingMaskIntoConstraints = false
        base.layer.cornerRadius = 8
        addSubview(base)
        self.base = base
        
        let label = Label(title, 16, .bold, .white)
        addSubview(label)
        self.label = label
        
        heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        base.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        base.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        base.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        base.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with: UIEvent?) {
        selected = true
        super.touchesBegan(touches, with: with)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with: UIEvent?) {
        selected = false
        super.touchesCancelled(touches, with: with)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with: UIEvent?) {
        if bounds.contains(touches.first!.location(in: self)) {
            _ = target.perform(action, with: self)
        } else {
            selected = false
        }
        super.touchesEnded(touches, with: with)
    }
    
    private func update() {
        base.backgroundColor = selected ? .haze : .clear
        label.textColor = selected ? .black : .white
    }
}
