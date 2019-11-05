import UIKit

final class Todo: Base.View {
    private weak var deleting: Task?
    private weak var empty: Label?
    private weak var name: Label?
    private weak var scroll: Scroll!
    private weak var _add: Button!
    private weak var _more: Button!
    private var deleteX = CGFloat()
    
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
        rename()
        scroll.views.filter { $0 is Task }.forEach { $0.removeFromSuperview() }
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
                    let task = Task(app.session.content(app.project, list: list, card: $0), index: $0, list: list, self)
                    scroll.add(task)

                    task.leftAnchor.constraint(equalTo: scroll.left).isActive = true
                    task.rightAnchor.constraint(equalTo: scroll.right).isActive = true

                    if top == nil {
                        task.topAnchor.constraint(equalTo: _add.bottomAnchor, constant: 10).isActive = true
                    } else {
                        task.topAnchor.constraint(equalTo: top!).isActive = true
                    }

                    top = task.bottomAnchor
                }
            }
            scroll.bottom.constraint(greaterThanOrEqualTo: top!, constant: 20).isActive = true
        }
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
    
    private func undelete() {
        let deleting = self.deleting
        self.deleting = nil
        deleting?._deleteLeft.constant = 0
        UIView.animate(withDuration: 0.35) { [weak deleting] in
            deleting?.layoutIfNeeded()
        }
    }
    
    @objc private func add() {
//        if new.string.isEmpty {
//            if new.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//                new.string = ""
//                new.needsLayout = true
//            }
//            window!.makeFirstResponder(new)
//        } else {
//            window!.makeFirstResponder(self)
//        }
    }
    
    @objc private func panning(_ gesture: UIPanGestureRecognizer) {
        guard let task = scroll.content.hitTest(gesture.location(in: scroll.content), with: nil) as? Task else {
            undelete()
            return
        }
        if deleting != nil && task != deleting {
            deleteX = gesture.translation(in: task).x
            undelete()
        }
        deleting = task
        switch gesture.state {
        case .changed:
            task._deleteLeft.constant = min(0, gesture.translation(in: task).x - deleteX)
            if task._deleteLeft.constant < -130 {
                let alert = UIAlertController(title: .key("Delete.title.card.\(app.mode.rawValue)"), message: app.session.content(app.project, list: task.list, card: task.index), preferredStyle: .actionSheet)
                alert.addAction(.init(title: .key("Delete.confirm"), style: .destructive) { [weak self] _ in
                    task._deleteLeft.constant = -(self?.bounds.width ?? 0) - 100
                    UIView.animate(withDuration: 0.4, animations: { [weak task] in
                        task?.layoutIfNeeded()
                        task?.alpha = 0.4
                    }) { [weak self, weak task] _ in
                        guard let task = task else { return }
                        app.session.delete(app.project, list: task.list, card: task.index)
                        self?.refresh()
                    }
                })
                alert.addAction(.init(title: .key("Delete.cancel"), style: .cancel))
                alert.popoverPresentationController?.sourceView = task
                app.present(alert, animated: true)
            } else {
                UIView.animate(withDuration: 0.35) { [weak task] in
                    task?.layoutIfNeeded()
                }
            }
        case .ended, .cancelled, .failed:
            undelete()
        case .began, .possible:
            deleteX = 0
        @unknown default: break
        }
    }
}
