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
        accessibilityLabel = "\(count) #" + name
        
        let base = UIView()
        base.isUserInteractionEnabled = false
        base.translatesAutoresizingMaskIntoConstraints = false
        base.backgroundColor = UIColor(named: "haze")!
        base.layer.cornerRadius = 4
        addSubview(base)
        
        let label = Label("#" + name, 14, .bold, .black)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.isAccessibilityElement = false
        addSubview(label)
        
        let _count = Label("\(count)", 14, .medium, UIColor(named: "haze")!)
        _count.isAccessibilityElement = false
        _count.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        addSubview(_count)
        
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        rightAnchor.constraint(equalTo: _count.rightAnchor, constant: 10).isActive = true
        
        base.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        base.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        base.heightAnchor.constraint(equalToConstant: 32).isActive = true
        base.rightAnchor.constraint(equalTo: label.rightAnchor, constant: 10).isActive = true
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 10).isActive = true
        
        _count.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        _count.leftAnchor.constraint(equalTo: base.rightAnchor, constant: 5).isActive = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with: UIEvent?) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.alpha = 0.3
        }
        super.touchesBegan(touches, with: with)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with: UIEvent?) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.alpha = 1
        }
        super.touchesCancelled(touches, with: with)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with: UIEvent?) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.alpha = 1
        }
        if bounds.contains(touches.first!.location(in: self)) {
            app.main.bar.find.search("#"+name)
        }
        super.touchesEnded(touches, with: with)
    }
}
