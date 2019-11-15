import UIKit

final class Shopping: Base.View {
    private weak var name: Label?
    private weak var emptyGrocery: Label?
    private weak var emptyProducts: Label?
    private weak var scroll: Scroll!
    private weak var stock: Scroll!
    private weak var _more: Button!
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let stock = Scroll()
        stock.alwaysBounceVertical = false
        addSubview(stock)
        self.stock = stock
        
        let border = Border()
        addSubview(border)
        
        let _more = Button("more", target: self, action: #selector(more))
        scroll.add(_more)
        self._more = _more
        
        let _add = Button("plusbig", target: self, action: #selector(add))
        addSubview(_add)
        
        scroll.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: border.topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        scroll.right.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        scroll.width.constraint(equalTo: safeAreaLayoutGuide.widthAnchor).isActive = true
        scroll.height.constraint(greaterThanOrEqualTo: scroll.heightAnchor).isActive = true
        
        stock.heightAnchor.constraint(equalToConstant: 100).isActive = true
        stock.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        stock.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        stock.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        stock.width.constraint(greaterThanOrEqualTo: stock.widthAnchor).isActive = true
        stock.height.constraint(equalToConstant: 100).isActive = true
        
        _more.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _more.heightAnchor.constraint(equalToConstant: 60).isActive = true
        _more.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
        
        _add.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        _add.widthAnchor.constraint(equalToConstant: 70).isActive = true
        _add.heightAnchor.constraint(equalToConstant: 70).isActive = true
        _add.centerYAnchor.constraint(equalTo: border.centerYAnchor).isActive = true
        
        border.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: _add.leftAnchor, constant: 15).isActive = true
        border.bottomAnchor.constraint(equalTo: stock.topAnchor).isActive = true
        
        stock.content.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(edit(_:))))
        
        refresh()
    }
    
    override func refresh() {
        super.refresh()
        scroll.views.filter { $0 is Grocery }.forEach { $0.removeFromSuperview() }
        stock.views.forEach { $0.removeFromSuperview() }
        rename()
        emptyGrocery?.removeFromSuperview()
        emptyProducts?.removeFromSuperview()
        if app.session.cards(app.project, list: 1) == 0 {
            let emptyGrocery = Label(.key("Shopping.empty.grocery"), 15, .medium, UIColor(named: "haze")!)
            scroll.add(emptyGrocery)
            self.emptyGrocery = emptyGrocery

            emptyGrocery.topAnchor.constraint(equalTo: name!.bottomAnchor, constant: 50).isActive = true
            emptyGrocery.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
            scroll.bottom.constraint(greaterThanOrEqualTo: emptyGrocery.bottomAnchor, constant: 40).isActive = true
        } else {
            var top: NSLayoutYAxisAnchor?
            (0 ..< app.session.cards(app.project, list: 1)).forEach {
                let grocery = Grocery($0, self)
                scroll.add(grocery)

                if top == nil {
                    grocery.topAnchor.constraint(equalTo: name!.bottomAnchor, constant: 20).isActive = true
                } else {
                    grocery.topAnchor.constraint(equalTo: top!).isActive = true
                }
                grocery.leftAnchor.constraint(equalTo: scroll.left).isActive = true
                grocery.rightAnchor.constraint(equalTo: scroll.right).isActive = true
                top = grocery.bottomAnchor
            }
            scroll.bottom.constraint(greaterThanOrEqualTo: top!, constant: 20).isActive = true
        }
        if app.session.cards(app.project, list: 0) == 0 {
            let emptyProducts = Label(.key("Shopping.empty.products"), 15, .medium, UIColor(named: "haze")!)
            stock.add(emptyProducts)
            self.emptyProducts = emptyProducts

            emptyProducts.leftAnchor.constraint(equalTo: stock.left, constant: 20).isActive = true
            emptyProducts.centerYAnchor.constraint(equalTo: stock.centerY).isActive = true
            stock.right.constraint(greaterThanOrEqualTo: emptyProducts.rightAnchor, constant: 40).isActive = true
        } else {
            var left: NSLayoutXAxisAnchor?
            (0 ..< app.session.cards(app.project, list: 0)).forEach {
                let product = Product($0, self)
                stock.add(product)

                if left == nil {
                    product.leftAnchor.constraint(equalTo: stock.left, constant: 10).isActive = true
                } else {
                    product.leftAnchor.constraint(equalTo: left!, constant: 5).isActive = true
                }
                product.topAnchor.constraint(equalTo: stock.top, constant: 10).isActive = true
                left = product.rightAnchor
            }
            stock.right.constraint(greaterThanOrEqualTo: left!, constant: 10).isActive = true
        }
        isUserInteractionEnabled = true
    }
    
    private func rename() {
        self.name?.removeFromSuperview()
        let string = app.session.name(app.project)
        let name = Label(string.mark {
            switch $0 {
            case .plain: return (.init(string[$1]), 26, .heavy, UIColor(named: "haze")!.withAlphaComponent(0.7))
            case .emoji: return (.init(string[$1]), 40, .regular, UIColor(named: "haze")!.withAlphaComponent(0.7))
            case .bold: return (.init(string[$1]), 30, .heavy, UIColor(named: "haze")!.withAlphaComponent(0.7))
                case .tag: fatalError()
            }
        })
        name.accessibilityLabel = .key("Project")
        name.accessibilityValue = string
        addSubview(name)
        self.name = name
        
        name.topAnchor.constraint(equalTo: scroll.top, constant: 25).isActive = true
        name.leftAnchor.constraint(equalTo: scroll.left, constant: 25).isActive = true
        name.widthAnchor.constraint(lessThanOrEqualToConstant: 400).isActive = true
        
        _more.leftAnchor.constraint(equalTo: name.rightAnchor, constant: 20).isActive = true
        _more.centerYAnchor.constraint(equalTo: name.centerYAnchor).isActive = true
    }
    
    func stockLast() {
        stock.content.layoutIfNeeded()
        if stock.content.bounds.width > stock.bounds.width {
            let offset = stock.content.bounds.width - stock.bounds.width
            UIView.animate(withDuration: 0.5) { [weak self] in
                self?.stock.contentOffset.x = offset
            }
        }
    }
    
    func groceryLast() {
        scroll.content.layoutIfNeeded()
        if scroll.content.bounds.height > scroll.bounds.height {
            let offset = scroll.content.bounds.height - scroll.bounds.height
            UIView.animate(withDuration: 0.5) { [weak self] in
                self?.scroll.contentOffset.y = offset
            }
        }
    }
    
    @objc private func add() {
        app.present(Stock.New(self), animated: true)
    }
    
    @objc private func edit(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            guard let product = stock.content.hitTest(gesture.location(in: stock.content), with: nil) as? Product else { return }
            app.present(Stock.Edit(self, index: product.index), animated: true)
        }
    }
}
