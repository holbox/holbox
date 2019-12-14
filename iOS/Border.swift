import UIKit

final class Border: UIView {
    class func vertical(_ alpha: CGFloat = 0.4) -> Border {
        let border = Border(alpha)
        border.widthAnchor.constraint(equalToConstant: 1).isActive = true
        return border
    }
    
    class func horizontal(_ alpha: CGFloat = 0.4) -> Border {
        let border = Border(alpha)
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return border
    }
    
    required init?(coder: NSCoder) { nil }
    private init(_ alpha: CGFloat) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        backgroundColor = UIColor(named: "haze")!.withAlphaComponent(alpha)
    }
}
