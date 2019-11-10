import UIKit

final class Grocery: UIView {
    private weak var shopping: Shopping?
    private weak var emoji: Label!
    private weak var label: Label!
    private let index: Int
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int, _ shopping: Shopping) {
        self.index = index
        self.shopping = shopping
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = .button
        
        let product = app.session.reference(app.project, index: index)
        accessibilityLabel = product.1
        
        let emoji = Label(product.0, 50, .regular, .white)
        emoji.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        emoji.isAccessibilityElement = false
        addSubview(emoji)
        self.emoji = emoji
        
        let label = Label(product.1, 16, .semibold, UIColor(named: "haze")!)
        label.isAccessibilityElement = false
        label.numberOfLines = 3
        addSubview(label)
        self.label = label
        
        heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        emoji.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        emoji.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        
        label.leftAnchor.constraint(equalTo: emoji.rightAnchor, constant: 15).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 350).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor, constant: 25).isActive = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with: UIEvent?) {
        backgroundColor = UIColor(named: "background")!
        super.touchesBegan(touches, with: with)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with: UIEvent?) {
        backgroundColor = .clear
        super.touchesCancelled(touches, with: with)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with: UIEvent?) {
        backgroundColor = .clear
        if bounds.contains(touches.first!.location(in: self)) {
            shopping?.isUserInteractionEnabled = false
            let product = app.session.reference(app.project, index: index)
            app.alert(.key("Shopping.got"), message: product.0 + " " + product.1)
            app.session.delete(app.project, list: 1, card: index)
            shopping?.refresh()
        }
        super.touchesEnded(touches, with: with)
    }
}
