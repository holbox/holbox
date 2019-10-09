import AppKit

final class Bar: NSView {
    final class Tab: NSView {
        var selected = false { didSet { update() } }
        var image: NSImage! { didSet { update() } }
        private weak var icon: NSImageView!
        private weak var target: AnyObject!
        private var action: Selector!
        
        required init?(coder: NSCoder) { nil }
        init(_ target: AnyObject, action: Selector) {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            setAccessibilityElement(true)
            setAccessibilityRole(.button)
            wantsLayer = true
            layer!.cornerRadius = 4
            self.target = target
            self.action = action
            
            let icon = NSImageView()
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.imageScaling = .scaleNone
            addSubview(icon)
            self.icon = icon
            
            widthAnchor.constraint(equalToConstant: 30).isActive = true
            heightAnchor.constraint(equalToConstant: 30).isActive = true
            
            icon.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            icon.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            icon.topAnchor.constraint(equalTo: topAnchor).isActive = true
            icon.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
        
        override func resetCursorRects() {
            addCursorRect(bounds, cursor: .pointingHand)
        }
        
        override func mouseUp(with: NSEvent) {
            if bounds.contains(convert(with.locationInWindow, from: nil)) {
                if !selected {
                    selected = true
                    _ = target.perform(action, with: self)
                }
            }
        }
        
        private func update() {
            layer!.backgroundColor = selected ? .haze : .clear
            icon.image = selected ? image.tint(.black) : image
            icon.alphaValue = selected ? 1 : 0.4
        }
    }
    
    private weak var _kanban: Tab!
    private weak var _todo: Tab!
    private weak var _shopping: Tab!
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let border = NSView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.wantsLayer = true
        border.layer!.backgroundColor = .black
        addSubview(border)
        
        let _kanban = Tab(self, action: #selector(kanban))
        _kanban.image = NSImage(named: "kanban")
        _kanban.selected = true
        addSubview(_kanban)
        self._kanban = _kanban
        
        let _todo = Tab(self, action: #selector(todo))
        _todo.image = NSImage(named: "todo")
        addSubview(_todo)
        self._todo = _todo
        
        let _shopping = Tab(self, action: #selector(shopping))
        _shopping.image = NSImage(named: "shopping")
        addSubview(_shopping)
        self._shopping = _shopping
        
        [_kanban, _todo, _shopping].forEach {
            addSubview($0)
            $0.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -1).isActive = true
        }
        
        heightAnchor.constraint(equalToConstant: 51).isActive = true
        
        _kanban.leftAnchor.constraint(equalTo: leftAnchor, constant: 100).isActive = true
        _todo.leftAnchor.constraint(equalTo: _kanban.rightAnchor, constant: 10).isActive = true
        _shopping.leftAnchor.constraint(equalTo: _todo.rightAnchor, constant: 10).isActive = true
        
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
    
    @objc private func kanban() {
        _todo.selected = false
        _shopping.selected = false
    }
    
    @objc private func todo() {
        _kanban.selected = false
        _shopping.selected = false
    }
    
    @objc private func shopping() {
        _kanban.selected = false
        _todo.selected = false
    }
}
