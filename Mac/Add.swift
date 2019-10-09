import AppKit

final class Add: Window {
    init() {
        super.init(400, 500, mask: [])
        _close.isHidden = true
        _minimise.isHidden = true
        _zoom.isHidden = true
        
        let icon = Image("new")
        
        let title = Label(.key("Add.title"))
        title.font = .systemFont(ofSize: 24, weight: .bold)
        title.textColor = .white
        
        let subtitle = Label(.key("Add.subtitle"))
        subtitle.font = .systemFont(ofSize: 14, weight: .regular)
        subtitle.alignment = .center
        subtitle.textColor = .init(white: 0.7, alpha: 1)
        
        let confirm = Control(.key("Add.confirm"), target: self, action: #selector(close))
        confirm.layer!.backgroundColor = .haze
        confirm.label.textColor = .black
        
        let cancel = Control(.key("Add.cancel"), target: self, action: #selector(close))
        cancel.label.textColor = .init(white: 0.7, alpha: 1)
        
        [icon, title, subtitle, confirm, cancel].forEach {
            contentView!.addSubview($0)
            
            $0.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        }
        
        icon.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 50).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 60).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        title.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 30).isActive = true
        
        subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10).isActive = true
        
        confirm.widthAnchor.constraint(equalToConstant: 260).isActive = true
        confirm.heightAnchor.constraint(equalToConstant: 40).isActive = true
        confirm.bottomAnchor.constraint(equalTo: cancel.topAnchor, constant: -20).isActive = true
        
        cancel.widthAnchor.constraint(equalToConstant: 260).isActive = true
        cancel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        cancel.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -40).isActive = true
    }
    
    override func close() {
        super.close()
        app.stopModal()
    }
}
