import AppKit

final class Shopping: View {
    private weak var scroll: Scroll!
    private weak var stock: Scroll!
    
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
        
        let _add = Button("plus", target: self, action: #selector(add))
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
        border.rightAnchor.constraint(equalTo: _add.leftAnchor, constant: 16).isActive = true
        border.bottomAnchor.constraint(equalTo: stock.topAnchor).isActive = true
        
        _add.centerYAnchor.constraint(equalTo: border.centerYAnchor).isActive = true
        _add.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        _add.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _add.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        refresh()
    }
    
    override func refresh() {
        (app.modalWindow as? Stock)?.close()
        scroll.views.filter { $0 is Grocery }.forEach { $0.removeFromSuperview() }
        stock.views.forEach { $0.removeFromSuperview() }
        
        var top: NSLayoutYAxisAnchor?
        (0 ..< app.session.cards(app.project!, list: 1)).forEach {
            let grocery = Grocery($0)
            scroll.add(grocery)
            
            if top == nil {
                grocery.topAnchor.constraint(equalTo: scroll.top, constant: 30).isActive = true
            } else {
                grocery.topAnchor.constraint(equalTo: top!).isActive = true
            }
            grocery.leftAnchor.constraint(greaterThanOrEqualTo: scroll.left).isActive = true
            grocery.rightAnchor.constraint(lessThanOrEqualTo: scroll.right).isActive = true
            grocery.leftAnchor.constraint(greaterThanOrEqualTo: scroll.centerX, constant: -250).isActive = true
            
            let left = grocery.leftAnchor.constraint(equalTo: scroll.centerX, constant: -250)
            left.priority = .defaultLow
            left.isActive = true
            top = grocery.bottomAnchor
        }
        if top != nil {
            scroll.bottom.constraint(greaterThanOrEqualTo: top!, constant: 20).isActive = true
        }
        var left: NSLayoutXAxisAnchor?
        (0 ..< app.session.cards(app.project!, list: 0)).forEach {
            let product = Product($0, self)
            stock.add(product)

            if left == nil {
                product.leftAnchor.constraint(equalTo: stock.left, constant: 15).isActive = true
            } else {
                product.leftAnchor.constraint(equalTo: left!, constant: 10).isActive = true
            }
            product.topAnchor.constraint(equalTo: stock.top, constant: 10).isActive = true
            left = product.rightAnchor
        }
        if left != nil {
            stock.right.constraint(greaterThanOrEqualTo: left!, constant: 20).isActive = true
        }
    }
    
    override func add() {
        app.runModal(for: Stock.New(self))
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
}
