import AppKit

final class Shopping: Base.View, NSTextViewDelegate {
    private weak var empty: Label?
    private weak var scroll: Scroll!
    private weak var stock: Scroll!
    private weak var name: Text!
    
    required init?(coder: NSCoder) { nil }
    override init() {
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
        (name.textStorage as! Storage).fonts = [.plain: .systemFont(ofSize: 30, weight: .heavy),
                                                .emoji: .systemFont(ofSize: 40, weight: .regular),
                                                .bold: .systemFont(ofSize: 34, weight: .heavy)]
        name.standby = NSColor(named: "haze")!.withAlphaComponent(0.7)
        name.delegate = self
        scroll.add(name)
        self.name = name
        
        let _more = Button("more", target: self, action: #selector(more))
        scroll.add(_more)
        
        let _add = Button("plusbig", target: self, action: #selector(add))
        addSubview(_add)
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: border.topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        scroll.right.constraint(equalTo: rightAnchor).isActive = true

        stock.heightAnchor.constraint(equalToConstant: 120).isActive = true
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
        app.session.name(app.project, name: name.string)
    }
    
    override func refresh() {
        (app.modalWindow as? Stock.Edit)?.close()
        scroll.views.filter { $0 is Task }.forEach { $0.removeFromSuperview() }
        stock.views.forEach { $0.removeFromSuperview() }
        empty?.removeFromSuperview()
        name.string = app.session.name(app.project)
        name.didChangeText()
        print("refresh")
        
        if app.session.cards(app.project, list: 0) == 0 {
            let empty = Label(.key("Shopping.empty"), 15, .medium, NSColor(named: "haze")!)
            scroll.add(empty)
            self.empty = empty

            empty.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 40).isActive = true
            empty.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true

            scroll.bottom.constraint(greaterThanOrEqualTo: empty.bottomAnchor, constant: 40).isActive = true
        } else {
            var left: NSLayoutXAxisAnchor?
            (0 ..< app.session.cards(app.project, list: 0)).forEach {
                let product = Product($0, self)
                stock.add(product)

                product.centerYAnchor.constraint(equalTo: stock.centerY).isActive = true

                if left == nil {
                    product.leftAnchor.constraint(equalTo: scroll.left, constant: 15).isActive = true
                } else {
                    product.leftAnchor.constraint(equalTo: left!, constant: 10).isActive = true
                }

                left = product.rightAnchor
            }
            stock.right.constraint(greaterThanOrEqualTo: left!, constant: 20).isActive = true
        }
    }
    
    @objc private func add() {
        app.runModal(for: Stock.New(self))
    }
}
