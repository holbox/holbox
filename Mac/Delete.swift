import AppKit

class Delete: Window.Modal {
    final class Project: Delete {
        private let index: Int
        
        init(_ index: Int) {
            self.index = index
            super.init()
            
            let title = Label([(.key("Delete.title") + "\n\n", 18, .bold, NSColor(named: "haze")!),
                               (app.session.name(index), 16, .regular, NSColor(named: "haze")!)])
            contentView!.addSubview(title)
            
            title.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 40).isActive = true
            title.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 70).isActive = true
            title.rightAnchor.constraint(lessThanOrEqualTo: contentView!.rightAnchor, constant: -70).isActive = true
        }
        
        override func confirm() {
            app.alert(.key("Delete.done"), message: app.session.name(index))
            app.session.delete(index)
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
    
    private init() {
        super.init(280, 260)
        
        let _confirm = Control(.key("Delete.confirm"), self, #selector(confirm), NSColor(named: "haze")!.cgColor, .black)
        let _cancel = Control(.key("Delete.cancel"), self, #selector(close), .clear, NSColor(named: "haze")!)
        
        [_confirm, _cancel].forEach {
            contentView!.addSubview($0)
            $0.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 140).isActive = true
        }
        
        _confirm.bottomAnchor.constraint(equalTo: _cancel.topAnchor, constant: -20).isActive = true
        _cancel.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -20).isActive = true
    }
    
    @objc private func confirm() {
        close()
        app.main.refresh()
    }
}
