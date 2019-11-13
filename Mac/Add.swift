import AppKit

final class Add: Window.Modal {
    init() {
        super.init(420, 560)
        let icon = Image("new")
        contentView!.addSubview(icon)
        
        let title = Label([(.key("Add.title") + "\n", 25, .bold, .white),
                           (.key("Add.subtitle"), 14, .light, .init(white: 1, alpha: 0.6))])
        contentView!.addSubview(title)
        
        let available = Label([(.key("Add.available") + "\n", 20, .light, .init(white: 1, alpha: 0.4)),
                              ("\(app.session.available)", 40, .medium, NSColor(named: "haze")!)], align: .center)
        contentView!.addSubview(available)
        
        let projects = Label([(.key("Add.projects"), 14, .light, .init(white: 1, alpha: 0.4)),
                              ("\n\(app.session.count)", 22, .medium, NSColor(named: "haze")!)], align: .center)
        contentView!.addSubview(projects)
        
        let capacity = Label([(.key("Add.capacity"), 14, .light, .init(white: 1, alpha: 0.4)),
                              ("\n\(app.session.capacity)", 22, .medium, NSColor(named: "haze")!)], align: .center)
        contentView!.addSubview(capacity)
        
        let cancel = Control(.key("Add.cancel"), self, #selector(close), .clear, NSColor(named: "haze")!.withAlphaComponent(0.8))
        contentView!.addSubview(cancel)
        
        icon.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 50).isActive = true
        icon.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 50).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 80).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 80).isActive = true

        title.topAnchor.constraint(equalTo: icon.topAnchor, constant: 10).isActive = true
        title.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 10).isActive = true
        
        available.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 10).isActive = true
        available.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        
        projects.centerYAnchor.constraint(equalTo: available.centerYAnchor).isActive = true
        projects.rightAnchor.constraint(equalTo: available.leftAnchor, constant: -20).isActive = true
        
        capacity.centerYAnchor.constraint(equalTo: available.centerYAnchor).isActive = true
        capacity.leftAnchor.constraint(equalTo: available.rightAnchor, constant: 20).isActive = true
        
        cancel.widthAnchor.constraint(equalToConstant: 160).isActive = true
        cancel.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -40).isActive = true
        cancel.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        
        if app.session.available > 0 {
            let _kanban = Control(.key("Add.kanban"), self, #selector(kanban), NSColor(named: "haze")!.cgColor, .black)
            let _todo = Control(.key("Add.todo"), self, #selector(todo), NSColor(named: "haze")!.cgColor, .black)
            let _shopping = Control(.key("Add.shopping"), self, #selector(shopping), NSColor(named: "haze")!.cgColor, .black)
            let _notes = Control(.key("Add.notes"), self, #selector(notes), NSColor(named: "haze")!.cgColor, .black)
            
            var top: NSLayoutYAxisAnchor?
            [_kanban, _todo, _shopping, _notes].forEach {
                contentView!.addSubview($0)
                
                $0.widthAnchor.constraint(equalToConstant: 160).isActive = true
                $0.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
                
                if top == nil {
                    $0.topAnchor.constraint(equalTo: available.bottomAnchor, constant: 60).isActive = true
                } else {
                    $0.topAnchor.constraint(equalTo: top!, constant: 20).isActive = true
                }
                
                top = $0.bottomAnchor
            }
        } else {
            let info = Label(.key("Add.info"), 16, .regular, .white)
            contentView!.addSubview(info)
            
            let _purchases = Control(.key("Add.purchases"), self, #selector(purchases), NSColor(named: "haze")!.cgColor, .black)
            contentView!.addSubview(_purchases)
            
            info.topAnchor.constraint(equalTo: available.bottomAnchor, constant: 20).isActive = true
            info.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 50).isActive = true
            info.rightAnchor.constraint(lessThanOrEqualTo: contentView!.rightAnchor, constant: -50).isActive = true
            
            _purchases.widthAnchor.constraint(equalToConstant: 160).isActive = true
            _purchases.bottomAnchor.constraint(equalTo: cancel.topAnchor, constant: -10).isActive = true
            _purchases.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        }
    }
    
    private func add() {
        app.session.add(app.mode)
        app.main.project(0)
        close()
    }
    
    @objc private func kanban() {
        app.mode = .kanban
        add()
    }
    
    @objc private func todo() {
        app.mode = .todo
        add()
    }
    
    @objc private func shopping() {
        app.mode = .shopping
        add()
    }
    
    @objc private func notes() {
        app.mode = .notes
        add()
    }
    
    @objc private func purchases() {
        close()
        app.main.shop()
    }
}
