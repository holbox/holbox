import UIKit

final class Border: UIView {
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        backgroundColor = UIColor(named: "haze")!.withAlphaComponent(0.4)
        
        heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
}
