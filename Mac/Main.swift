import AppKit

final class Main: Window {
    private(set) weak var base: NSView!
    private weak var bar: Bar!

    init() {
        super.init(800, 700, mask: [.miniaturizable, .resizable])
        minSize = .init(width: 400, height: 300)
        
        let bar = Bar()
        contentView!.addSubview(bar)
        self.bar = bar
        
        bar.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        bar.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        bar.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
    }
    
    override func close() { app.terminate(nil) }
    
    func show(_ view: NSView) {
        base.subviews.forEach { $0.removeFromSuperview() }
        view.alphaValue = 0
        base.addSubview(view)
        
        view.topAnchor.constraint(equalTo: base.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: base.bottomAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: base.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: base.rightAnchor).isActive = true
        
        NSAnimationContext.runAnimationGroup({
            $0.duration = 1
            $0.allowsImplicitAnimation = true
            view.alphaValue = 1
        }) {
            self.makeFirstResponder(view)
        }
    }
    
    override func becomeKey() {
        super.becomeKey()
        bar.alphaValue = 1
    }
    
    override func resignKey() {
        super.resignKey()
        bar.alphaValue = 0.3
    }
}

