import AppKit

final class Shopping: View {
    private weak var tags: Tags!
    private weak var scroll: Scroll!
    private weak var stock: Scroll!
    
    required init?(coder: NSCoder) { nil }
    required init() {
        super.init()
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let tags = Tags()
        scroll.add(tags)
        self.tags = tags
        
        let stock = Scroll()
        addSubview(stock)
        self.stock = stock
        
        let left = Border()
        addSubview(left)
        
        let right = Border()
        addSubview(right)
        
        let _add = Button("plus", target: self, action: #selector(add))
        addSubview(_add)
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: left.topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        scroll.right.constraint(equalTo: rightAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: tags.bottomAnchor, constant: 20).isActive = true

        stock.heightAnchor.constraint(equalToConstant: 150).isActive = true
        stock.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stock.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
        stock.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        stock.right.constraint(greaterThanOrEqualTo: rightAnchor).isActive = true
        stock.bottom.constraint(equalTo: stock.bottomAnchor).isActive = true
        
        tags.leftAnchor.constraint(equalTo: scroll.left).isActive = true
        
        left.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
        left.rightAnchor.constraint(equalTo: centerXAnchor, constant: -13).isActive = true
        left.bottomAnchor.constraint(equalTo: stock.topAnchor).isActive = true
        
        right.leftAnchor.constraint(equalTo: centerXAnchor, constant: 13).isActive = true
        right.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        right.bottomAnchor.constraint(equalTo: stock.topAnchor).isActive = true
        
        _add.centerYAnchor.constraint(equalTo: left.centerYAnchor).isActive = true
        _add.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        _add.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _add.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        refresh()
    }
    
    override func refresh() {
        (app.modalWindow as? Stock)?.close()
        scroll.views.filter { $0 is Grocery || $0 is Chart }.forEach { $0.removeFromSuperview() }
        stock.views.forEach { $0.removeFromSuperview() }
        
        let ring = Ring(app.session.cards(app.project, list: 0) - app.session.cards(app.project, list: 1), total: app.session.cards(app.project, list: 0))
        scroll.add(ring)
        
        var top: NSLayoutYAxisAnchor?
        (0 ..< app.session.cards(app.project, list: 1)).forEach {
            let grocery = Grocery($0)
            scroll.add(grocery)
            
            if top == nil {
                grocery.topAnchor.constraint(equalTo: scroll.top, constant: 20).isActive = true
            } else {
                grocery.topAnchor.constraint(equalTo: top!).isActive = true
            }
            grocery.leftAnchor.constraint(equalTo: tags.rightAnchor, constant: 20).isActive = true
            grocery.rightAnchor.constraint(lessThanOrEqualTo: scroll.right, constant: -10).isActive = true
            top = grocery.bottomAnchor
        }
        if top != nil {
            scroll.bottom.constraint(greaterThanOrEqualTo: top!, constant: 30).isActive = true
        }
        var left: NSLayoutXAxisAnchor?
        (0 ..< app.session.cards(app.project, list: 0)).forEach {
            let product = Product($0, self)
            stock.add(product)

            if left == nil {
                product.leftAnchor.constraint(equalTo: stock.left, constant: 30).isActive = true
            } else {
                product.leftAnchor.constraint(equalTo: left!, constant: 10).isActive = true
            }
            product.topAnchor.constraint(equalTo: stock.top, constant: 10).isActive = true
            left = product.rightAnchor
        }
        if left != nil {
            stock.right.constraint(greaterThanOrEqualTo: left!, constant: 30).isActive = true
        }
        
        ring.topAnchor.constraint(equalTo: scroll.top).isActive = true
        ring.leftAnchor.constraint(equalTo: scroll.left, constant: 30).isActive = true
        tags.widthAnchor.constraint(greaterThanOrEqualTo: ring.widthAnchor).isActive = true
        tags.topAnchor.constraint(equalTo: ring.bottomAnchor, constant: 20).isActive = true
        tags.refresh()
    }
    
    override func found(_ ranges: [(Int, Int, NSRange)]) {
        scroll.views.compactMap { $0 as? Grocery }.forEach { grocery in
            let ranges = ranges.filter { $0.0 == 1 && $0.1 == grocery.index }.map { $0.2 as NSValue }
            if ranges.isEmpty {
                grocery.text.setSelectedRange(.init())
            } else {
                grocery.text.setSelectedRanges(ranges, affinity: .downstream, stillSelecting: true)
            }
        }
        stock.views.compactMap { $0 as? Product }.forEach { product in
            let ranges = ranges.filter { $0.0 == 0 && $0.1 == product.index }.map { $0.2 as NSValue }
            if ranges.isEmpty {
                product.text.setSelectedRange(.init())
            } else {
                product.text.setSelectedRanges(ranges, affinity: .downstream, stillSelecting: true)
            }
        }
    }
    
    override func select(_ list: Int, _ card: Int, _ range: NSRange) {
        if list == 0 {
            let text = stock.views.compactMap { $0 as? Product }.first { $0.index == card }!.text!
            var frame = stock.contentView.convert(text.layoutManager!.boundingRect(forGlyphRange: range, in: text.textContainer!), from: text)
            frame.origin.x -= (stock.bounds.width - frame.size.width) / 2
            frame.origin.y -= (stock.bounds.height / 2) - frame.size.height
            frame.size.width = stock.bounds.width
            frame.size.height = stock.bounds.height
            text.showFindIndicator(for: range)
            NSAnimationContext.runAnimationGroup {
                $0.duration = 0.4
                $0.allowsImplicitAnimation = true
                stock.contentView.scrollToVisible(frame)
            }
        } else {
            let text = scroll.views.compactMap { $0 as? Grocery }.first { $0.index == card }!.text!
            var frame = scroll.contentView.convert(text.layoutManager!.boundingRect(forGlyphRange: range, in: text.textContainer!), from: text)
            frame.origin.x -= (scroll.bounds.width - frame.size.width) / 2
            frame.origin.y -= (scroll.bounds.height / 2) - frame.size.height
            frame.size.width = scroll.bounds.width
            frame.size.height = scroll.bounds.height
            text.showFindIndicator(for: range)
            NSAnimationContext.runAnimationGroup {
                $0.duration = 0.4
                $0.allowsImplicitAnimation = true
                scroll.contentView.scrollToVisible(frame)
            }
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
