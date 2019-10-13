import AppKit

final class Bar: NSView, NSTextViewDelegate {
    private(set) weak var _add: Button!
    private(set) weak var _kanban: Tab!
    private(set) weak var _todo: Tab!
    private(set) weak var _shopping: Tab!
    private weak var name: Text!
    
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
        
        let name = Text()
        name.alphaValue = 0.5
        name.textColor = .white
        name.font = .systemFont(ofSize: 14, weight: .bold)
        name.textContainer!.lineBreakMode = .byTruncatingTail
        name.textContainer!.widthTracksTextView = true
        name.textContainer!.size.height = 40
        name.delegate = self
        addSubview(name)
        self.name = name
        
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

        name.leftAnchor.constraint(equalTo: _shopping.rightAnchor, constant: 20).isActive = true
        name.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.26).isActive = true
        name.heightAnchor.constraint(equalToConstant: 40).isActive = true
        name.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -2).isActive = true
        
        _add.widthAnchor.constraint(equalToConstant: 40).isActive = true
        _add.heightAnchor.constraint(equalToConstant: 40).isActive = true
        _add.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true
        
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
    
    func textDidEndEditing(_: Notification) {
        name.alphaValue = 0.5
        session.name(main.project, name: name.string)
    }
    
    func show() {
        name.isHidden = false
        name.accepts = true
        name.string = session.name(main.project)
    }
    
    func hide() {
        name.accepts = false
        name.string = ""
        name.isHidden = true
    }
    
    @objc private func add() {
        app.runModal(for: Add())
    }
}
