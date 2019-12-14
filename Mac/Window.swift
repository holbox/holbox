import AppKit

class Window: NSWindow {
    override var canBecomeKey: Bool { true }
    override var acceptsFirstResponder: Bool { true }

    init(_ width: CGFloat, _ height: CGFloat, mask: NSWindow.StyleMask) {
        super.init(contentRect: .init(x: 0, y: 0, width: width, height: height), styleMask: [.borderless, mask], backing: .buffered, defer: false)
        appearance = NSAppearance(named: .darkAqua)
        backgroundColor = .clear
        isOpaque = false
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        isMovableByWindowBackground = true
        contentView!.wantsLayer = true
        contentView!.layer!.cornerRadius = 10
    }
    
    override func becomeKey() {
        super.becomeKey()
        hasShadow = true
        contentView!.subviews.forEach { $0.alphaValue = 1 }
    }
    
    override func resignKey() {
        super.resignKey()
        hasShadow = false
        contentView!.subviews.forEach { $0.alphaValue = 0.4 }
    }
    
    final func addClose() {
        let _close = Tool("close", action: #selector(close))
        _close.setAccessibilityLabel(.key("Window.close"))
        contentView!.addSubview(_close)
        
        _close.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 18).isActive = true
        _close.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 19).isActive = true
    }
    
    final func addMinimise() {
        let _minimise = Tool("minimise", action: #selector(miniaturize(_:)))
        _minimise.setAccessibilityLabel(.key("Window.minimise"))
        contentView!.addSubview(_minimise)
        
        _minimise.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 18).isActive = true
        _minimise.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 39).isActive = true
        
    }
    
    final func addZoom() {
        let _zoom = Tool("zoom", action: #selector(zoom(_:)))
        _zoom.setAccessibilityLabel(.key("Window.zoom"))
        contentView!.addSubview(_zoom)

        _zoom.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 18).isActive = true
        _zoom.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 59).isActive = true
    }
}
