import UIKit

final class Gradient: UIView {
    override class var layerClass: AnyClass { return CAGradientLayer.self }
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        (layer as! CAGradientLayer).startPoint = CGPoint(x: 0, y: 0)
        (layer as! CAGradientLayer).endPoint = CGPoint(x: 0.2, y: 1)
        (layer as! CAGradientLayer).locations = [0, 1]
        (layer as! CAGradientLayer).colors = [UIColor(named: "background")!.cgColor, UIColor.black.cgColor]
    }
    
    required init?(coder: NSCoder) { return nil }
}
