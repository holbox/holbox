import AppKit

final class Scroll: NSScrollView {
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
    
    func clear() { documentView!.subviews.forEach { $0.removeFromSuperview() } }
}

private final class Flipped: NSView { override var isFlipped: Bool { true } }
