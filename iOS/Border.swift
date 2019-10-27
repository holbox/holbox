import UIKit

final class Border: UIView {
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        backgroundColor = UIColor(named: "background")!
        
        heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
}
