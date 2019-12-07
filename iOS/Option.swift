import UIKit

class Option: UIView {
    final class Item: Option {
        private let index: Int
        
        required init?(coder: NSCoder) { nil }
        init(_ index: Int, settings: Settings) {
            self.index = index
            super.init(settings, title: .key("Settings.options.\(index)"))
        }
        
        override func click() {
            settings.option(index)
        }
    }

    final class Check: Option {
        var on = false {
            didSet {
                circle.backgroundColor = on ? UIColor(named: "haze")! : .clear
                check.alpha = on ? 1 : 0
                accessibilityValue = "\(on)"
            }
        }
        
        private weak var circle: UIView!
        private weak var check: Image!
        
        required init?(coder: NSCoder) { nil }
        init(_ title: String, settings: Settings) {
            super.init(settings, title: title)
            let circle = UIView()
            circle.translatesAutoresizingMaskIntoConstraints = false
            circle.isUserInteractionEnabled = false
            circle.layer.cornerRadius = 11
            circle.layer.borderWidth = 2
            circle.layer.borderColor = UIColor(named: "haze")!.cgColor
            addSubview(circle)
            self.circle = circle
            
            let check = Image("check")
            addSubview(check)
            self.check = check
            
            circle.widthAnchor.constraint(equalToConstant: 22).isActive = true
            circle.heightAnchor.constraint(equalToConstant: 22).isActive = true
            circle.centerYAnchor.constraint(lessThanOrEqualTo: centerYAnchor).isActive = true
            circle.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
            
            check.widthAnchor.constraint(equalToConstant: 14).isActive = true
            check.heightAnchor.constraint(equalToConstant: 14).isActive = true
            check.centerYAnchor.constraint(lessThanOrEqualTo: circle.centerYAnchor, constant: 1).isActive = true
            check.centerXAnchor.constraint(lessThanOrEqualTo: circle.centerXAnchor).isActive = true
        }
        
        override func click() {
            settings.check(self)
        }
    }
    
    private weak var settings: Settings!
    
    required init?(coder: NSCoder) { nil }
    init(_ settings: Settings, title: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        accessibilityTraits = .button
        isAccessibilityElement = true
        accessibilityLabel = title
        layer.cornerRadius = 4
        self.settings = settings
        
        let label = Label(title, 16, .regular, UIColor(named: "haze")!)
        addSubview(label)
        
        heightAnchor.constraint(equalToConstant: 60).isActive = true
        widthAnchor.constraint(equalToConstant: 270).isActive = true
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with: UIEvent?) {
        UIView.animate(withDuration: 0.35) { [weak self] in
            self?.backgroundColor = UIColor(named: "haze")!.withAlphaComponent(0.3)
        }
        super.touchesBegan(touches, with: with)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with: UIEvent?) {
        UIView.animate(withDuration: 0.35) { [weak self] in
            self?.backgroundColor = .clear
        }
        super.touchesCancelled(touches, with: with)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with: UIEvent?) {
        UIView.animate(withDuration: 0.35) { [weak self] in
            self?.backgroundColor = .clear
        }
        if bounds.contains(touches.first!.location(in: self)) {
            click()
        }
        super.touchesEnded(touches, with: with)
    }
    
    func click() { }
}
