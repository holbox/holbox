import UIKit

final class More: Edit {
    private weak var base: Base.View!
    private weak var _delete: Capsule!
    
    required init?(coder: NSCoder) { nil }
    init(_ base: Base.View) {
        super.init()
        self.base = base
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        text.text = app.session.name(app.project)
        
        let _delete = Capsule(.key("More.delete.\(app.mode.rawValue)"), self, #selector(remove), UIColor(named: "background")!, UIColor(named: "haze")!)
        view.addSubview(_delete)
        self._delete = _delete
        
        _delete.topAnchor.constraint(equalTo: done.topAnchor).isActive = true
        _delete.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 15).isActive = true
    }
    
    override func textViewDidEndEditing(_: UITextView) {
        app.session.name(app.project, name: text.text)
        base.refresh()
    }
    
    @objc private func remove() {
        app.win.endEditing(true)
        let alert = UIAlertController(title: .key("Delete.title.\(app.mode.rawValue)"), message: nil, preferredStyle: .actionSheet)
        alert.addAction(.init(title: .key("Delete.confirm"), style: .destructive) { [weak self] _ in
            self?.presentingViewController!.dismiss(animated: true) {
                app.session.delete(app.project)
                switch app.mode {
                case .todo: app.main.todo()
                case .shopping: app.main.shopping()
                default: app.main.kanban()
                }
            }
        })
        alert.addAction(.init(title: .key("Delete.cancel"), style: .cancel))
        alert.popoverPresentationController?.sourceView = _delete
        present(alert, animated: true)
    }
}
