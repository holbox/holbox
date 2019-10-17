import AppKit

final class Main: Window {
    final class Base: NSView {
        override var mouseDownCanMoveWindow: Bool { false }
        
        required init?(coder: NSCoder) { nil }
        init() {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private(set) weak var base: Base?
    private weak var bar: Bar?
    private weak var logo: Logo?

    init() {
        super.init(800, 700, mask: [.miniaturizable, .resizable])
        minSize = .init(width: 300, height: 200)
        setFrameOrigin(.init(x: NSScreen.main!.frame.midX - 400, y: NSScreen.main!.frame.midY - 250))
        
        let logo = Logo()
        logo.start()
        contentView!.addSubview(logo)
        self.logo = logo
        
        logo.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        logo.centerYAnchor.constraint(equalTo: contentView!.centerYAnchor).isActive = true
    }
    
    override func close() { app.terminate(nil) }
    
    override func becomeKey() {
        super.becomeKey()
        bar?.alphaValue = 1
        base?.alphaValue = 1
    }
    
    override func resignKey() {
        super.resignKey()
        bar?.alphaValue = 0.5
        base?.alphaValue = 0.5
    }
    
    override func zoom(_ sender: Any?) {
        contentView!.layer!.cornerRadius = isZoomed ? 20 : 0
        super.zoom(sender)
    }
    
    func loaded() {
        logo!.stop()
        logo!.removeFromSuperview()
        
        let bar = Bar()
        contentView!.addSubview(bar, positioned: .below, relativeTo: _close)
        self.bar = bar
        
        let base = Base()
        contentView!.addSubview(base)
        self.base = base
        
        bar.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        bar.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        bar.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        
        base.topAnchor.constraint(equalTo: bar.bottomAnchor).isActive = true
        base.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        base.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        base.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        
        kanban()
    }
    
    func project(_ project: Int) {
        app.project = project
        switch app.mode {
        case .kanban: show(Kanban())
        default: break
        }
    }
    
    @objc func kanban() {
        app.mode = .kanban
        bar?._kanban.selected = true
        bar?._todo.selected = false
        bar?._shopping.selected = false
        bar?._shop.selected = false
        show(Detail())
    }
    
    @objc func todo() {
        app.mode = .todo
        bar?._kanban.selected = false
        bar?._todo.selected = true
        bar?._shopping.selected = false
        bar?._shop.selected = false
        show(Detail())
    }
    
    @objc func shopping() {
        app.mode = .shopping
        bar?._kanban.selected = false
        bar?._todo.selected = false
        bar?._shopping.selected = true
        bar?._shop.selected = false
        show(Detail())
    }
    
    @objc func shop() {
        app.mode = .off
        bar?._kanban.selected = false
        bar?._todo.selected = false
        bar?._shopping.selected = false
        bar?._shop.selected = true
        show(Shop())
    }
    
    @objc func more() {
        app.runModal(for: More.Main())
    }
    
    @objc func about() {
        app.runModal(for: More.Main())
    }
    
    @objc func full() { zoom(self) }
    
    private func show(_ view: NSView) {
        guard let base = self.base else { return }
        base.subviews.forEach { $0.removeFromSuperview() }
        view.alphaValue = 0
        base.addSubview(view)
        
        view.topAnchor.constraint(equalTo: base.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: base.bottomAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: base.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: base.rightAnchor).isActive = true
        
        makeFirstResponder(view)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.4
            $0.allowsImplicitAnimation = true
            view.alphaValue = 1
        }
    }
}
