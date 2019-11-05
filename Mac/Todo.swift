import AppKit

final class Todo: Base.View, NSTextViewDelegate {
    private weak var empty: Label?
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
        name.setAccessibilityLabel(.key("Project"))
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
        new.font = .systemFont(ofSize: 28, weight: .medium)
        (new.textStorage as! Storage).fonts = [.plain: new.font!,
                                               .emoji: .systemFont(ofSize: 45, weight: .regular),
                                               .bold: .systemFont(ofSize: 35, weight: .bold)]
        new.delegate = self
        scroll.add(new)
        self.new = new
        
        let _add = Button("plusbig", target: self, action: #selector(add))
        scroll.add(_add)
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        scroll.right.constraint(equalTo: rightAnchor).isActive = true

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
        new.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 5).isActive = true
        
        _add.topAnchor.constraint(equalTo: new.bottomAnchor).isActive = true
        _add.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
        _add.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _add.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        refresh()
    }
    
    override func layout() {
        super.layout()
        new.needsLayout = true
        name.needsLayout = true
    }
    
    override func keyDown(with: NSEvent) {
        switch with.keyCode {
        case 36: add()
        default: super.keyDown(with: with)
        }
    }
    
    func textDidEndEditing(_ notification: Notification) {
        if (notification.object as! Text) == new {
            let string = new.string
            new.string = ""
            if !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                app.session.add(app.project, list: 0, content: string)
                refresh()
            }
            new.needsLayout = true
        } else {
            app.session.name(app.project, name: name.string)
        }
    }
    
    override func refresh() {
        scroll.views.filter { $0 is Task }.forEach { $0.removeFromSuperview() }
        empty?.removeFromSuperview()
        name.string = app.session.name(app.project)
        name.didChangeText()
        
        if app.session.cards(app.project, list: 0) + app.session.cards(app.project, list: 1) == 0 {
            let empty = Label(.key("Todo.empty"), 15, .medium, NSColor(named: "haze")!)
            scroll.add(empty)
            self.empty = empty

            empty.topAnchor.constraint(equalTo: new.bottomAnchor, constant: 80).isActive = true
            empty.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true

            scroll.bottom.constraint(greaterThanOrEqualTo: empty.bottomAnchor, constant: 40).isActive = true
        } else {
            var top: NSLayoutYAxisAnchor?
            [0, 1].forEach { list in
                (0 ..< app.session.cards(app.project, list: list)).forEach {
                    let task = Task(app.session.content(app.project, list: list, card: $0), index: $0, list: list, self)
                    scroll.add(task)

                    task.leftAnchor.constraint(greaterThanOrEqualTo: scroll.left).isActive = true
                    task.rightAnchor.constraint(lessThanOrEqualTo: scroll.right).isActive = true
                    task.widthAnchor.constraint(lessThanOrEqualToConstant: 500).isActive = true
                    task.leftAnchor.constraint(greaterThanOrEqualTo: scroll.centerX, constant: -250).isActive = true
                    
                    let left = task.leftAnchor.constraint(equalTo: scroll.centerX, constant: -250)
                    left.priority = .defaultLow
                    left.isActive = true
                    
                    let width = task.widthAnchor.constraint(equalToConstant: 500)
                    width.priority = .defaultLow
                    width.isActive = true

                    if top == nil {
                        task.topAnchor.constraint(equalTo: new.bottomAnchor, constant: 80).isActive = true
                    } else {
                        task.topAnchor.constraint(equalTo: top!).isActive = true
                    }

                    top = task.bottomAnchor
                }
            }
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
