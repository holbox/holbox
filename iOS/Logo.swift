import UIKit

final class Logo: UIView {
    private weak var rays: CAShapeLayer!
    private var counter = -1
    private let deg5 = CGFloat(0.0872665)
    private let deg2_5 = CGFloat(0.0436332)
    private let timer = DispatchSource.makeTimerSource(queue: .main)
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        isHidden = true
        
        timer.resume()
        timer.schedule(deadline: .distantFuture)
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            if self.counter == 35 {
                self.counter = -1
            } else {
                self.counter += 1
            }
            self.setNeedsDisplay()
        }
        
        let rays = CAShapeLayer()
        rays.fillColor = .clear
        rays.strokeColor = .haze
        layer.addSublayer(rays)
        self.rays = rays
        
        widthAnchor.constraint(equalToConstant: 50).isActive = true
        heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    override func draw(_ rect: CGRect) {
        let side = min(rect.width, rect.height)
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        rays.sublayers?.forEach { $0.removeFromSuperlayer() }
        rays.path = {
            $0.addEllipse(in: .init(x: (rect.width - side) / 2, y: (rect.height - side) / 2, width: side, height: side))
            return $0
        } (CGMutablePath())
        rays.lineWidth = side / 25
        
        let radius = side * 0.39
        let width = side / 12
        var prev = deg2_5 / -2
        (0 ..< 36).forEach {
            let ray = CAShapeLayer()
            ray.path = {
                $0.addArc(center: center, radius: radius, startAngle: prev, endAngle: prev + deg2_5, clockwise: false)
                return $0
            } (CGMutablePath())
            prev += deg5 * 2
            ray.lineWidth = width
            if $0 > counter {
                ray.strokeColor = UIColor.haze.withAlphaComponent(0.2).cgColor
            } else {
                ray.strokeColor = .haze
            }
            ray.fillColor = .clear
            rays.addSublayer(ray)
        }
    }
    
    func start() {
        timer.schedule(deadline: .now() + 0.2, repeating: 0.2)
        isHidden = false
    }
    
    func stop() {
        timer.schedule(deadline: .distantFuture)
        isHidden = true
    }
}
