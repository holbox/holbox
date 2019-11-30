import AppKit

class Delete: Modal {
    final class Project: Delete {
        private let index: Int
        
        init(_ index: Int) {
            self.index = index
            super.init()
            let name = Label(app.session.name(index), 18, .regular, NSColor(named: "haze")!)
            name.maximumNumberOfLines = 3
            contentView!.addSubview(name)
            
            name.topAnchor.constraint(equalTo: contentView!.centerYAnchor, constant: -60).isActive = true
            name.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 40).isActive = true
            name.rightAnchor.constraint(lessThanOrEqualTo: contentView!.rightAnchor, constant: -40).isActive = true
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
        super.init(260, 260)
        let icon = Image("trash")
        contentView!.addSubview(icon)
        
        let title = Label(.key("Delete.title"), 18, .bold, NSColor(named: "haze")!)
        contentView!.addSubview(title)
        
        let cancel = Control(.key("Delete.cancel"), self, #selector(close), .clear, NSColor(named: "haze")!.withAlphaComponent(0.7))
        contentView!.addSubview(cancel)
        
        let _confirm = Control(.key("Delete.confirm"), self, #selector(confirm), NSColor(named: "haze")!.cgColor, .black)
        contentView!.addSubview(_confirm)
        
        icon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 20).isActive = true
        icon.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 40).isActive = true
        icon.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 40).isActive = true
        
        title.centerYAnchor.constraint(equalTo: icon.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 2).isActive = true
        
        cancel.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        cancel.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -30).isActive = true
        cancel.widthAnchor.constraint(equalToConstant: 120).isActive = true
        
        _confirm.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        _confirm.bottomAnchor.constraint(equalTo: cancel.topAnchor, constant: -10).isActive = true
        _confirm.widthAnchor.constraint(equalToConstant: 120).isActive = true
    }
    
    @objc private func confirm() {
        close()
        app.main.refresh()
    }
}
