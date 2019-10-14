import AppKit

final class Add: Modal {
    private weak var available: Label!
    private weak var _confirm: Control!
    
    init() {
        super.init(400, 500)
        let icon = Image("new")
        
        let title = Label(.key("Add.title.\(app.mode.rawValue)"))
        title.font = .systemFont(ofSize: 20, weight: .bold)
        title.textColor = .white
        
        let subtitle = Label(.key("Add.subtitle.\(app.mode.rawValue)") + .key("Add.subtitle.bottom"))
        subtitle.font = .systemFont(ofSize: 14, weight: .regular)
        subtitle.alignment = .center
        subtitle.textColor = .init(white: 1, alpha: 0.4)
        
        let circle = NSView()
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.wantsLayer = true
        circle.layer!.backgroundColor = .haze
        circle.layer!.cornerRadius = 30
        
        let available = Label("\(app.session.available)")
        available.font = .systemFont(ofSize: 26, weight: .bold)
        available.textColor = .black
        self.available = available
        
        let _confirm = Control(.key("Add.title.\(app.mode.rawValue)"), target: self, action: #selector(confirm))
        _confirm.layer!.backgroundColor = .haze
        _confirm.label.textColor = .black
        self._confirm = _confirm
        
        let cancel = Control(.key("Add.cancel"), target: self, action: #selector(close))
        cancel.label.textColor = .init(white: 1, alpha: 0.4)
        
        [icon, title, subtitle, circle, available, _confirm, cancel].forEach {
            contentView!.addSubview($0)
            
            $0.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        }
        
        icon.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 80).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 60).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        title.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 30).isActive = true
        
        subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10).isActive = true
        
        circle.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 30).isActive = true
        circle.widthAnchor.constraint(equalToConstant: 60).isActive = true
        circle.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        available.centerYAnchor.constraint(equalTo: circle.centerYAnchor).isActive = true
        
        _confirm.widthAnchor.constraint(equalToConstant: 200).isActive = true
        _confirm.heightAnchor.constraint(equalToConstant: 40).isActive = true
        _confirm.bottomAnchor.constraint(equalTo: cancel.topAnchor, constant: -20).isActive = true
        
        cancel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        cancel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        cancel.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -20).isActive = true
    }
    
    @objc private func confirm() {
        _confirm.target = nil
        available.stringValue = "\(app.session.available - 1)"
        app.session.add(app.mode)
        app.main.project(app.session.projects(app.mode).last!)
        close()
    }
}
