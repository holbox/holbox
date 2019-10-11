import AppKit

final class Logo: NSView {
    override var mouseDownCanMoveWindow: Bool { true }
    private weak var rays: CAShapeLayer!
    private var counter = 36
    private var rings = [CAShapeLayer]()
    private let deg5 = CGFloat(0.0872665)
    private let deg2_5 = CGFloat(0.0436332)
    private let timer = DispatchSource.makeTimerSource(queue: .main)
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        
        timer.resume()
        timer.schedule(deadline: .now() + 0.2, repeating: 0.2)
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            if self.counter == 0 {
                self.counter = 36
            } else {
                self.counter -= 1
            }
            self.display()
        }
        
        let rays = CAShapeLayer()
        rays.fillColor = .clear
        rays.strokeColor = .haze
        layer!.addSublayer(rays)
        self.rays = rays
        
        rings = (0 ..< 36).map { _ in
            let ring = CAShapeLayer()
            ring.strokeColor = NSColor.haze.withAlphaComponent(0.05).cgColor
            ring.fillColor = .clear
            layer!.addSublayer(ring)
            return ring
        }
        
        widthAnchor.constraint(equalToConstant: 100).isActive = true
        heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    override func draw(_ rect: NSRect) {
        let side = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        rays.sublayers?.forEach { $0.removeFromSuperlayer() }
        rays.path = {
            $0.addEllipse(in: .init(x: (rect.width - side) / 2, y: (rect.height - side) / 2, width: side, height: side))
            return $0
        } (CGMutablePath())
        rays.lineWidth = side / 25
        
        var radius = side * 0.42
        var width = side / 20
        var prev = deg2_5 / -2
        (0 ..< 36).forEach {
            let ray = CAShapeLayer()
            ray.path = {
                $0.addArc(center: center, radius: radius, startAngle: prev, endAngle: prev + deg2_5, clockwise: false)
                return $0
            } (CGMutablePath())
            prev += deg5 * 2
            ray.lineWidth = width
            if $0 < counter {
                ray.strokeColor = NSColor.haze.withAlphaComponent(0.3).cgColor
            } else {
                ray.strokeColor = .haze
            }
            ray.fillColor = .clear
            rays.addSublayer(ray)
        }
        
        width = side / 5
        radius = side / 0.83
        let offset = side / 5
        let x = (rect.width - radius) / 2
        let y = (rect.height - radius) / 2
        rings.forEach {
            $0.lineWidth = width
            $0.path = {
                $0.addEllipse(in: .init(x: x + (offset * .random(in: -1 ... 1)), y: y + (offset * .random(in: -1 ... 1)), width: radius, height: radius))
                return $0
            } (CGMutablePath())
        }
    }
}
