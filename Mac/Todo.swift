import AppKit

final class Todo: Base.View, NSTextViewDelegate {
    private weak var scroll: Scroll!
    private weak var new: Text!
    
    required init?(coder: NSCoder) { nil }
    required init() {
        super.init()
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let new = Text(.Vertical(500), Active())
        new.setAccessibilityLabel(.key("Task"))
        (new.textStorage as! Storage).fonts = [.plain: (.systemFont(ofSize: 22, weight: .medium), .white),
                                               .emoji: (NSFont(name: "Times New Roman", size: 30)!, .white),
                                               .bold: (.systemFont(ofSize: 24, weight: .bold), .white),
                                               .tag: (.systemFont(ofSize: 20, weight: .medium), NSColor(named: "haze")!)]
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
        scroll.bottom.constraint(greaterThanOrEqualTo: _add.bottomAnchor, constant: 40).isActive = true
        
        new.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
        new.leftAnchor.constraint(greaterThanOrEqualTo: scroll.left).isActive = true
        new.rightAnchor.constraint(lessThanOrEqualTo: scroll.right).isActive = true
        new.topAnchor.constraint(equalTo: scroll.top, constant: 20).isActive = true
        
        _add.topAnchor.constraint(equalTo: new.bottomAnchor).isActive = true
        _add.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
        _add.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _add.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        refresh()
    }
    
    override func layout() {
        super.layout()
        new.needsLayout = true
    }
    
    override func keyDown(with: NSEvent) {
        switch with.keyCode {
        case 36: add()
        default: super.keyDown(with: with)
        }
    }
    
    func textDidEndEditing(_: Notification) {
        let string = new.string
        new.string = ""
        if !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            app.session.add(app.project!, list: 0, content: string)
          app.alert(.key("Task"), message: string)
            refresh()
        }
        new.needsLayout = true
    }
    
    override func refresh() {
        scroll.views.filter { $0 is Task }.forEach { $0.removeFromSuperview() }
        var top: NSLayoutYAxisAnchor?
        [0, 1].forEach { list in
            (0 ..< app.session.cards(app.project!, list: list)).forEach {
                let task = Task($0, list: list)
                scroll.add(task)

                if top == nil {
                    task.topAnchor.constraint(equalTo: new.bottomAnchor, constant: 80).isActive = true
                } else {
                    task.topAnchor.constraint(equalTo: top!).isActive = true
                }
                task.leftAnchor.constraint(greaterThanOrEqualTo: scroll.left).isActive = true
                task.rightAnchor.constraint(lessThanOrEqualTo: scroll.right).isActive = true
                task.leftAnchor.constraint(greaterThanOrEqualTo: scroll.centerX, constant: -250).isActive = true
                
                let left = task.leftAnchor.constraint(equalTo: scroll.centerX, constant: -250)
                left.priority = .defaultLow
                left.isActive = true
                top = task.bottomAnchor
            }
        }
        if top != nil {
            scroll.bottom.constraint(greaterThanOrEqualTo: top!, constant: 50).isActive = true
        }
    }
    
    @objc private func add() {
        if new.string.isEmpty {
            if new.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                new.string = ""
                new.needsLayout = true
            }
            window!.makeFirstResponder(new)
        } else {
            window!.makeFirstResponder(self)
        }
    }
}
