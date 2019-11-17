import AppKit

class More: Window.Modal {
    final class Main: More {
        override init() {
            super.init()
            let _spell = Check(.key("More.spell"), target: self, action: #selector(spell(_:)))
            _spell.on = app.session.spell
            contentView!.addSubview(_spell)
            
            _spell.topAnchor.constraint(equalTo: _title.bottomAnchor, constant: 35).isActive = true
            _spell.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        }
        
        @objc private func spell(_ check: Check) {
            app.session.spell(check.on)
            app.main.refresh()
        }
    }
    
    
    private weak var _title: Label!
    
    private init() {
        super.init(260, 280)
        
        let _title = Label(.key("More.title"), 18, .bold, .init(white: 1, alpha: 0.4))
        contentView!.addSubview(_title)
        self._title = _title
        
        let _done = Control(.key("More.done"), self, #selector(close), NSColor(named: "haze")!.cgColor, .black)
        contentView!.addSubview(_done)
        
        _title.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 50).isActive = true
        _title.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        
        _done.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -50).isActive = true
        _done.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        _done.widthAnchor.constraint(equalToConstant: 140).isActive = true
    }
}
