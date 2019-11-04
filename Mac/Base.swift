import AppKit

final class Base: NSView {
    class View: NSView {
        required init?(coder: NSCoder) { nil }
        init() {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            wantsLayer = true
            alphaValue = 0
        }
        
        func refresh() { }
        
        override func mouseDown(with: NSEvent) {
            super.mouseDown(with: with)
            window!.makeFirstResponder(nil)
        }
        
        @objc final func more() {
            app.runModal(for: More.Project())
        }
    }
    
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func show(_ view: View) {
        subviews.forEach { $0.removeFromSuperview() }
        addSubview(view)
        
        view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        window!.makeFirstResponder(view)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.4
            $0.allowsImplicitAnimation = true
            view.alphaValue = 1
        }
    }
    
    func refresh() {
        (subviews.first as? View)?.refresh()
    }
}
