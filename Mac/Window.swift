import AppKit

class Window: NSWindow {
    override var canBecomeKey: Bool { true }
    override var acceptsFirstResponder: Bool { true }
    private(set) weak var _close: Button.Window!
    private(set) weak var _minimise: Button.Window!
    private(set) weak var _zoom: Button.Window!

    init(_ width: CGFloat, _ height: CGFloat, mask: NSWindow.StyleMask) {
        super.init(contentRect: .init(x: NSScreen.main!.frame.midX - width / 2, y: NSScreen.main!.frame.midY - height / 2, width: width, height: height), styleMask: [.borderless, mask], backing: .buffered, defer: false)
        backgroundColor = .clear
        isOpaque = false
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        isMovableByWindowBackground = true
        contentView!.wantsLayer = true
        contentView!.layer!.cornerRadius = 20
        
        let _close = Button.Window(self, action: #selector(close))
        _close.setAccessibilityLabel(.key("Menu.quit"))
        _close.image.image = NSImage(named: "close")
        self._close = _close
        
        let _minimise = Button.Window(self, action: #selector(miniaturize(_:)))
        _minimise.setAccessibilityLabel(.key("Menu.minimize"))
        _minimise.image.image = NSImage(named: "minimise")
        self._minimise = _minimise
        
        let _zoom = Button.Window(self, action: #selector(zoom(_:)))
        _zoom.setAccessibilityLabel(.key("Menu.zoom"))
        _zoom.image.image = NSImage(named: "zoom")
        self._zoom = _zoom
        
        [_close, _minimise, _zoom].forEach {
            contentView!.addSubview($0)
            $0.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 18).isActive = true
        }
        
        _close.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 19).isActive = true
        _minimise.leftAnchor.constraint(equalTo: _close.rightAnchor, constant: 8).isActive = true
        _zoom.leftAnchor.constraint(equalTo: _minimise.rightAnchor, constant: 8).isActive = true
    }
    
    override func becomeKey() {
        super.becomeKey()
        contentView!.layer!.backgroundColor = .background
        [_close, _minimise, _zoom].forEach { $0!.alphaValue = 0.5 }
        hasShadow = true
    }
    
    override func resignKey() {
        super.resignKey()
        contentView!.layer!.backgroundColor = .black
        [_close, _minimise, _zoom].forEach { $0!.alphaValue = 0.3 }
        hasShadow = false
    }
}
