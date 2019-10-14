import AppKit

final class More: Modal {
    init() {
        super.init(400, 300)
        
        let _delete = Control(.key("More.delete.\(main.mode.rawValue)"), target: self, action: #selector(delete))
        _delete.label.textColor = .init(white: 1, alpha: 0.4)
        
        let _done = Control(.key("More.done"), target: self, action: #selector(close))
        _done.label.textColor = .black
        _done.layer!.backgroundColor = .haze
        
        [_delete, _done].forEach {
            contentView!.addSubview($0)
            
            $0.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        }
        
        _done.widthAnchor.constraint(equalToConstant: 200).isActive = true
        _done.heightAnchor.constraint(equalToConstant: 40).isActive = true
        _done.bottomAnchor.constraint(equalTo: _delete.topAnchor, constant: -20).isActive = true
        
        _delete.widthAnchor.constraint(equalToConstant: 200).isActive = true
        _delete.heightAnchor.constraint(equalToConstant: 40).isActive = true
        _delete.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -20).isActive = true
    }
    
    @objc private func delete() {
        close()
        app.runModal(for: Delete())
    }
}
