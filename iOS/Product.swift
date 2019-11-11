import UIKit

final class Product: UIView {
    let index: Int
    private weak var shopping: Shopping?
    private weak var label: Label!
    private var active = true
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int, _ shopping: Shopping) {
        self.index = index
        self.shopping = shopping
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = .button
        layer.cornerRadius = 20
        
        active = !app.session.contains(app.project, reference: index)
        let product = app.session.product(app.project, index: index)
        accessibilityLabel = product.1
        
        let emoji = Label(product.0, 25, .regular, .white)
        emoji.isAccessibilityElement = false
        addSubview(emoji)
        
        let label = Label(product.1, 11, .light, active ? .white : UIColor(named: "haze")!)
        label.isAccessibilityElement = false
        label.numberOfLines = 2
        addSubview(label)
        self.label = label
        
        heightAnchor.constraint(equalToConstant: 80).isActive = true
        widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        emoji.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
        emoji.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        
        label.topAnchor.constraint(equalTo: emoji.bottomAnchor, constant: 5).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -15).isActive = true
        
        if !active {
            backgroundColor = UIColor(named: "background")!.withAlphaComponent(0.6)
            alpha = 0.7
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with: UIEvent?) {
        if active {
            backgroundColor = UIColor(named: "haze")!
            label.textColor = .black
        }
        super.touchesBegan(touches, with: with)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with: UIEvent?) {
        if active {
            backgroundColor = .clear
            label.textColor = UIColor(named: "haze")!
        }
        super.touchesCancelled(touches, with: with)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with: UIEvent?) {
        if active {
            if bounds.contains(touches.first!.location(in: self)) {
                active = false
                shopping?.isUserInteractionEnabled = false
                let product = app.session.product(app.project, index: index)
                app.alert(.key("Shopping.add"), message: product.0 + " " + product.1)
                app.session.add(app.project, reference: index)
                shopping?.refresh()
                shopping?.groceryLast()
            }
            backgroundColor = .clear
            label.textColor = UIColor(named: "haze")!
        }
        super.touchesEnded(touches, with: with)
    }
}
