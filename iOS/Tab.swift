import UIKit

final class Tab: UIView {
    var selected = false { didSet { update() } }
    private weak var icon: UIImageView!
    private weak var target: AnyObject!
    private let action: Selector
    
    required init?(coder: NSCoder) { nil }
    init(_ image: String, target: AnyObject, action: Selector) {
        self.target = target
        self.action = action
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = .button
        layer.cornerRadius = 4
        
        let icon = UIImageView(image: UIImage(named: image)?.withRenderingMode(.alwaysTemplate))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.clipsToBounds = true
        icon.contentMode = .center
        addSubview(icon)
        self.icon = icon
        
        widthAnchor.constraint(equalToConstant: 30).isActive = true
        heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        icon.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        icon.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        icon.topAnchor.constraint(equalTo: topAnchor).isActive = true
        icon.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        update()
    }
    
    override func touchesEnded(_: Set<UITouch>, with: UIEvent?) {
        print("touch")
        with?.tar
        if bounds.contains(convert(with?.allTouches?.first.location, from: nil)) {
            _ = target.perform(action)
        }
    }
    
    private func update() {
        backgroundColor = selected ? .haze : .clear
        icon.tintColor = selected ? .black : .haze
        icon.alpha = selected ? 1 : 0.4
    }
}
