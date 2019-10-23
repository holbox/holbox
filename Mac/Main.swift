import AppKit

final class Main: Window {
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
        bar?.alphaValue = 0.3
        base?.alphaValue = 0.3
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
        bar?._kanban.selected = false
        bar?._todo.selected = false
        bar?._shopping.selected = false
        bar?._shop.selected = false
        switch app.mode {
        case .kanban: base?.show(Kanban())
        default: break
        }
    }
    
    @objc func kanban() {
        app.mode = .kanban
        bar?._kanban.selected = true
        bar?._todo.selected = false
        bar?._shopping.selected = false
        bar?._shop.selected = false
        base?.show(Detail())
    }
    
    @objc func todo() {
        app.mode = .todo
        bar?._kanban.selected = false
        bar?._todo.selected = true
        bar?._shopping.selected = false
        bar?._shop.selected = false
        base?.show(Detail())
    }
    
    @objc func shopping() {
        app.mode = .shopping
        bar?._kanban.selected = false
        bar?._todo.selected = false
        bar?._shopping.selected = true
        bar?._shop.selected = false
        base?.show(Detail())
    }
    
    @objc func shop() {
        app.mode = .off
        bar?._kanban.selected = false
        bar?._todo.selected = false
        bar?._shopping.selected = false
        bar?._shop.selected = true
        base?.show(Shop())
    }
    
    @objc func more() {
        app.runModal(for: More.Main())
    }
    
    @objc func about() {
        app.runModal(for: About())
    }
    
    @objc func full() { zoom(self) }
}
