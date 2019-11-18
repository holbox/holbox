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
        private let index: Int
        private let list: Int
        
        init(_ index: Int, list: Int) {
            self.index = index
            self.list = list
            super.init()
            
            let title = Label([(.key("Delete.title") + "\n\n", 18, .bold, NSColor(named: "haze")!),
                               (app.session.content(app.project!, list: list, card: index), 16, .regular, NSColor(named: "haze")!)])
            title.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
            contentView!.addSubview(title)
            
            title.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 40).isActive = true
            title.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 70).isActive = true
            title.rightAnchor.constraint(lessThanOrEqualTo: contentView!.rightAnchor, constant: -70).isActive = true
            title.bottomAnchor.constraint(lessThanOrEqualTo: contentView!.bottomAnchor, constant: -120).isActive = true
        }
        
        override func confirm() {
            app.alert(.key("Delete.done"), message: app.session.content(app.project!, list: list, card: index))
            app.session.delete(app.project!, list: list, card: index)
            super.confirm()
        }
    }
    
    final class Product: Delete {
        private let index: Int
        
        init(_ index: Int) {
            self.index = index
            super.init()
            
            let product = app.session.product(app.project!, index: index)
            let title = Label([(.key("Delete.title") + "\n\n", 18, .bold, NSColor(named: "haze")!),
                               (product.0 + " " + product.1, 16, .regular, NSColor(named: "haze")!)])
            title.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
            contentView!.addSubview(title)
            
            title.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 40).isActive = true
            title.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 70).isActive = true
            title.rightAnchor.constraint(lessThanOrEqualTo: contentView!.rightAnchor, constant: -70).isActive = true
            title.bottomAnchor.constraint(lessThanOrEqualTo: contentView!.bottomAnchor, constant: -120).isActive = true
        }
        
        override func confirm() {
            let product = app.session.product(app.project!, index: index)
            app.alert(.key("Delete.done"), message: product.0 + " " + product.1)
            app.session.delete(app.project!, product: index)
            super.confirm()
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
