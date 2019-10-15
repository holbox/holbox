import AppKit

class Delete: Modal {
    final class Board: Delete {
        override init() {
            super.init()
            heading.stringValue = .key("Delete.title.\(app.mode.rawValue)")
        }
        
        override func confirm() {
            app.session.delete(app.project)
            switch app.mode {
            case .kanban: app.main.kanban()
            case .todo: app.main.todo()
            case .shopping: app.main.shopping()
            default: break
            }
            app.alert(.key("Delete.deleted.\(app.mode.rawValue)"), message: app.session.name(app.project))
            super.confirm()
        }
    }
    
    final class Card: Delete {
        private let index: Int
        private let list: Int
        
        init(_ index: Int, list: Int) {
            self.index = index
            self.list = list
            super.init()
            heading.stringValue = .key("Delete.title.card.\(app.mode.rawValue)")
        }
        
        override func confirm() {
            app.session.delete(app.project, list: list, card: index)
            app.main.project(app.project)
            super.confirm()
        }
    }
    
    private weak var heading: Label!
    
    private init() {
        super.init(320, 180)
        
        let heading = Label()
        heading.font = .systemFont(ofSize: 20, weight: .bold)
        heading.textColor = .init(white: 1, alpha: 0.3)
        contentView!.addSubview(heading)
        self.heading = heading
        
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
        
        heading.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 50).isActive = true
        heading.leftAnchor.constraint(equalTo: _cancel.leftAnchor, constant: 25).isActive = true
        
        _confirm.leftAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        _cancel.rightAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
    }
    
    @objc private func confirm() {
        close()
    }
}
