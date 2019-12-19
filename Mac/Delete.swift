import AppKit

class Delete: Modal {
    final class Project: Delete {
        private let index: Int
        
        init(_ index: Int) {
            self.index = index
            super.init()
            name.stringValue = app.session.name(index)
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
            name.stringValue = app.session.content(app.project, list: list, card: index)
        }
        
        override func confirm() {
            app.alert(.key("Delete.done"), message: app.session.content(app.project, list: list, card: index))
            app.session.delete(app.project, list: list, card: index)
            super.confirm()
        }
    }
    
    final class Product: Delete {
        private let index: Int
        
        init(_ index: Int) {
            self.index = index
            super.init()
            let product = app.session.product(app.project, index: index)
            name.stringValue = product.0 + " " + product.1
        }
        
        override func confirm() {
            let product = app.session.product(app.project, index: index)
            app.alert(.key("Delete.done"), message: product.0 + " " + product.1)
            app.session.delete(app.project, product: index)
            super.confirm()
        }
    }
    
    final class List: Delete {
        private let index: Int
        
        init(_ index: Int) {
            self.index = index
            super.init()
            name.stringValue = app.session.name(app.project, list: index)
        }
        
        override func confirm() {
            app.alert(.key("Delete.done"), message: app.session.name(app.project, list: index))
            app.session.delete(app.project, list: index)
            super.confirm()
        }
    }
    
    private weak var name: Label!
    
    private init() {
        super.init(260, 230)
        let icon = Image("trash")
        contentView!.addSubview(icon)
        
        let title = Label(.key("Delete.title"), .bold(14), .haze())
        contentView!.addSubview(title)
        
        let cancel = Control(.key("Delete.cancel"), self, #selector(close), .clear, .haze(0.7))
        contentView!.addSubview(cancel)
        
        let _confirm = Control(.key("Delete.confirm"), self, #selector(confirm), .haze(), .black)
        contentView!.addSubview(_confirm)
        
        let name = Label("", .regular(14), .haze())
        name.maximumNumberOfLines = 2
        contentView!.addSubview(name)
        self.name = name
        
        name.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10).isActive = true
        name.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 40).isActive = true
        name.rightAnchor.constraint(lessThanOrEqualTo: contentView!.rightAnchor, constant: -40).isActive = true
        
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
