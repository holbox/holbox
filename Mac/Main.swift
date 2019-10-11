import holbox
import AppKit

final class Main: Window {
    private(set) var mode = Mode.off
    private weak var bar: Bar?
    private weak var base: NSView?
    private weak var logo: Logo!

    init() {
        super.init(800, 700, mask: [.miniaturizable, .resizable])
        minSize = .init(width: 400, height: 300)
        setFrameOrigin(.init(x: NSScreen.main!.frame.midX - 400, y: NSScreen.main!.frame.midY - 250))
        
        let logo = Logo()
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
        bar?.alphaValue = 0.3
        base?.alphaValue = 0.3
    }
    
    func loaded() {
        let bar = Bar()
        contentView!.addSubview(bar, positioned: .below, relativeTo: _close)
        self.bar = bar
        
        let base = NSView()
        base.translatesAutoresizingMaskIntoConstraints = false
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
    
    @objc func kanban() {
        mode = .kanban
        bar?._todo.selected = false
        bar?._shopping.selected = false
        show(Detail())
    }
    
    @objc func todo() {
        mode = .todo
        bar?._kanban.selected = false
        bar?._shopping.selected = false
        show(Detail())
    }
    
    @objc func shopping() {
        mode = .shopping
        bar?._kanban.selected = false
        bar?._todo.selected = false
        show(Detail())
    }
    
    private func show(_ view: NSView) {
        guard let base = self.base else { return }
        base.subviews.forEach { $0.removeFromSuperview() }
        view.alphaValue = 0
        base.addSubview(view)
        
        view.topAnchor.constraint(equalTo: base.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: base.bottomAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: base.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: base.rightAnchor).isActive = true
        
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.4
            $0.allowsImplicitAnimation = true
            view.alphaValue = 1
        }) {
            self.makeFirstResponder(view)
        }
    }
}
