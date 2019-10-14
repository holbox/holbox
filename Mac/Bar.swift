import AppKit

final class Bar: NSView, NSTextViewDelegate {
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
        
        let _kanban = Tab("kanban", target: app.main, action: #selector(app.main.kanban))
        _kanban.setAccessibilityLabel(.key("Bar.kanban"))
        addSubview(_kanban)
        self._kanban = _kanban
        
        let _todo = Tab("todo", target: app.main, action: #selector(app.main.todo))
        _todo.setAccessibilityLabel(.key("Bar.todo"))
        addSubview(_todo)
        self._todo = _todo
        
        let _shopping = Tab("shopping", target: app.main, action: #selector(app.main.shopping))
        _shopping.setAccessibilityLabel(.key("Bar.shopping"))
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
}
