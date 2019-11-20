import AppKit

final class Base: NSView {
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func refresh() {
        if app.project == nil {
            if app.session.projects().isEmpty {
                clear()
            } else {
                validate(Detail.self)
            }
        } else {
            switch app.session.mode(app.project!) {
            case .kanban: validate(Kanban.self)
            case .todo: validate(Todo.self)
            case .shopping: validate(Shopping.self)
            case .notes: validate(Notes.self)
            default: app.project = nil
            }
        }
    }
    
    private func validate<T>(_ type: T.Type) where T: View {
        if let view = subviews.first as? T {
            view.refresh()
        } else {
            show(T())
        }
    }
    
    private func show(_ view: View) {
        let previous = subviews.first as? View
        addSubview(view)
        
        view.top = view.topAnchor.constraint(equalTo: topAnchor, constant: -bounds.height)
        view.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        layoutSubtreeIfNeeded()
        window!.makeFirstResponder(view)
        
        view.top.constant = 0
        previous?.top.constant = bounds.height
        
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.4
            $0.allowsImplicitAnimation = true
            layoutSubtreeIfNeeded()
        }) {
            previous?.removeFromSuperview()
            app.main.bar.find?.view = view
        }
    }
    
    private func clear() {
        subviews.forEach { $0.removeFromSuperview() }
    }
}
