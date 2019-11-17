import AppKit

final class Shopping: Base.View, NSTextViewDelegate {
    private weak var emptyGrocery: Label?
    private weak var emptyProducts: Label?
    private weak var scroll: Scroll!
    private weak var stock: Scroll!
    private weak var name: Text!
    
    required init?(coder: NSCoder) { nil }
    required init() {
        super.init()
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let stock = Scroll()
        addSubview(stock)
        self.stock = stock
        
        let border = Border()
        addSubview(border)
        
        let name = Text(.Vertical(400), Block())
        name.setAccessibilityLabel(.key("Project"))
        (name.textStorage as! Storage).fonts = [.plain: (.systemFont(ofSize: 30, weight: .heavy), .white),
                                                .emoji: (NSFont(name: "Times New Roman", size: 40)!, .white),
                                                .bold: (.systemFont(ofSize: 34, weight: .heavy), .white)]
        name.delegate = self
        scroll.add(name)
        self.name = name
        
        let _more = Button("more", target: self, action: #selector(add))
        scroll.add(_more)
        
        let _add = Button("plusbig", target: self, action: #selector(add))
        addSubview(_add)
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: border.topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        scroll.right.constraint(equalTo: rightAnchor).isActive = true

        stock.heightAnchor.constraint(equalToConstant: 130).isActive = true
        stock.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stock.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
        stock.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        stock.right.constraint(greaterThanOrEqualTo: rightAnchor).isActive = true
        stock.bottom.constraint(equalTo: stock.bottomAnchor).isActive = true
        
        border.leftAnchor.constraint(equalTo: scroll.left).isActive = true
        border.rightAnchor.constraint(equalTo: _add.leftAnchor, constant: 12).isActive = true
        border.bottomAnchor.constraint(equalTo: stock.topAnchor).isActive = true
        
        name.topAnchor.constraint(equalTo: scroll.top, constant: 40).isActive = true
        name.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
        name.leftAnchor.constraint(greaterThanOrEqualTo: scroll.left).isActive = true
        name.rightAnchor.constraint(lessThanOrEqualTo: scroll.right).isActive = true
        
        _more.widthAnchor.constraint(equalToConstant: 40).isActive = true
        _more.heightAnchor.constraint(equalToConstant: 40).isActive = true
        _more.centerYAnchor.constraint(equalTo: name.centerYAnchor, constant: 2).isActive = true
        _more.leftAnchor.constraint(equalTo: name.rightAnchor, constant: 20).isActive = true
        
        _add.centerYAnchor.constraint(equalTo: border.centerYAnchor).isActive = true
        _add.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        _add.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _add.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        refresh()
    }
    
    override func layout() {
        super.layout()
        name.needsLayout = true
    }
    
    func textDidEndEditing(_ notification: Notification) {
//        app.session.name(app.project, name: name.string)
    }
    
    override func refresh() {
//        (app.modalWindow as? Stock)?.close()
//        scroll.views.filter { $0 is Grocery }.forEach { $0.removeFromSuperview() }
//        stock.views.forEach { $0.removeFromSuperview() }
//        emptyGrocery?.removeFromSuperview()
//        emptyProducts?.removeFromSuperview()
//        name.string = app.session.name(app.project)
//        name.didChangeText()
//        
//        if app.session.cards(app.project, list: 1) == 0 {
//            let emptyGrocery = Label(.key("Shopping.empty.grocery"), 15, .medium, NSColor(named: "haze")!)
//            scroll.add(emptyGrocery)
//            self.emptyGrocery = emptyGrocery
//
//            emptyGrocery.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 40).isActive = true
//            emptyGrocery.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
//            scroll.bottom.constraint(greaterThanOrEqualTo: emptyGrocery.bottomAnchor, constant: 40).isActive = true
//        } else {
//            var top: NSLayoutYAxisAnchor?
//            (0 ..< app.session.cards(app.project, list: 1)).forEach {
//                let grocery = Grocery($0, self)
//                scroll.add(grocery)
//                
//                if top == nil {
//                    grocery.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 20).isActive = true
//                } else {
//                    grocery.topAnchor.constraint(equalTo: top!).isActive = true
//                }
//                grocery.leftAnchor.constraint(greaterThanOrEqualTo: scroll.left).isActive = true
//                grocery.rightAnchor.constraint(lessThanOrEqualTo: scroll.right).isActive = true
//                grocery.leftAnchor.constraint(greaterThanOrEqualTo: scroll.centerX, constant: -250).isActive = true
//                
//                let left = grocery.leftAnchor.constraint(equalTo: scroll.centerX, constant: -250)
//                left.priority = .defaultLow
//                left.isActive = true
//                top = grocery.bottomAnchor
//            }
//            scroll.bottom.constraint(greaterThanOrEqualTo: top!, constant: 20).isActive = true
//        }
//        if app.session.cards(app.project, list: 0) == 0 {
//            let emptyProducts = Label(.key("Shopping.empty.products"), 15, .medium, NSColor(named: "haze")!)
//            stock.add(emptyProducts)
//            self.emptyProducts = emptyProducts
//
//            emptyProducts.leftAnchor.constraint(equalTo: stock.left, constant: 40).isActive = true
//            emptyProducts.centerYAnchor.constraint(equalTo: stock.centerY).isActive = true
//            stock.right.constraint(greaterThanOrEqualTo: emptyProducts.rightAnchor, constant: 40).isActive = true
//        } else {
//            var left: NSLayoutXAxisAnchor?
//            (0 ..< app.session.cards(app.project, list: 0)).forEach {
//                let product = Product($0, self)
//                stock.add(product)
//
//                if left == nil {
//                    product.leftAnchor.constraint(equalTo: stock.left, constant: 15).isActive = true
//                } else {
//                    product.leftAnchor.constraint(equalTo: left!, constant: 10).isActive = true
//                }
//                product.topAnchor.constraint(equalTo: stock.top, constant: 10).isActive = true
//                left = product.rightAnchor
//            }
//            stock.right.constraint(greaterThanOrEqualTo: left!, constant: 20).isActive = true
//        }
    }
    
    func stockLast() {
        stock.documentView!.layoutSubtreeIfNeeded()
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.8
            $0.allowsImplicitAnimation = true
            stock.contentView.scroll(to: .init(x: stock.documentView!.bounds.width - stock.bounds.width, y: 0))
        }
    }
    
    func groceryLast() {
        scroll.documentView!.layoutSubtreeIfNeeded()
        if scroll.documentView!.bounds.height > scroll.bounds.height {
            NSAnimationContext.runAnimationGroup {
                $0.duration = 0.8
                $0.allowsImplicitAnimation = true
                scroll.contentView.scroll(to: .init(x: 0, y: scroll.documentView!.bounds.height - scroll.bounds.height))
            }
        }
    }
    
    @objc private func add() {
        app.runModal(for: Stock.New(self))
    }
}
