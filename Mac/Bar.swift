import AppKit

final class Bar: NSView {
    private(set) weak var _kanban: Tab!
    private(set) weak var _todo: Tab!
    private(set) weak var _shopping: Tab!
    private(set) weak var _shop: Tab!
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let border = Border()
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
        
        let _shop = Tab("cart", target: app.main, action: #selector(app.main.shop))
        _shop.setAccessibilityLabel(.key("Bar.shop"))
        addSubview(_shop)
        self._shop = _shop
        
        let _more = Button("more", target: app.main, action: #selector(app.main.more))
        
        [_kanban, _todo, _shopping, _shop, _more].forEach {
            addSubview($0)
            $0.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -1).isActive = true
        }
        
        heightAnchor.constraint(equalToConstant: 51).isActive = true
        
        _kanban.leftAnchor.constraint(equalTo: leftAnchor, constant: 100).isActive = true
        _todo.leftAnchor.constraint(equalTo: _kanban.rightAnchor, constant: 20).isActive = true
        _shopping.leftAnchor.constraint(equalTo: _todo.rightAnchor, constant: 20).isActive = true
        _shop.leftAnchor.constraint(equalTo: _shopping.rightAnchor, constant: 20).isActive = true
        
        _more.widthAnchor.constraint(equalToConstant: 40).isActive = true
        _more.heightAnchor.constraint(equalToConstant: 40).isActive = true
        _more.leftAnchor.constraint(greaterThanOrEqualTo: _shop.rightAnchor, constant: 20).isActive = true
        let right = _more.rightAnchor.constraint(equalTo: rightAnchor, constant: -10)
        right.priority = .defaultLow
        right.isActive = true
        
        border.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
}
