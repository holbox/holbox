import AppKit

final class Scroll: NSScrollView {
    var views: [NSView] { documentView!.subviews }
    var top: NSLayoutYAxisAnchor { documentView!.topAnchor }
    var bottom: NSLayoutYAxisAnchor { documentView!.bottomAnchor }
    var left: NSLayoutXAxisAnchor { documentView!.leftAnchor }
    var right: NSLayoutXAxisAnchor { documentView!.rightAnchor }
    var centerX: NSLayoutXAxisAnchor { documentView!.centerXAnchor }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        drawsBackground = false
        hasVerticalScroller = true
        hasHorizontalScroller = true
        verticalScroller!.controlSize = .mini
        horizontalScroller!.controlSize = .mini
        horizontalScrollElasticity = .automatic
        verticalScrollElasticity = .automatic
        documentView = Flipped()
        documentView!.translatesAutoresizingMaskIntoConstraints = false
        documentView!.topAnchor.constraint(equalTo: topAnchor).isActive = true
        documentView!.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
    }
    
    func add(_ view: NSView) { documentView!.addSubview(view) }
}

private final class Flipped: NSView { override var isFlipped: Bool { true } }
