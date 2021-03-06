import holbox
import UIKit

final class Add: Modal {
    private weak var name: Label!
    private weak var selected: Button! {
        didSet {
            oldValue?.icon.alpha = 0.4
            oldValue?.layer.borderColor = .clear
            selected.layer.borderColor = .haze()
            selected.icon.alpha = 1
        }
    }
    private var mode = Mode.off
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let scroll = Scroll()
        view.addSubview(scroll)
        
        let icon = Image("new")
        scroll.add(icon)
        
        let title = Label([(.key("Add.title") + "\n", .medium(18), .haze()),
                           (.key("Add.subtitle"), .light(14), .haze(0.8))])
        scroll.add(title)
        
        let available = Label([(.key("Add.available") + "\n\n", .light(18), .haze(0.6)),
                               ("\(app.session.available)", .medium(32), .haze())], align: .center)
        scroll.add(available)
        
        let projects = Label([(.key("Add.projects"), .light(14), .haze(0.6)),
                              ("\n\n\(app.session.count)", .medium(18), .haze())], align: .center)
        scroll.add(projects)
        
        let capacity = Label([(.key("Add.capacity"), .light(14), .haze(0.6)),
                              ("\n\n\(app.session.capacity)", .medium(18), .haze())], align: .center)
        scroll.add(capacity)
        
        let cancel = Control(.key("Add.cancel"), self, #selector(close), .clear, .haze())
        scroll.add(cancel)
        
        scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        scroll.right.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        scroll.bottom.constraint(equalTo: cancel.bottomAnchor, constant: 20).isActive = true
        
        icon.topAnchor.constraint(equalTo: scroll.top, constant: 50).isActive = true
        icon.leftAnchor.constraint(equalTo: scroll.left, constant: 100).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 52).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 52).isActive = true

        title.topAnchor.constraint(equalTo: icon.topAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 10).isActive = true
        
        available.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 40).isActive = true
        available.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
        
        projects.centerYAnchor.constraint(equalTo: available.centerYAnchor).isActive = true
        projects.rightAnchor.constraint(equalTo: available.leftAnchor, constant: -20).isActive = true
        
        capacity.centerYAnchor.constraint(equalTo: available.centerYAnchor).isActive = true
        capacity.leftAnchor.constraint(equalTo: available.rightAnchor, constant: 20).isActive = true
        
        cancel.widthAnchor.constraint(equalToConstant: 110).isActive = true
        cancel.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
        
        if app.session.available > 0 {
            let _kanban = Button("kanban", target: self, action: #selector(kanban(_:)))
            _kanban.accessibilityLabel = .key("Add.kanban")
            
            let _todo = Button("todo", target: self, action: #selector(todo(_:)))
            _todo.accessibilityLabel = .key("Add.todo")
            
            let _shopping = Button("shopping", target: self, action: #selector(shopping(_:)))
            _shopping.accessibilityLabel = .key("Add.shopping")
            
            let _notes = Button("notes", target: self, action: #selector(notes(_:)))
            _notes.accessibilityLabel = .key("Add.notes")
            
            let name = Label("", .bold(18), .haze())
            scroll.add(name)
            self.name = name
            
            let _confirm = Control(.key("Add.confirm"), self, #selector(add), .haze(), .black)
            scroll.add(_confirm)
            
            var left: NSLayoutXAxisAnchor?
            [_kanban, _todo, _shopping, _notes].forEach {
                $0.icon.alpha = 0.4
                $0.layer.cornerRadius = 4
                $0.layer.borderWidth = 1
                $0.layer.borderColor = .clear
                scroll.add($0)
                
                $0.widthAnchor.constraint(equalToConstant: 60).isActive = true
                $0.heightAnchor.constraint(equalToConstant: 60).isActive = true
                $0.topAnchor.constraint(equalTo: available.bottomAnchor, constant: 60).isActive = true
                
                if left == nil {
                    $0.rightAnchor.constraint(equalTo: scroll.centerX, constant: -90).isActive = true
                } else {
                    $0.leftAnchor.constraint(equalTo: left!, constant: 20).isActive = true
                }
                
                left = $0.rightAnchor
            }
            
            name.topAnchor.constraint(equalTo: available.bottomAnchor, constant: 160).isActive = true
            name.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
            
            _confirm.widthAnchor.constraint(equalToConstant: 110).isActive = true
            _confirm.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
            _confirm.topAnchor.constraint(equalTo: available.bottomAnchor, constant: 230).isActive = true
            
            cancel.topAnchor.constraint(equalTo: _confirm.bottomAnchor).isActive = true
            
            kanban(_kanban)
        } else {
            let info = Label(.key("Add.info"), .light(16), .white)
            scroll.add(info)
            
            let _purchases = Control(.key("Add.purchases"), self, #selector(purchases), .haze(), .black)
            scroll.add(_purchases)
            
            info.topAnchor.constraint(equalTo: available.bottomAnchor, constant: 30).isActive = true
            info.leftAnchor.constraint(equalTo: scroll.left, constant: 50).isActive = true
            info.rightAnchor.constraint(lessThanOrEqualTo: scroll.right, constant: -50).isActive = true
            info.widthAnchor.constraint(lessThanOrEqualToConstant: 400).isActive = true
            
            _purchases.widthAnchor.constraint(equalToConstant: 110).isActive = true
            _purchases.topAnchor.constraint(equalTo: info.bottomAnchor, constant: 60).isActive = true
            _purchases.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
            
            cancel.topAnchor.constraint(equalTo: _purchases.bottomAnchor).isActive = true
        }
    }
    
    @objc private func add() {
        app.project = app.session.add(mode)
        close()
    }
    
    @objc private func kanban(_ button: Button) {
        mode = .kanban
        name.text = .key("Add.kanban")
        selected = button
    }
    
    @objc private func todo(_ button: Button) {
        mode = .todo
        name.text = .key("Add.todo")
        selected = button
    }
    
    @objc private func shopping(_ button: Button) {
        mode = .shopping
        name.text = .key("Add.shopping")
        selected = button
    }
    
    @objc private func notes(_ button: Button) {
        mode = .notes
        name.text = .key("Add.notes")
        selected = button
    }
    
    @objc private func purchases() {
        close()
        app.main.bar.shop()
    }
}
