import AppKit

class Window: NSWindow, NSWindowDelegate {
    final class Button: NSView {
        private let action: Selector
        
        required init?(coder: NSCoder) { nil }
        init(_ image: String, action: Selector) {
            self.action = action
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            setAccessibilityElement(true)
            setAccessibilityRole(.button)
            alphaValue = 0.4
            
            let icon = Image(image)
            addSubview(icon)
            
            widthAnchor.constraint(equalToConstant: 12).isActive = true
            heightAnchor.constraint(equalToConstant: 12).isActive = true
            
            icon.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            icon.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            icon.topAnchor.constraint(equalTo: topAnchor).isActive = true
            icon.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
        
        override func resetCursorRects() {
            addCursorRect(bounds, cursor: .pointingHand)
        }
        
        override func mouseDown(with: NSEvent) {
            alphaValue = 1
            super.mouseDown(with: with)
        }
        
        override func mouseUp(with: NSEvent) {
            if bounds.contains(convert(with.locationInWindow, from: nil)) {
                _ = window!.perform(action, with: nil)
            }
            alphaValue = 0.4
            super.mouseUp(with: with)
        }
    }
    
    override var canBecomeKey: Bool { true }
    override var acceptsFirstResponder: Bool { true }
    private(set) weak var _close: Button!
    private(set) weak var _minimise: Button!
    private(set) weak var _zoom: Button!

    init(_ width: CGFloat, _ height: CGFloat, mask: NSWindow.StyleMask) {
        super.init(contentRect: .init(x: 0, y: 0, width: width, height: height), styleMask: [.borderless, mask], backing: .buffered, defer: false)
        backgroundColor = .clear
        isOpaque = false
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        isMovableByWindowBackground = true
        contentView!.wantsLayer = true
        contentView!.layer!.cornerRadius = 20
        contentView!.layer!.backgroundColor = .black
        delegate = self
        
        let _close = Button("close", action: #selector(close))
        _close.setAccessibilityLabel(.key("Window.close"))
        self._close = _close
        
        let _minimise = Button("minimise", action: #selector(miniaturize(_:)))
        _minimise.setAccessibilityLabel(.key("Window.minimise"))
        self._minimise = _minimise
        
        let _zoom = Button("zoom", action: #selector(zoom(_:)))
        _zoom.setAccessibilityLabel(.key("Window.zoom"))
        self._zoom = _zoom
        
        [_close, _minimise, _zoom].forEach {
            contentView!.addSubview($0)
            $0.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 18).isActive = true
        }
        
        _close.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 19).isActive = true
        _minimise.leftAnchor.constraint(equalTo: _close.rightAnchor, constant: 8).isActive = true
        _zoom.leftAnchor.constraint(equalTo: _minimise.rightAnchor, constant: 8).isActive = true
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
