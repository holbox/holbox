import UIKit

final class Button: UIView {
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
        
        let icon = UIImageView(image: UIImage(named: image)!)
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .center
        icon.clipsToBounds = true
        addSubview(icon)
        
        icon.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        icon.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        icon.topAnchor.constraint(equalTo: topAnchor).isActive = true
        icon.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        alpha = 0.3
    }
    
//    override func mouseUp(with: NSEvent) {
//        window!.makeFirstResponder(nil)
//        if bounds.contains(convert(with.locationInWindow, from: nil)) {
//            _ = target.perform(action, with: nil)
//        }
//        alphaValue = 1
//    }
}
