import AppKit

final class Bar: NSView {
    private weak var selected: Tab? { didSet { oldValue?.selected = false; selected?.selected = true } }
    private weak var height: NSLayoutConstraint?
    private weak var title: Label?
    private weak var border: Border!
    private weak var _shop: Button!
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let border = Border()
        border.alphaValue = 0
        addSubview(border)
        self.border = border
        
        let _home = Button("logo", target: self, action: #selector(home))
        _home.setAccessibilityLabel(.key("Bar.more"))
        
        let _shop = Button("cart", target: app.main, action: #selector(app.main.shop))
        _shop.setAccessibilityLabel(.key("Bar.shop"))
        self._shop = _shop
        
        let _more = Button("more", target: app.main, action: #selector(app.main.more))
        _more.setAccessibilityLabel(.key("Bar.more"))
        
        let _kanban = Tab("kanban", label: .key("Bar.kanban")) {
            self.selected = $0
            app.mode = .kanban
            app.main.detail()
        }
        
        let _todo = Tab("todo", label: .key("Bar.todo")) {
            self.selected = $0
            app.mode = .todo
            app.main.detail()
        }
        
        let _shopping = Tab("shopping", label: .key("Bar.shopping")) {
            self.selected = $0
            app.mode = .shopping
            app.main.detail()
        }
        
        let _notes = Tab("notes", label: .key("Bar.notes")) {
            self.selected = $0
            app.mode = .notes
            app.main.detail()
        }
        
        [_home, _shop, _more].forEach {
            addSubview($0)
            
            $0.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -1).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 30).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 30).isActive = true
        }
        
        var left = _home.rightAnchor
        [_kanban, _todo, _shopping, _notes].forEach {
            addSubview($0)
            
            $0.leftAnchor.constraint(equalTo: left, constant: 20).isActive = true
            $0.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -1).isActive = true
            left = $0.rightAnchor
        }
        
        _home.leftAnchor.constraint(equalTo: leftAnchor, constant: 100).isActive = true
        
        _shop.leftAnchor.constraint(greaterThanOrEqualTo: left, constant: 20).isActive = true
        let right = _shop.rightAnchor.constraint(equalTo: rightAnchor, constant: -65)
        right.priority = .defaultLow
        right.isActive = true
        
        _more.leftAnchor.constraint(equalTo: _shop.rightAnchor, constant: 20).isActive = true
        
        border.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
    
    func project() {
        border.alphaValue = 1
        selected = nil
        resize(51, nil)
        
        let title = Label(app.session.name(app.project), 14, .bold, NSColor(named: "haze")!)
        title.wantsLayer = true
        title.alphaValue = 0
        title.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        addSubview(title)
           
        title.leftAnchor.constraint(equalTo: leftAnchor, constant: 350).isActive = true
        title.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -1).isActive = true
        _shop.leftAnchor.constraint(greaterThanOrEqualTo: title.rightAnchor, constant: 20).isActive = true
        
        NSAnimationContext.runAnimationGroup ({
            $0.duration = 0.4
            $0.allowsImplicitAnimation = true
            title.alphaValue = 1
            self.title?.alphaValue = 0
        }) {
            self.title?.removeFromSuperview()
            self.title = title
        }
    }
    
    func detail() {
        border.alphaValue = 1
        resize(151, nil)
        
        let title = Label(.key("Detail.title.\(app.mode.rawValue)"), 18, .bold, NSColor(named: "haze")!)
        title.wantsLayer = true
        title.alphaValue = 0
        addSubview(title)
        
        title.leftAnchor.constraint(equalTo: leftAnchor, constant: 100).isActive = true
        title.bottomAnchor.constraint(equalTo: border.topAnchor, constant: -10).isActive = true
     
        NSAnimationContext.runAnimationGroup ({
            $0.duration = 0.4
            $0.allowsImplicitAnimation = true
            title.alphaValue = 1
            self.title?.alphaValue = 0
        }) {
            self.title?.removeFromSuperview()
            self.title = title
        }
    }
    
    @objc private func home() {
        selected = nil
        app.mode = .off
        title?.removeFromSuperview()
        resize(nil) {
            self.border.alphaValue = 0
            app.main.base.clear()
        }
    }
    
    private func resize(_ amount: CGFloat?, _ completion: (() -> Void)?) {
        height?.isActive = false
        if let amount = amount {
            height = heightAnchor.constraint(equalToConstant: amount)
            height!.isActive = true
        }
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.4
            $0.allowsImplicitAnimation = true
            superview!.layoutSubtreeIfNeeded()
        }, completionHandler: completion)
    }
}
