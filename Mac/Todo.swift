import AppKit

final class Todo: Base.View, NSTextViewDelegate {
    private weak var scroll: Scroll!
    private weak var new: Text!
    private weak var name: Text!
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let name = Text(.Vertical(400), Block())
        name.setAccessibilityLabel(.key("Kanban.project"))
        (name.textStorage as! Storage).fonts = [.plain: .systemFont(ofSize: 30, weight: .bold),
                                                .emoji: .systemFont(ofSize: 40, weight: .regular),
                                                .bold: .systemFont(ofSize: 34, weight: .bold)]
        name.standby = NSColor(named: "haze")!.withAlphaComponent(0.7)
        name.delegate = self
        scroll.add(name)
        self.name = name
        
        let _more = Button("more", target: self, action: #selector(more))
        scroll.add(_more)
        
        let new = Text(.Vertical(500), Active())
        new.setAccessibilityLabel(.key("Task"))
        (new.textStorage as! Storage).fonts = [.plain: .systemFont(ofSize: 20, weight: .medium),
                                               .emoji: .systemFont(ofSize: 36, weight: .regular),
                                               .bold: .systemFont(ofSize: 26, weight: .bold)]
        new.delegate = self
        scroll.add(new)
        self.new = new
        
        let _add = Button("plus", target: self, action: #selector(add))
        scroll.add(_add)
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        scroll.right.constraint(equalTo: rightAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: _add.bottomAnchor, constant: 20).isActive = true

        name.topAnchor.constraint(equalTo: scroll.top, constant: 40).isActive = true
        name.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
        name.leftAnchor.constraint(greaterThanOrEqualTo: scroll.left).isActive = true
        name.rightAnchor.constraint(lessThanOrEqualTo: scroll.right).isActive = true
        
        _more.widthAnchor.constraint(equalToConstant: 40).isActive = true
        _more.heightAnchor.constraint(equalToConstant: 40).isActive = true
        _more.centerYAnchor.constraint(equalTo: name.centerYAnchor, constant: 2).isActive = true
        _more.leftAnchor.constraint(equalTo: name.rightAnchor, constant: 20).isActive = true
        
        new.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
        new.leftAnchor.constraint(greaterThanOrEqualTo: scroll.left).isActive = true
        new.rightAnchor.constraint(lessThanOrEqualTo: scroll.right).isActive = true
        new.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 20).isActive = true
        
        _add.topAnchor.constraint(equalTo: new.bottomAnchor).isActive = true
        _add.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
        _add.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _add.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        refresh()
    }
    
    override func layout() {
        super.layout()
        new.needsLayout = true
        name.needsLayout = true
    }
    
    override func refresh() {
        scroll.views.filter { $0 is Task }.forEach { $0.removeFromSuperview() }
        name.string = app.session.name(app.project)
        name.didChangeText()
    }
    
    @objc private func more() {
        
    }
    
    @objc private func add() {
        if new.string.isEmpty {
            print("made")
            window!.makeFirstResponder(new)
        } else {
            print("unmake")
            window!.makeFirstResponder(nil)
        }
    }
}
