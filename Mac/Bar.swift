import AppKit

final class Bar: NSView {
    final class Tab: NSView {
        var selected = false { didSet { update() } }
        private weak var icon: NSImageView!
        private weak var target: AnyObject!
        private let action: Selector
        private let image: NSImage
        
        required init?(coder: NSCoder) { nil }
        init(_ image: String, target: AnyObject, action: Selector) {
            self.image = NSImage(named: image)!
            self.target = target
            self.action = action
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            setAccessibilityElement(true)
            setAccessibilityRole(.button)
            wantsLayer = true
            layer!.cornerRadius = 4
            
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
            
            update()
        }
        
        override func resetCursorRects() {
            addCursorRect(bounds, cursor: .pointingHand)
        }
        
        override func mouseUp(with: NSEvent) {
            if bounds.contains(convert(with.locationInWindow, from: nil)) {
                if !selected {
                    selected = true
                    _ = target.perform(action, with: nil)
                }
            }
        }
        
        private func update() {
            layer!.backgroundColor = selected ? .haze : .clear
            icon.image = selected ? image.tint(.black) : image
            icon.alphaValue = selected ? 1 : 0.4
        }
    }
    
    private(set) weak var _add: Button!
    private(set) weak var _kanban: Tab!
    private(set) weak var _todo: Tab!
    private(set) weak var _shopping: Tab!
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let border = NSView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.wantsLayer = true
        border.layer!.backgroundColor = .black
        addSubview(border)
        
        let _kanban = Tab("kanban", target: main, action: #selector(main.kanban))
        _kanban.setAccessibilityLabel(.key("Bar.kanban"))
        addSubview(_kanban)
        self._kanban = _kanban
        
        let _todo = Tab("todo", target: main, action: #selector(main.todo))
        _todo.setAccessibilityLabel(.key("Bar.todo"))
        addSubview(_todo)
        self._todo = _todo
        
        let _shopping = Tab("shopping", target: main, action: #selector(main.shopping))
        _shopping.setAccessibilityLabel(.key("Bar.shopping"))
        addSubview(_shopping)
        self._shopping = _shopping
        
        let _add = Button("plus", target: self, action: #selector(add))
        self._add = _add
        
        [_kanban, _todo, _shopping, _add].forEach {
            addSubview($0)
            $0.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -1).isActive = true
        }
        
        heightAnchor.constraint(equalToConstant: 51).isActive = true
        
        _kanban.leftAnchor.constraint(equalTo: leftAnchor, constant: 100).isActive = true
        _todo.leftAnchor.constraint(equalTo: _kanban.rightAnchor, constant: 10).isActive = true
        _shopping.leftAnchor.constraint(equalTo: _todo.rightAnchor, constant: 10).isActive = true

        _add.widthAnchor.constraint(equalToConstant: 40).isActive = true
        _add.heightAnchor.constraint(equalToConstant: 40).isActive = true
        _add.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true
        
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
    
    @objc private func add() {
        app.runModal(for: Add())
    }
}
