import UIKit

final class Tag: UIView {
    private let name: String
    
    required init?(coder: NSCoder) { nil }
    init(_ name: String, count: Int) {
        self.name = name
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = .button
        
        let label = Label([("\(count)", 13, .medium, UIColor(named: "haze")!),
                           (" #" + name, 14, .bold, UIColor(named: "haze")!)])
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        accessibilityLabel = label.text
        addSubview(label)
        
        heightAnchor.constraint(equalToConstant: 34).isActive = true
        rightAnchor.constraint(equalTo: label.rightAnchor, constant: 10).isActive = true
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
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
            app.main.bar.find.search("#"+name)
        }
        super.touchesEnded(touches, with: with)
    }
}
