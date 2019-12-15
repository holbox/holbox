import AppKit

final class Bar: NSView, NSTextViewDelegate {
    private(set) weak var find: Find!
    private weak var title: Label?
    private weak var name: Text?
    private weak var border: Border!
    private weak var button: NSLayoutConstraint!
    private weak var height: NSLayoutConstraint?
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let unmove = Unmove()
        addSubview(unmove)
        
        let border = Border.horizontal()
        border.alphaValue = 0
        addSubview(border)
        self.border = border
        
        let _home = Button("logo", target: self, action: #selector(home))
        _home.setAccessibilityLabel(.key("Bar.home"))
        addSubview(_home)
        
        let _add = Button("add", target: self, action: #selector(add))
        _add.setAccessibilityLabel(.key("Bar.add"))
        addSubview(_add)
        
        let _shop = Button("cart", target: self, action: #selector(shop))
        _shop.setAccessibilityLabel(.key("Bar.shop"))
        
        let _settings = Button("more", target: self, action: #selector(settings))
        _settings.setAccessibilityLabel(.key("Bar.settings"))
        
        let find = Find()
        find.alphaValue = 0
        addSubview(find)
        self.find = find
        
        var left = find.rightAnchor
        [_add, _shop, _settings].forEach {
            addSubview($0)
            
            $0.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -1).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 30).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 30).isActive = true
            $0.leftAnchor.constraint(equalTo: left, constant: 20).isActive = true
            left = $0.rightAnchor
        }
        
        unmove.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 51).isActive = true
        unmove.heightAnchor.constraint(lessThanOrEqualToConstant: 50).isActive = true
        unmove.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        unmove.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        unmove.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        _home.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -1).isActive = true
        _home.leftAnchor.constraint(equalTo: leftAnchor, constant: 100).isActive = true
        _home.heightAnchor.constraint(equalTo: _home.widthAnchor).isActive = true
        button = _home.widthAnchor.constraint(equalToConstant: 100)
        button.isActive = true
        
        find.leftAnchor.constraint(greaterThanOrEqualTo: _home.rightAnchor, constant: 20).isActive = true
        find.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -1).isActive = true
        
        let right = find.rightAnchor.constraint(equalTo: rightAnchor, constant: -170)
        right.priority = .defaultLow
        right.isActive = true
        
        border.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
    
    func textDidEndEditing(_: Notification) {
        guard let name = self.name?.string, let project = app.project else { return }
        app.session.name(project, name: name)
    }
    
    func refresh() {
        if app.project == nil {
            if app.session.projects().isEmpty {
                empty()
            } else {
                detail()
            }
        } else {
            project()
        }
    }
    
    @objc func shop() {
        app.runModal(for: Shop())
    }
    
    @objc func settings() {
        app.runModal(for: Settings())
    }
    
    private func project() {
        border.alphaValue = 1
        resize(51, nil)
        
        let name = Text(.Expand(350, 51), Block())
        name.textContainerInset.width = 10
        name.textContainerInset.height = 10
        name.wantsLayer = true
        name.alphaValue = 0
        name.setAccessibilityLabel(.key("Project"))
        name.font = NSFont(name: "Times New Roman", size: 14)!
        (name.textStorage as! Storage).fonts = [.plain: (.systemFont(ofSize: 14, weight: .medium), NSColor(named: "haze")!),
                                                .emoji: (NSFont(name: "Times New Roman", size: 14)!, .white),
                                                .bold: (.systemFont(ofSize: 14, weight: .bold), NSColor(named: "haze")!),
                                                .tag: (.systemFont(ofSize: 14, weight: .medium), NSColor(named: "haze")!)]
        name.textContainer!.maximumNumberOfLines = 1
        (name.layoutManager as! Layout).padding = 1
        name.string = app.session.name(app.project)
        addSubview(name)
        
        name.leftAnchor.constraint(equalTo: leftAnchor, constant: 120).isActive = true
        name.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -1).isActive = true
        name.didChangeText()
        name.delegate = self
        
        find.clear()
        find.leftAnchor.constraint(greaterThanOrEqualTo: name.rightAnchor).isActive = true
        
        button.constant = 20
        NSAnimationContext.runAnimationGroup ({
            $0.duration = 0.4
            $0.allowsImplicitAnimation = true
            layoutSubtreeIfNeeded()
            name.alphaValue = 1
            title?.alphaValue = 0
            self.name?.alphaValue = 0
            find.alphaValue = 1
        }) {
            self.title?.removeFromSuperview()
            self.name?.removeFromSuperview()
            self.name = name
        }
    }
    
    private func detail() {
        border.alphaValue = 1
        resize(151, nil)
        
        let title = Label(.key("Detail.title"), 14, .bold, NSColor(named: "haze")!)
        title.wantsLayer = true
        title.alphaValue = 0
        addSubview(title)
        
        title.leftAnchor.constraint(equalTo: leftAnchor, constant: 98).isActive = true
        title.bottomAnchor.constraint(equalTo: border.topAnchor, constant: -10).isActive = true
        
        button.constant = 30
        
        find.clear()
        NSAnimationContext.runAnimationGroup ({
            $0.duration = 0.4
            $0.allowsImplicitAnimation = true
            layoutSubtreeIfNeeded()
            title.alphaValue = 1
            self.title?.alphaValue = 0
            name?.alphaValue = 0
            find.alphaValue = 1
        }) {
            self.name?.removeFromSuperview()
            self.title?.removeFromSuperview()
            self.title = title
        }
    }
    
    private func empty() {
        title?.removeFromSuperview()
        name?.removeFromSuperview()
        resize(nil) {
            self.border.alphaValue = 0
        }
        
        button.constant = 50
        
        find.clear()
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            find.alphaValue = 0
            layoutSubtreeIfNeeded()
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
    
    @objc private func home() {
        window!.makeFirstResponder(app.main)
        app.project = nil
        app.refresh()
    }
    
    @objc private func add() {
        app.runModal(for: Add())
    }
}
