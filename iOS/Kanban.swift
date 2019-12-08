import UIKit

final class Kanban: View {
    private(set) weak var scroll: Scroll!
    private(set) weak var _add: Button!
    private(set) weak var tags: Tags!
    private weak var ring: Ring!
    private weak var bars: Bars!
    
    required init?(coder: NSCoder) { nil }
    required init() {
        super.init()
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let tags = Tags()
        scroll.add(tags)
        self.tags = tags
        
        let _add = Button("plus", target: self, action: #selector(add))
        scroll.add(_add)
        self._add = _add
        
        let ring = Ring()
        scroll.add(ring)
        self.ring = ring

        let bars = Bars()
        scroll.add(bars)
        self.bars = bars

        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        scroll.width.constraint(greaterThanOrEqualTo: widthAnchor).isActive = true
        scroll.height.constraint(greaterThanOrEqualTo: heightAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: tags.bottomAnchor, constant: 20).isActive = true

        ring.topAnchor.constraint(equalTo: scroll.top).isActive = true
        ring.leftAnchor.constraint(equalTo: scroll.left, constant: 15).isActive = true
        
        bars.topAnchor.constraint(equalTo: ring.bottomAnchor, constant: 20).isActive = true
        bars.leftAnchor.constraint(equalTo: scroll.left, constant: 20).isActive = true
        
        tags.widthAnchor.constraint(greaterThanOrEqualTo: ring.widthAnchor, constant: 30).isActive = true
        tags.widthAnchor.constraint(greaterThanOrEqualTo: bars.widthAnchor, constant: 30).isActive = true
        tags.topAnchor.constraint(equalTo: bars.bottomAnchor, constant: 40).isActive = true
        tags.leftAnchor.constraint(equalTo: scroll.left, constant: 10).isActive = true
        
        _add.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _add.heightAnchor.constraint(equalToConstant: 60).isActive = true

        refresh()
    }
    
    override func refresh() {
        isUserInteractionEnabled = false
        scroll.views.filter { $0 is Card || $0 is Column }.forEach { $0.removeFromSuperview() }
        
        var left = tags.rightAnchor
        (0 ..< app.session.lists(app.project)).forEach { list in
            let column = Column(list)
            scroll.add(column)
            
            if list == 0 {
                _add.leftAnchor.constraint(equalTo: column.leftAnchor).isActive = true
                _add.topAnchor.constraint(equalTo: column.bottomAnchor, constant: 10).isActive = true
            }
            
            var top: Card?
            (0 ..< app.session.cards(app.project, list: list)).forEach {
                let card = Card(self, index: $0)
                scroll.add(card)
                
                if top == nil {
                    if list == 0 {
                        card.top = card.topAnchor.constraint(equalTo: _add.bottomAnchor, constant: 10)
                    } else {
                        card.top = card.topAnchor.constraint(equalTo: column.bottomAnchor, constant: 10)
                    }
                } else {
                    top!.child = card
                }
                
                scroll.bottomAnchor.constraint(greaterThanOrEqualTo: card.bottomAnchor, constant: 20).isActive = true
                card.column = column
                card.update(false)
                top = card
            }
            
            column.leftAnchor.constraint(equalTo: left, constant: 10).isActive = true
            column.topAnchor.constraint(equalTo: scroll.top, constant: 10).isActive = true
            left = column.rightAnchor
        }
        
        scroll.right.constraint(greaterThanOrEqualTo: left, constant: 20).isActive = true
        tags.refresh()
        charts()
        isUserInteractionEnabled = true
    }
    
    override func found(_ ranges: [(Int, Int, NSRange)]) {
        scroll.views.compactMap { $0 as? Card }.forEach {
            $0.textStorage.removeAttribute(.backgroundColor, range: .init(location: 0, length: $0.text.count))
        }
    }
    
    override func select(_ list: Int, _ card: Int, _ range: NSRange) {
        scroll.views.compactMap { $0 as? Card }.forEach {
            $0.textStorage.removeAttribute(.backgroundColor, range: .init(location: 0, length: $0.text.utf16.count))
            if $0.column.index == list && $0.index == card {
                $0.textStorage.addAttribute(.backgroundColor, value: UIColor(named: "haze")!.withAlphaComponent(0.6), range: range)
                scroll.center(scroll.content.convert($0.layoutManager.boundingRect(forGlyphRange: range, in: $0.textContainer), from: $0))
            }
        }
    }
    
    func charts() {
        ring.current = .init(app.session.cards(app.project, list: app.session.lists(app.project) - 1))
        ring.total = .init((0 ..< app.session.lists(app.project)).map { app.session.cards(app.project, list: $0) }.reduce(0, +))
        ring.refresh()
        bars.refresh()
    }
    
    @objc private func add() {
        app.window!.endEditing(true)
        app.session.add(app.project, list: 0)
        refresh()
        scroll.views.compactMap { $0 as? Card }.first { $0.index == 0 && $0.column.index == 0 }!.edit()
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.scroll.contentOffset.x = 0
            self?.scroll.contentOffset.y = 0
        }
    }
}
