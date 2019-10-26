import AppKit

final class Add: Window.Modal {
    private weak var _confirm: Control!
    private weak var _purchases: Control!
    
    init() {
        super.init(400, 600)
        let icon = Image("new")
        contentView!.addSubview(icon)
        
        let title = Label(.key("Add.title.\(app.mode.rawValue)"), 25, .bold, .white)
        contentView!.addSubview(title)
        
        let subtitle = Label(.key("Add.subtitle.\(app.mode.rawValue)") + .key("Add.subtitle.bottom"), 14, .regular, .init(white: 1, alpha: 0.6))
        subtitle.alignment = .center
        contentView!.addSubview(subtitle)
        
        let available = Label("\(app.session.available)", 40, .light, NSColor(named: "haze")!)
        contentView!.addSubview(available)
        
        let capacity = Label([(.key("Add.projects.title"), 14, .bold, .init(white: 1, alpha: 0.4)),
                              ("\(app.session.count)", 16, .light, .init(white: 1, alpha: 0.8)),
                              (.key("Add.capacity.title"), 14, .bold, .init(white: 1, alpha: 0.4)),
                              ("\(app.session.capacity)", 16, .light, .init(white: 1, alpha: 0.8))])
        contentView!.addSubview(capacity)
        
        let info = Label(.key("Add.info"), 14, .regular, .white)
        contentView!.addSubview(info)
        
        let _confirm = Control(.key("Add.title.\(app.mode.rawValue)"), self, #selector(confirm), NSColor(named: "haze")!.cgColor, .black)
        contentView!.addSubview(_confirm)
        self._confirm = _confirm
        
        let _purchases = Control(.key("Add.purchases"), self, #selector(purchases), NSColor(named: "haze")!.cgColor, .black)
        contentView!.addSubview(_purchases)
        self._purchases = _purchases
        
        let cancel = Control(.key("Add.cancel"), self, #selector(close), .clear, .init(white: 1, alpha: 0.6))
        contentView!.addSubview(cancel)
        
        icon.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 70).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 60).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 60).isActive = true
        icon.rightAnchor.constraint(equalTo: contentView!.centerXAnchor, constant: -50).isActive = true
        
        title.centerYAnchor.constraint(equalTo: icon.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 10).isActive = true
        
        subtitle.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 30).isActive = true
        subtitle.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        
        available.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 30).isActive = true
        available.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        
        capacity.topAnchor.constraint(equalTo: available.bottomAnchor, constant: 10).isActive = true
        capacity.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        
        info.widthAnchor.constraint(equalToConstant: 250).isActive = true
        info.topAnchor.constraint(equalTo: capacity.bottomAnchor, constant: 20).isActive = true
        info.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        
        _confirm.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        _confirm.widthAnchor.constraint(equalToConstant: 140).isActive = true
        _confirm.bottomAnchor.constraint(equalTo: cancel.topAnchor, constant: -10).isActive = true
        
        _purchases.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        _purchases.widthAnchor.constraint(equalToConstant: 140).isActive = true
        _purchases.bottomAnchor.constraint(equalTo: cancel.topAnchor, constant: -10).isActive = true
        
        cancel.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        cancel.widthAnchor.constraint(equalToConstant: 140).isActive = true
        cancel.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -40).isActive = true
        
        if app.session.available > 0 {
            info.isHidden = true
            _purchases.isHidden = true
            _purchases.target = nil
            
        } else {
            _confirm.isHidden = true
            _confirm.target = nil
        }
    }
    
    @objc private func confirm() {
        _confirm.target = nil
        app.session.add(app.mode)
        app.main.project(0)
        close()
    }
    
    @objc private func purchases() {
        _purchases.target = nil
        app.main.shop()
        close()
    }
}
