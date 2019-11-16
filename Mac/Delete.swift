import AppKit

class Delete: Window.Modal {
    final class Board: Delete {
        override init() {
            super.init()
//            heading.stringValue = .key("Delete.title.\(app.mode.rawValue)")
        }
        
        override func confirm() {
//            app.session.delete(app.project)
//            switch app.mode {
//            case .todo: app.main.todo()
//            case .shopping: app.main.shopping()
//            default: app.main.kanban()
//            }
//            app.alert(.key("Delete.deleted.\(app.mode.rawValue)"), message: app.session.name(app.project))
            super.confirm()
        }
    }
    
    final class Card: Delete {
        private weak var base: Base.View?
        private let index: Int
        private let list: Int
        
        init(_ base: Base.View, index: Int, list: Int) {
            self.index = index
            self.list = list
            self.base = base
            super.init()
//            heading.stringValue = .key("Delete.title.card.\(app.mode.rawValue)")
        }
        
        override func confirm() {
//            app.alert(.key("Delete.deleted.card.\(app.mode.rawValue)"), message: app.session.content(app.project, list: list, card: index))
//            app.session.delete(app.project, list: list, card: index)
            base?.refresh()
            super.confirm()
        }
    }
    
    final class Product: Delete {
        private weak var shopping: Shopping?
        private let index: Int
        
        init(_ shopping: Shopping, index: Int) {
            self.index = index
            self.shopping = shopping
            super.init()
//            heading.stringValue = .key("Delete.title.card.\(app.mode.rawValue)")
        }
        
        override func confirm() {
//            let product = app.session.product(app.project, index: index)
//            app.alert(.key("Delete.deleted.card.\(app.mode.rawValue)"), message: product.0 + " " + product.1)
//            app.session.delete(app.project, product: index)
//            shopping?.refresh()
//            super.confirm()
        }
    }
    
    private weak var heading: Label!
    
    private init() {
        super.init(260, 200)
        
        let heading = Label("", 18, .bold, .init(white: 1, alpha: 0.8))
        self.heading = heading
        
        let _confirm = Control(.key("Delete.confirm"), self, #selector(confirm), .black, .white)
        let _cancel = Control(.key("Delete.cancel"), self, #selector(close), .clear, .init(white: 1, alpha: 0.6))
        
        [heading, _confirm, _cancel].forEach {
            contentView!.addSubview($0)
            $0.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        }
        
        heading.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 50).isActive = true
        
        _confirm.topAnchor.constraint(equalTo: heading.bottomAnchor, constant: 25).isActive = true
        _confirm.widthAnchor.constraint(equalToConstant: 140).isActive = true
        
        _cancel.topAnchor.constraint(equalTo: _confirm.bottomAnchor, constant: 10).isActive = true
        _cancel.widthAnchor.constraint(equalToConstant: 140).isActive = true
    }
    
    @objc private func confirm() {
        close()
    }
}
