import AppKit

class More: Modal {
    final class Main: More {
        override init() {
            super.init()
            let _spell = Check(.key("More.spell"), target: self, action: #selector(spell(_:)))
            _spell.on = app.session.spell
            add(_spell)
            
            _spell.topAnchor.constraint(equalTo: _title.bottomAnchor, constant: 40).isActive = true
        }
        
        @objc private func spell(_ check: Check) {
            app.session.spell(check.on)
            if app.main.base?.subviews.first is Kanban {
                app.main.project(app.project)
            }
        }
    }
    
    final class Project: More {
        override init() {
            super.init()
            let _delete = Control(.key("More.delete.\(app.mode.rawValue)"), self, #selector(delete), .black, .init(white: 1, alpha: 0.6))
            add(_delete)
            
            _delete.topAnchor.constraint(equalTo: _title.bottomAnchor, constant: 40).isActive = true
        }
        
        @objc private func delete() {
            close()
            app.runModal(for: Delete.Board())
        }
    }
    
    private weak var _title: Label!
    
    private init() {
        super.init(400, 280)
        
        let _done = Control(.key("More.done"), self, #selector(close), NSColor(named: "haze")!.cgColor, .black)
        let _title = Label(.key("More.title"), 20, .bold, .init(white: 1, alpha: 0.2))
        self._title = _title
        
        [_title, _done].forEach(add(_:))
        
        _title.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 50).isActive = true
        _done.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -40).isActive = true
    }
    
    private func add(_ view: NSView) {
        contentView!.addSubview(view)
        view.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        view.widthAnchor.constraint(equalToConstant: 200).isActive = true
    }
}
