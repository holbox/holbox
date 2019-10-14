import AppKit

final class Delete: Modal {
    init() {
        super.init(320, 180)
        
        let title = Label(.key("Delete.title.\(app.mode.rawValue)"))
        title.font = .systemFont(ofSize: 20, weight: .bold)
        title.textColor = .init(white: 1, alpha: 0.5)
        contentView!.addSubview(title)
        
        let _confirm = Control(.key("Delete.confirm"), target: self, action: #selector(confirm))
        _confirm.label.textColor = .haze
        _confirm.layer!.backgroundColor = .black
        
        let _cancel = Control(.key("Delete.cancel"), target: self, action: #selector(close))
        _cancel.label.textColor = .white
        
        [_confirm, _cancel].forEach {
            contentView!.addSubview($0)
            
            $0.widthAnchor.constraint(equalToConstant: 100).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
            $0.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -40).isActive = true
        }
        
        title.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 50).isActive = true
        title.leftAnchor.constraint(equalTo: _confirm.leftAnchor, constant: 2).isActive = true
        
        _confirm.rightAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        _cancel.leftAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
    }
    
    @objc private func confirm() {
        app.session.delete(app.project)
        switch app.mode {
        case .kanban: app.main.kanban()
        case .todo: app.main.todo()
        case .shopping: app.main.shopping()
        default: break
        }
        close()
        app.alert(.key("Delete.deleted.\(app.mode.rawValue)"), message: app.session.name(app.project))
    }
}
