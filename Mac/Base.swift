import AppKit

final class Base: NSView {
    class View: NSView {
        fileprivate weak var top: NSLayoutConstraint! { didSet { top.isActive = true }  }
        
        required init?(coder: NSCoder) { nil }
        init() {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            wantsLayer = true
        }
        
        func refresh() { }
        
        override func mouseDown(with: NSEvent) {
            super.mouseDown(with: with)
            window!.makeFirstResponder(self)
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
        let previous = subviews.first as? View
        addSubview(view)
        window!.makeFirstResponder(view)
        
        view.top = view.topAnchor.constraint(equalTo: topAnchor, constant: -bounds.height)
        view.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        layoutSubtreeIfNeeded()
        
        view.top.constant = 0
        previous?.top.constant = bounds.height
        
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            layoutSubtreeIfNeeded()
        }) {
            previous?.removeFromSuperview()
        }
    }
    
    func clear() {
        subviews.forEach { $0.removeFromSuperview() }
    }
    
    func refresh() {
        (subviews.first as? View)?.refresh()
    }
}
