import AppKit

final class Add: Window {
    init() {
        super.init(400, 500, mask: [])
        _close.isHidden = true
        _minimise.isHidden = true
        _zoom.isHidden = true
        
        let icon = Image("new")
        
        let title = Label(.key("Add.title.\(main.mode.rawValue)"))
        title.font = .systemFont(ofSize: 30, weight: .bold)
        title.textColor = .white
        
        let subtitle = Label(.key("Add.subtitle.\(main.mode.rawValue)") + .key("Add.subtitle.bottom"))
        subtitle.font = .systemFont(ofSize: 14, weight: .regular)
        subtitle.alignment = .center
        subtitle.textColor = .init(white: 0.6, alpha: 1)
        
        let available = Label("\(max(session.capacity - session.count, 0))")
        available.font = .systemFont(ofSize: 50, weight: .bold)
        available.textColor = .haze
        
        let confirm = Control(.key("Add.title.\(main.mode.rawValue)"), target: self, action: #selector(self.confirm))
        confirm.layer!.backgroundColor = .haze
        confirm.label.textColor = .black
        
        let cancel = Control(.key("Add.cancel"), target: self, action: #selector(close))
        cancel.label.textColor = .init(white: 0.7, alpha: 1)
        
        [icon, title, subtitle, available, confirm, cancel].forEach {
            contentView!.addSubview($0)
            
            $0.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        }
        
        icon.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 80).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 60).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        title.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 30).isActive = true
        
        subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10).isActive = true
        
        available.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 30).isActive = true
        
        confirm.widthAnchor.constraint(equalToConstant: 260).isActive = true
        confirm.heightAnchor.constraint(equalToConstant: 40).isActive = true
        confirm.bottomAnchor.constraint(equalTo: cancel.topAnchor, constant: -20).isActive = true
        
        cancel.widthAnchor.constraint(equalToConstant: 260).isActive = true
        cancel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        cancel.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -20).isActive = true
    }
    
    override func keyDown(with: NSEvent) {
        switch with.keyCode {
        case 36: confirm()
        case 53: close()
        default: super.keyDown(with: with)
        }
    }
    
    override func close() {
        super.close()
        app.stopModal()
    }
    
    @objc private func confirm() {
        
    }
}
