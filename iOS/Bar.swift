import UIKit

final class Bar: UIView {
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
        _kanban.accessibilityLabel = .key("Bar.kanban")
        addSubview(_kanban)
        self._kanban = _kanban
        
        let _todo = Tab("todo", target: app.main, action: #selector(app.main.todo))
        _todo.accessibilityLabel = .key("Bar.todo")
        addSubview(_todo)
        self._todo = _todo
        
        let _shopping = Tab("shopping", target: app.main, action: #selector(app.main.shopping))
        _shopping.accessibilityLabel = .key("Bar.shopping")
        addSubview(_shopping)
        self._shopping = _shopping
        
        let _shop = Tab("cart", target: app.main, action: #selector(app.main.shop))
        _shop.accessibilityLabel = .key("Bar.shop")
        addSubview(_shop)
        self._shop = _shop
        
        let _more = Button("more", target: app.main, action: #selector(app.main.more))
        
        [_kanban, _todo, _shopping, _shop, _more].forEach {
            addSubview($0)
            $0.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        }
        
        topAnchor.constraint(equalTo: _kanban.topAnchor).isActive = true
        
        _kanban.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        _todo.leftAnchor.constraint(equalTo: _kanban.rightAnchor).isActive = true
        _shopping.leftAnchor.constraint(equalTo: _todo.rightAnchor).isActive = true
        _shop.leftAnchor.constraint(equalTo: _kanban.rightAnchor).isActive = true
        
        _more.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        _more.widthAnchor.constraint(equalToConstant: 65).isActive = true
        _more.heightAnchor.constraint(equalToConstant: 65).isActive = true
        
        border.topAnchor.constraint(equalTo: topAnchor).isActive = true
        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        _todo.isHidden = true
        _shopping.isHidden = true
    }
}
