import UIKit

final class Kanban: View {
    private weak var scroll: Scroll!
    private weak var _add: Button!
    private(set) weak var tags: Tags!
    
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

        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        scroll.width.constraint(greaterThanOrEqualTo: widthAnchor).isActive = true
        scroll.height.constraint(greaterThanOrEqualTo: heightAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: tags.bottomAnchor, constant: 20).isActive = true
        
        tags.topAnchor.constraint(equalTo: scroll.top, constant: 20).isActive = true
        tags.leftAnchor.constraint(equalTo: scroll.left).isActive = true
        
        _add.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _add.heightAnchor.constraint(equalToConstant: 60).isActive = true

        refresh()
    }
    
    override func refresh() {
        isUserInteractionEnabled = false
        scroll.views.filter { $0 is Card || $0 is Column || $0 is Chart }.forEach { $0.removeFromSuperview() }
        
        var left = tags.rightAnchor
        (0 ..< app.session.lists(app.project!)).forEach { list in
            let column = Column(list)
            scroll.add(column)
            
            if list == 0 {
                _add.leftAnchor.constraint(equalTo: column.leftAnchor).isActive = true
                _add.topAnchor.constraint(equalTo: column.bottomAnchor, constant: 10).isActive = true
            }
            
            var top: Card?
            (0 ..< app.session.cards(app.project!, list: list)).forEach {
                let card = Card(self, index: $0, column: list)
                scroll.add(card)
                
                if top == nil {
                    if list == 0 {
                        card.topAnchor.constraint(equalTo: _add.bottomAnchor, constant: 10).isActive = true
                    } else {
                        card.topAnchor.constraint(equalTo: column.bottomAnchor, constant: 20).isActive = true
                    }
                } else {
                    card.topAnchor.constraint(equalTo: top!.bottomAnchor).isActive = true
                }
                
                if $0 == app.session.cards(app.project!, list: list) - 1 {
                    tags.bottomAnchor.constraint(greaterThanOrEqualTo: card.bottomAnchor, constant: 20).isActive = true
                }
                column.rightAnchor.constraint(greaterThanOrEqualTo: card.rightAnchor).isActive = true
                card.leftAnchor.constraint(equalTo: column.leftAnchor).isActive = true
                top = card
            }
            
            column.leftAnchor.constraint(equalTo: left).isActive = true
            column.topAnchor.constraint(equalTo: scroll.top, constant: 10).isActive = true
            left = column.rightAnchor
        }
        
        let spider = Spider()
        scroll.add(spider)
        
        let ring = Ring((app.session.name(app.project!, list: app.session.lists(app.project!) - 1), .init(app.session.cards(app.project!, list: app.session.lists(app.project!) - 1))),
                              total: (.key("Chart.cards"), .init((0 ..< app.session.lists(app.project!)).reduce(into: [Int]()) {
                                $0.append(app.session.cards(app.project!, list: $1))
                              }.reduce(0, +))))
        scroll.add(ring)

        let bars = Bars()
        scroll.add(bars)
        
        spider.topAnchor.constraint(equalTo: scroll.top, constant: 10).isActive = true
        spider.leftAnchor.constraint(equalTo: left, constant: 20).isActive = true
        
        ring.topAnchor.constraint(equalTo: spider.bottomAnchor, constant: 20).isActive = true
        ring.leftAnchor.constraint(equalTo: left, constant: 40).isActive = true
        
        bars.topAnchor.constraint(equalTo: ring.bottomAnchor, constant: 60).isActive = true
        bars.leftAnchor.constraint(equalTo: left, constant: 20).isActive = true
        
        scroll.right.constraint(greaterThanOrEqualTo: spider.rightAnchor, constant: 10).isActive = true
        scroll.right.constraint(greaterThanOrEqualTo: ring.rightAnchor, constant: 10).isActive = true
        scroll.right.constraint(greaterThanOrEqualTo: bars.rightAnchor, constant: 10).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: bars.bottomAnchor, constant: 20).isActive = true
        tags.refresh()
        isUserInteractionEnabled = true
    }
    
    @objc private func add() {
        app.session.add(app.project!, list: 0)
        refresh()
        scroll.views.compactMap { $0 as? Card }.first { $0.index == 0 && $0.column == 0 }!.edit()
        UIView.animate(withDuration: 0.35) { [weak self] in
            self?.scroll.contentOffset.y = 0
        }
    }
}
