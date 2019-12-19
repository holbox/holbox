import AppKit

final class Logo: NSView {
    override var mouseDownCanMoveWindow: Bool { false }
    private weak var rays: CAShapeLayer!
    private var counter = 36
    private let deg5 = CGFloat(0.0872665)
    private let deg2_5 = CGFloat(0.0436332)
    private let timer = DispatchSource.makeTimerSource(queue: .main)
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        isHidden = true
        setAccessibilityElement(true)
        setAccessibilityRole(.progressIndicator)
        setAccessibilityLabel(.key("Logo"))
        
        timer.activate()
        timer.schedule(deadline: .distantFuture)
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            if self.counter == 0 {
                self.counter = 36
            } else {
                self.counter -= 1
            }
            self.rays.sublayers!.enumerated().forEach {
                if $0.0 < self.counter {
                    ($0.1 as! CAShapeLayer).strokeColor = .background()
                } else {
                    ($0.1 as! CAShapeLayer).strokeColor = .haze()
                }
            }
        }
        
        let rays = CAShapeLayer()
        rays.fillColor = .clear
        rays.strokeColor = NSColor(named: "haze")!.cgColor
        layer!.addSublayer(rays)
        self.rays = rays
        
        widthAnchor.constraint(equalToConstant: 60).isActive = true
        heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    override func draw(_ rect: NSRect) {
        let side = min(rect.width, rect.height) * 0.95
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        rays.sublayers?.forEach { $0.removeFromSuperlayer() }
        rays.path = {
            $0.addEllipse(in: .init(x: (rect.width - side) / 2, y: (rect.height - side) / 2, width: side, height: side))
            return $0
        } (CGMutablePath())
        rays.lineWidth = side / 25
        
        let radius = side * 0.41
        let width = side / 15
        var prev = deg2_5 / -2
        (0 ..< 36).forEach { _ in
            let ray = CAShapeLayer()
            ray.path = {
                $0.addArc(center: center, radius: radius, startAngle: prev, endAngle: prev + deg2_5, clockwise: false)
                return $0
            } (CGMutablePath())
            prev += deg5 * 2
            ray.lineWidth = width
            ray.fillColor = .clear
            rays.addSublayer(ray)
        }
    }
    
    func start() {
        timer.schedule(deadline: .now() + 0.2, repeating: 0.1)
        isHidden = false
    }
    
    func stop() {
        timer.schedule(deadline: .distantFuture)
        isHidden = true
    }
}
