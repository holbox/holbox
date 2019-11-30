import AppKit

final class Gradient: NSView {
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layer = CAGradientLayer()
        (layer as! CAGradientLayer).startPoint = CGPoint(x: 0.2, y: 0)
        (layer as! CAGradientLayer).endPoint = CGPoint(x: 0, y: 1)
        (layer as! CAGradientLayer).locations = [0, 1]
        (layer as! CAGradientLayer).colors = [NSColor(named: "background")!.cgColor, NSColor.black.cgColor]
        wantsLayer = true
    }
}
