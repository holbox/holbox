import AppKit

final class Bar: NSView, NSTextViewDelegate {
    private weak var selected: Tab? { didSet { oldValue?.selected = false; selected?.selected = true } }
    private weak var height: NSLayoutConstraint?
    private weak var title: Label?
    private weak var name: Text?
    private weak var border: Border!
    private weak var _add: Button!
    private weak var homeSize: NSLayoutConstraint!
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let unmove = Unmove()
        addSubview(unmove)
        
        let border = Border()
        border.alphaValue = 0
        addSubview(border)
        self.border = border
        
        let _home = Button("logo", target: self, action: #selector(home))
        _home.setAccessibilityLabel(.key("Bar.more"))
        addSubview(_home)
        
        let _add = Button("add", target: self, action: #selector(add))
        _add.setAccessibilityLabel(.key("Bar.add"))
        addSubview(_add)
        self._add = _add
        
        let _shop = Button("cart", target: app.main, action: #selector(app.main.shop))
        _shop.setAccessibilityLabel(.key("Bar.shop"))
        
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
        
        var left: NSLayoutXAxisAnchor?
        [_add, _shop, _more].forEach {
            addSubview($0)
            
            $0.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -1).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 30).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 30).isActive = true
            if left != nil {
                $0.leftAnchor.constraint(equalTo: left!, constant: 20).isActive = true
            }
            left = $0.rightAnchor
        }
        
        left = _home.rightAnchor
        [_kanban, _todo, _shopping, _notes].forEach {
            addSubview($0)
            
            $0.leftAnchor.constraint(equalTo: left!, constant: 20).isActive = true
            $0.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -1).isActive = true
            left = $0.rightAnchor
        }
        
        unmove.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 51).isActive = true
        unmove.heightAnchor.constraint(lessThanOrEqualToConstant: 50).isActive = true
        unmove.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        unmove.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        unmove.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        _home.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -1).isActive = true
        _home.centerXAnchor.constraint(equalTo: leftAnchor, constant: 115).isActive = true
        _home.heightAnchor.constraint(equalTo: _home.widthAnchor).isActive = true
        homeSize = _home.widthAnchor.constraint(equalToConstant: 100)
        homeSize.isActive = true
        
        _add.leftAnchor.constraint(greaterThanOrEqualTo: left!, constant: 20).isActive = true
        let right = _add.rightAnchor.constraint(equalTo: rightAnchor, constant: -120)
        right.priority = .defaultLow
        right.isActive = true
        
        border.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
    
    func textDidEndEditing(_: Notification) {
        guard let name = self.name?.string else { return }
        app.session.name(app.project, name: name)
    }
    
    func project() {
        border.alphaValue = 1
        selected = nil
        resize(51, nil)
        
        let name = Text(.Both(300, 51), Block())
        name.wantsLayer = true
        name.alphaValue = 0
        name.setAccessibilityLabel(.key("Project"))
        (name.textStorage as! Storage).fonts = [.plain: (.systemFont(ofSize: 14, weight: .bold), .white),
                                                .emoji: (NSFont(name: "Times New Roman", size: 20)!, .white),
                                                .bold: (.systemFont(ofSize: 16, weight: .heavy), .white)]
        name.textContainer!.maximumNumberOfLines = 1
        name.string = app.session.name(app.project)
        addSubview(name)
        
        name.leftAnchor.constraint(equalTo: leftAnchor, constant: 350).isActive = true
        name.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -1).isActive = true
        _add.leftAnchor.constraint(greaterThanOrEqualTo: name.rightAnchor, constant: 20).isActive = true
        name.didChangeText()
        name.delegate = self
        
        homeSize.constant = 30
        NSAnimationContext.runAnimationGroup ({
            $0.duration = 0.4
            $0.allowsImplicitAnimation = true
            layoutSubtreeIfNeeded()
            name.alphaValue = 1
            title?.alphaValue = 0
            self.name?.alphaValue = 0
        }) {
            self.title?.removeFromSuperview()
            self.name?.removeFromSuperview()
            self.name = name
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
     
        homeSize.constant = 30
        NSAnimationContext.runAnimationGroup ({
            $0.duration = 0.4
            $0.allowsImplicitAnimation = true
            layoutSubtreeIfNeeded()
            title.alphaValue = 1
            self.title?.alphaValue = 0
            name?.alphaValue = 0
        }) {
            self.name?.removeFromSuperview()
            self.title?.removeFromSuperview()
            self.title = title
        }
    }
    
    @objc private func home() {
        selected = nil
        app.mode = .off
        title?.removeFromSuperview()
        name?.removeFromSuperview()
        resize(nil) {
            self.border.alphaValue = 0
            app.main.base.clear()
        }
        
        homeSize.constant = 100
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            layoutSubtreeIfNeeded()
        }
    }
    
    @objc private func add() {
        app.runModal(for: Add())
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
