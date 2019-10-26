import AppKit

class Window: NSWindow, NSWindowDelegate {
    class Full: Window {
        init(_ width: CGFloat, _ height: CGFloat) {
            super.init(width, height, mask: [.miniaturizable, .resizable])
            contentView!.layer!.backgroundColor = .black
            
            let _close = Tool("close", action: #selector(close))
            _close.setAccessibilityLabel(.key("Window.close"))
            
            let _minimise = Tool("minimise", action: #selector(miniaturize(_:)))
            _minimise.setAccessibilityLabel(.key("Window.minimise"))
            
            let _zoom = Tool("zoom", action: #selector(zoom(_:)))
            _zoom.setAccessibilityLabel(.key("Window.zoom"))
            
            [_close, _minimise, _zoom].forEach {
                contentView!.addSubview($0)
                $0.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 18).isActive = true
            }
            
            _close.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 19).isActive = true
            _minimise.leftAnchor.constraint(equalTo: _close.rightAnchor, constant: 8).isActive = true
            _zoom.leftAnchor.constraint(equalTo: _minimise.rightAnchor, constant: 8).isActive = true
        }
    }
    
    class Modal: Window {
        init(_ width: CGFloat, _ height: CGFloat) {
            super.init(width, height, mask: [])
            contentView!.layer!.backgroundColor = NSColor(named: "background")!.cgColor
            contentView!.layer!.borderColor = NSColor(named: "background")!.cgColor
        }
        
        override func becomeKey() {
            super.becomeKey()
            contentView!.layer!.backgroundColor = NSColor(named: "background")!.cgColor
            contentView!.layer!.borderWidth = 0
        }
        
        override func resignKey() {
            super.resignKey()
            contentView!.layer!.backgroundColor = .black
            contentView!.layer!.borderWidth = 1
        }
        
        override func keyDown(with: NSEvent) {
            switch with.keyCode {
            case 53: close()
            default: super.keyDown(with: with)
            }
        }
        
        override func close() {
            super.close()
            app.stopModal()
        }
    }
    
    override var canBecomeKey: Bool { true }
    override var acceptsFirstResponder: Bool { true }

    private init(_ width: CGFloat, _ height: CGFloat, mask: NSWindow.StyleMask) {
        super.init(contentRect: .init(x: 0, y: 0, width: width, height: height), styleMask: [.borderless, mask], backing: .buffered, defer: false)
        appearance = NSAppearance(named: .darkAqua)
        backgroundColor = .clear
        isOpaque = false
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        isMovableByWindowBackground = true
        contentView!.wantsLayer = true
        contentView!.layer!.cornerRadius = 20
        delegate = self
    }
    
    func windowWillStartLiveResize(_: Notification) {
        isMovableByWindowBackground = false
    }
    
    func windowDidEndLiveResize(_: Notification) {
        isMovableByWindowBackground = true
    }
    
    override func becomeKey() {
        super.becomeKey()
        hasShadow = true
    }
    
    override func resignKey() {
        super.resignKey()
        hasShadow = false
    }
}
