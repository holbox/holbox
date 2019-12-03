import UIKit

final class Todo: View, UITextViewDelegate {
    private weak var deleting: Task?
    private weak var new: Text!
    private weak var scroll: Scroll!
    private weak var _add: Button!
    
    required init?(coder: NSCoder) { nil }
    required init() {
        super.init()
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let new = Text()
        new.isScrollEnabled = false
        new.textContainerInset = .init(top: 20, left: 20, bottom: 20, right: 20)
        new.accessibilityLabel = .key("Project")
        new.font = .systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 18), weight: .medium)
        (new.textStorage as! Storage).fonts = [
            .plain: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 18), weight: .bold), .white),
            .emoji: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 32), weight: .regular), .white),
            .bold: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 22), weight: .bold), UIColor(named: "haze")!),
            .tag: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 16), weight: .bold), UIColor(named: "haze")!)]
        new.delegate = self
        (new.layoutManager as! Layout).padding = 2
        scroll.add(new)
        self.new = new
        
        let _add = Button("plus", target: self, action: #selector(add))
        scroll.add(_add)
        self._add = _add
        
        scroll.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        scroll.width.constraint(equalTo: safeAreaLayoutGuide.widthAnchor).isActive = true
        scroll.height.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.heightAnchor).isActive = true
        
        new.topAnchor.constraint(equalTo: scroll.top).isActive = true
        new.leftAnchor.constraint(equalTo: scroll.left).isActive = true
        new.rightAnchor.constraint(equalTo: scroll.right).isActive = true
        
        _add.topAnchor.constraint(equalTo: new.bottomAnchor, constant: -20).isActive = true
        _add.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
        _add.widthAnchor.constraint(equalToConstant: 70).isActive = true
        _add.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panning(_:))))
        
        refresh()
    }
    
    override func refresh() {
        isUserInteractionEnabled = false
        scroll.views.filter { $0 is Task || $0 is Chart }.forEach { $0.removeFromSuperview() }
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
        if top != nil {
            scroll.bottom.constraint(greaterThanOrEqualTo: top!, constant: 20).isActive = true
        }
        scroll.content.layoutIfNeeded()
        isUserInteractionEnabled = true
    }
    
    @objc private func add() {
        if new.text.isEmpty {
            new.becomeFirstResponder()
        } else {
            if !new.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                app.session.add(app.project, list: 0, content: new.text)
                app.alert(.key("Task"), message: new.text)
                refresh()
            }
            new.text = ""
            app.window!.endEditing(true)
        }
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.scroll.contentOffset.y = 0
        }
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
