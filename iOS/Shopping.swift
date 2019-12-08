import UIKit

final class Shopping: View {
    private weak var ring: Ring!
    private weak var scroll: Scroll!
    private weak var stock: Scroll!
    
    required init?(coder: NSCoder) { nil }
    required init() {
        super.init()
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let stock = Scroll()
        stock.alwaysBounceVertical = false
        addSubview(stock)
        self.stock = stock
        
        let left = Border()
        addSubview(left)
        
        let right = Border()
        addSubview(right)
        
        let _add = Button("plus", target: self, action: #selector(add))
        addSubview(_add)
        
        let ring = Ring()
        scroll.add(ring)
        self.ring = ring
        
        scroll.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: left.topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        scroll.width.constraint(equalTo: safeAreaLayoutGuide.widthAnchor).isActive = true
        scroll.height.constraint(greaterThanOrEqualTo: scroll.heightAnchor).isActive = true
        
        stock.heightAnchor.constraint(equalToConstant: 115).isActive = true
        stock.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        stock.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        stock.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        stock.width.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.widthAnchor).isActive = true
        stock.height.constraint(equalToConstant: 115).isActive = true
        
        left.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 1).isActive = true
        left.rightAnchor.constraint(equalTo: centerXAnchor, constant: -13).isActive = true
        left.bottomAnchor.constraint(equalTo: stock.topAnchor).isActive = true
        
        right.leftAnchor.constraint(equalTo: centerXAnchor, constant: 13).isActive = true
        right.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -1).isActive = true
        right.bottomAnchor.constraint(equalTo: stock.topAnchor).isActive = true
        
        _add.centerYAnchor.constraint(equalTo: left.centerYAnchor).isActive = true
        _add.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        _add.widthAnchor.constraint(equalToConstant: 70).isActive = true
        _add.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        ring.topAnchor.constraint(equalTo: scroll.top).isActive = true
        ring.leftAnchor.constraint(equalTo: scroll.left, constant: 15).isActive = true
        
        refresh()
    }
    
    override func refresh() {
        isUserInteractionEnabled = false
        scroll.views.filter { $0 is Grocery }.forEach { $0.removeFromSuperview() }
        stock.views.forEach { $0.removeFromSuperview() }
        
        var top: NSLayoutYAxisAnchor?
        (0 ..< app.session.cards(app.project, list: 1)).forEach {
            let grocery = Grocery($0, self)
            scroll.add(grocery)

            if top == nil {
                grocery.topAnchor.constraint(equalTo: ring.bottomAnchor).isActive = true
            } else {
                grocery.topAnchor.constraint(equalTo: top!).isActive = true
            }
            grocery.leftAnchor.constraint(equalTo: scroll.left).isActive = true
            grocery.rightAnchor.constraint(equalTo: scroll.right).isActive = true
            top = grocery.bottomAnchor
        }
        
        if top != nil {
            scroll.bottom.constraint(greaterThanOrEqualTo: top!, constant: 20).isActive = true
        }
        
        var left: NSLayoutXAxisAnchor?
        (0 ..< app.session.cards(app.project, list: 0)).forEach {
            let product = Product($0, self)
            stock.add(product)

            if left == nil {
                product.leftAnchor.constraint(equalTo: stock.left, constant: 5).isActive = true
            } else {
                product.leftAnchor.constraint(equalTo: left!, constant: 10).isActive = true
            }
            product.topAnchor.constraint(equalTo: stock.top, constant: 10).isActive = true
            left = product.rightAnchor
        }
        
        if left != nil {
            stock.right.constraint(greaterThanOrEqualTo: left!, constant: 10).isActive = true
        }
        
        ring.current = .init(app.session.cards(app.project, list: 0) - app.session.cards(app.project, list: 1))
        ring.total = .init(app.session.cards(app.project, list: 0))
        ring.refresh()
        isUserInteractionEnabled = true
    }
    
    override func found(_ ranges: [(Int, Int, NSRange)]) {
        scroll.views.compactMap { $0 as? Grocery }.forEach {
            $0.text.textStorage.removeAttribute(.backgroundColor, range: .init(location: 0, length: $0.text.text.count))
        }
        stock.views.compactMap { $0 as? Product }.forEach {
            $0.text.textStorage.removeAttribute(.backgroundColor, range: .init(location: 0, length: $0.text.text.count))
        }
    }
    
    override func select(_ list: Int, _ card: Int, _ range: NSRange) {
        stock.views.compactMap { $0 as? Product }.forEach {
            $0.text.textStorage.removeAttribute(.backgroundColor, range: .init(location: 0, length: $0.text.text.utf16.count))
            if list == 0 && $0.index == card {
                $0.text.textStorage.addAttribute(.backgroundColor, value: UIColor(named: "haze")!.withAlphaComponent(0.6), range: range)
                stock.center(stock.content.convert($0.text.layoutManager.boundingRect(forGlyphRange: range, in: $0.text.textContainer), from: $0))
            }
        }
        scroll.views.compactMap { $0 as? Grocery }.forEach {
            $0.text.textStorage.removeAttribute(.backgroundColor, range: .init(location: 0, length: $0.text.text.utf16.count))
            if list == 1 && $0.index == card {
                $0.text.textStorage.addAttribute(.backgroundColor, value: UIColor(named: "haze")!.withAlphaComponent(0.6), range: range)
                scroll.center(scroll.content.convert($0.text.layoutManager.boundingRect(forGlyphRange: range, in: $0.text.textContainer), from: $0))
            }
        }
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
}
