import UIKit

final class Todo: Base.View {
    private final class Detail: Edit {
        private weak var todo: Todo?
        
        required init?(coder: NSCoder) { nil }
        init(_ todo: Todo) {
            super.init()
            self.todo = todo
        }
        
        override func textViewDidEndEditing(_: UITextView) {
            if !text.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                app.session.add(app.project, list: 0, content: text.text)
                app.alert(.key("Add.card.\(app.mode.rawValue)"), message: text.text)
                todo?.refresh()
            }
        }
    }
    
    private weak var deleting: Task?
    private weak var empty: Label?
    private weak var name: Label?
    private weak var scroll: Scroll!
    private weak var _add: Button!
    private weak var _more: Button!
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let _more = Button("more", target: self, action: #selector(more))
        scroll.add(_more)
        self._more = _more
        
        let _add = Button("plusbig", target: self, action: #selector(add))
        scroll.add(_add)
        self._add = _add
        
        scroll.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        scroll.right.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        scroll.width.constraint(equalTo: safeAreaLayoutGuide.widthAnchor).isActive = true
        scroll.height.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.heightAnchor).isActive = true
        
        _more.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _more.heightAnchor.constraint(equalToConstant: 60).isActive = true
        _more.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
        
        _add.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
        _add.widthAnchor.constraint(equalToConstant: 70).isActive = true
        _add.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panning(_:))))
        
        refresh()
    }
    
    override func refresh() {
        super.refresh()
        scroll.views.filter { $0 is Task }.forEach { $0.removeFromSuperview() }
        rename()
        empty?.removeFromSuperview()
        if app.session.cards(app.project, list: 0) + app.session.cards(app.project, list: 1) == 0 {
            let empty = Label(.key("Todo.empty"), 15, .medium, UIColor(named: "haze")!)
            scroll.add(empty)
            self.empty = empty

            empty.topAnchor.constraint(equalTo: _add.bottomAnchor, constant: 40).isActive = true
            empty.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true

            scroll.bottom.constraint(greaterThanOrEqualTo: empty.bottomAnchor, constant: 40).isActive = true
        } else {
            var top: NSLayoutYAxisAnchor?
            [0, 1].forEach { list in
                (0 ..< app.session.cards(app.project, list: list)).forEach {
                    let task = Task($0, list: list, self)
                    scroll.add(task)

                    if top == nil {
                        task.topAnchor.constraint(equalTo: _add.bottomAnchor, constant: 10).isActive = true
                    } else {
                        task.topAnchor.constraint(equalTo: top!).isActive = true
                    }
                    task.leftAnchor.constraint(equalTo: scroll.left).isActive = true
                    task.rightAnchor.constraint(equalTo: scroll.right).isActive = true
                    top = task.bottomAnchor
                }
            }
            scroll.bottom.constraint(greaterThanOrEqualTo: top!, constant: 20).isActive = true
        }
        isUserInteractionEnabled = true
    }
    
    private func rename() {
        self.name?.removeFromSuperview()
        let string = app.session.name(app.project)
        let name = Label(string.mark {
            switch $0 {
            case .plain: return (.init(string[$1]), 26, .heavy, UIColor(named: "haze")!.withAlphaComponent(0.7))
            case .emoji: return (.init(string[$1]), 40, .regular, UIColor(named: "haze")!.withAlphaComponent(0.7))
            case .bold: return (.init(string[$1]), 30, .heavy, UIColor(named: "haze")!.withAlphaComponent(0.7))
            }
        })
        name.accessibilityLabel = .key("Project")
        name.accessibilityValue = string
        addSubview(name)
        self.name = name
        
        name.topAnchor.constraint(equalTo: scroll.top, constant: 25).isActive = true
        name.leftAnchor.constraint(equalTo: scroll.left, constant: 25).isActive = true
        name.widthAnchor.constraint(lessThanOrEqualToConstant: 400).isActive = true
        
        _more.leftAnchor.constraint(equalTo: name.rightAnchor, constant: 20).isActive = true
        _more.centerYAnchor.constraint(equalTo: name.centerYAnchor).isActive = true
        
        _add.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 20).isActive = true
    }
    
    @objc private func add() {
        app.present(Detail(self), animated: true)
    }
    
    @objc private func panning(_ gesture: UIPanGestureRecognizer) {
        guard let task = scroll.content.hitTest(gesture.location(in: scroll.content), with: nil) as? Task else {
            deleting?.undelete()
            return
        }
        if deleting != nil && task != deleting {
            task.delta = gesture.translation(in: task).x
            deleting?.undelete()
        }
        deleting = task
        switch gesture.state {
        case .changed:
            task.delete(gesture.translation(in: task).x)
        case .ended, .cancelled, .failed:
            task.undelete()
            deleting = nil
        case .began, .possible: break
        @unknown default: break
        }
    }
}
