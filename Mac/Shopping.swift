import AppKit

final class Shopping: View {
    private weak var scroll: Scroll!
    
    required init?(coder: NSCoder) { nil }
    required init() {
        super.init()
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let _add = Button("plus", target: self, action: #selector(add))
        _add.setAccessibilityLabel(.key("Shopping.add"))
        addSubview(_add)
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
        scroll.widthAnchor.constraint(lessThanOrEqualToConstant: 500).isActive = true
        scroll.width.constraint(equalTo: scroll.widthAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: scroll.bottomAnchor).isActive = true

        let width = scroll.widthAnchor.constraint(equalToConstant: 500)
        width.priority = .defaultLow
        width.isActive = true
        
        
        
//        _add.centerYAnchor.constraint(equalTo: left.centerYAnchor).isActive = true
//        _add.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
//        _add.widthAnchor.constraint(equalToConstant: 60).isActive = true
//        _add.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        refresh()
    }
    
    override func refresh() {
//        (app.modalWindow as? Stock)?.close()
//        scroll.views.filter { $0 is Grocery }.forEach { $0.removeFromSuperview() }
//        stock.views.forEach { $0.removeFromSuperview() }
//
//        var top: NSLayoutYAxisAnchor?
//        (0 ..< app.session.cards(app.project, list: 1)).forEach {
//            let grocery = Grocery($0)
//            scroll.add(grocery)
//
//            if top == nil {
//                grocery.topAnchor.constraint(equalTo: scroll.top, constant: 20).isActive = true
//            } else {
//                grocery.topAnchor.constraint(equalTo: top!).isActive = true
//            }
//            grocery.leftAnchor.constraint(equalTo: tags.rightAnchor, constant: 20).isActive = true
//            grocery.rightAnchor.constraint(lessThanOrEqualTo: scroll.right, constant: -10).isActive = true
//            top = grocery.bottomAnchor
//        }
//        if top != nil {
//            scroll.bottom.constraint(greaterThanOrEqualTo: top!, constant: 30).isActive = true
//        }
//        var left: NSLayoutXAxisAnchor?
//        (0 ..< app.session.cards(app.project, list: 0)).forEach {
//            let product = Product($0, self)
//            stock.add(product)
//
//            if left == nil {
//                product.leftAnchor.constraint(equalTo: stock.left, constant: 30).isActive = true
//            } else {
//                product.leftAnchor.constraint(equalTo: left!, constant: 10).isActive = true
//            }
//            product.topAnchor.constraint(equalTo: stock.top, constant: 10).isActive = true
//            left = product.rightAnchor
//        }
//        if left != nil {
//            stock.right.constraint(greaterThanOrEqualTo: left!, constant: 30).isActive = true
//        }
//
//        ring.current = .init(app.session.cards(app.project, list: 0) - app.session.cards(app.project, list: 1))
//        ring.total = .init(app.session.cards(app.project, list: 0))
//        ring.refresh()
//        tags.refresh()
    }
    
    override func found(_ ranges: [(Int, Int, NSRange)]) {
//        scroll.views.compactMap { $0 as? Grocery }.forEach { grocery in
//            let ranges = ranges.filter { $0.0 == 1 && $0.1 == grocery.index }.map { $0.2 as NSValue }
//            if ranges.isEmpty {
//                grocery.text.setSelectedRange(.init())
//            } else {
//                grocery.text.setSelectedRanges(ranges, affinity: .downstream, stillSelecting: true)
//            }
//        }
//        stock.views.compactMap { $0 as? Product }.forEach { product in
//            let ranges = ranges.filter { $0.0 == 0 && $0.1 == product.index }.map { $0.2 as NSValue }
//            if ranges.isEmpty {
//                product.text.setSelectedRange(.init())
//            } else {
//                product.text.setSelectedRanges(ranges, affinity: .downstream, stillSelecting: true)
//            }
//        }
    }
    
    override func select(_ list: Int, _ card: Int, _ range: NSRange) {
//        if list == 0 {
//            let text = stock.views.compactMap { $0 as? Product }.first { $0.index == card }!.text!
//            text.showFindIndicator(for: range)
//            stock.center(stock.contentView.convert(text.layoutManager!.boundingRect(forGlyphRange: range, in: text.textContainer!), from: text))
//        } else {
//            let text = scroll.views.compactMap { $0 as? Grocery }.first { $0.index == card }!.text!
//            text.showFindIndicator(for: range)
//            scroll.center(scroll.contentView.convert(text.layoutManager!.boundingRect(forGlyphRange: range, in: text.textContainer!), from: text))
//        }
    }
    
    override func add() {
//        app.runModal(for: Stock.New(self))
    }
    
    func last() {
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
