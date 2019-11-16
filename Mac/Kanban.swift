import AppKit

final class Kanban: Base.View {
    private weak var drag: Card?
    private weak var scroll: Scroll!
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let _card = Button("plus", target: self, action: #selector(card))
        let _more = Button("more", target: self, action: #selector(more))
        
        [_card, _more].forEach {
            scroll.add($0)
            $0.widthAnchor.constraint(equalToConstant: 30).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 30).isActive = true
            $0.topAnchor.constraint(equalTo: scroll.top, constant: 20).isActive = true
        }

        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        scroll.right.constraint(greaterThanOrEqualTo: rightAnchor).isActive = true
        scroll.right.constraint(greaterThanOrEqualTo: _more.rightAnchor, constant: 40).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: bottomAnchor).isActive = true
        
        _card.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        _more.leftAnchor.constraint(equalTo: _card.rightAnchor, constant: 20).isActive = true

        refresh()
    }
    
    override func mouseDragged(with: NSEvent) {
        super.mouseDragged(with: with)
        if let drag = self.drag {
            drag.drag(with.deltaX, with.deltaY)
        } else if let view = hitTest(with.locationInWindow) {
            drag = view as? Card ?? view.superview as? Card ?? view.superview?.superview as? Card
        }
    }
    
    override func mouseUp(with: NSEvent) {
        super.mouseUp(with: with)
        drag?.stop(with.locationInWindow.x + scroll.documentVisibleRect.origin.x, scroll.documentVisibleRect.height - with.locationInWindow.y + scroll.documentVisibleRect.origin.y)
        drag = nil
    }
    
    override func refresh() {
//        scroll.views.filter { $0 is Card || $0 is Column }.forEach { $0.removeFromSuperview() }
//        var left: NSLayoutXAxisAnchor?
//        (0 ..< app.session.lists(app.project)).forEach { list in
//            let column = Column(list)
//            scroll.add(column)
//
//            var top: Card?
//            (0 ..< app.session.cards(app.project, list: list)).forEach {
//                let card = Card(self, index: $0, column: list)
//                scroll.add(card)
//
//                if top == nil {
//                    card.top = card.topAnchor.constraint(equalTo: column.bottomAnchor, constant: 10)
//                } else {
//                    card.top = card.topAnchor.constraint(equalTo: top!.bottomAnchor, constant: 5)
//                    top!.child = card
//                }
//
//                scroll.bottom.constraint(greaterThanOrEqualTo: card.bottomAnchor, constant: 30).isActive = true
//                card.right = column.rightAnchor.constraint(greaterThanOrEqualTo: card.rightAnchor)
//                card.left = card.leftAnchor.constraint(equalTo: column.leftAnchor)
//                top = card
//            }
//
//            if left == nil {
//                column.leftAnchor.constraint(equalTo: scroll.left, constant: 30).isActive = true
//            } else {
//                column.leftAnchor.constraint(equalTo: left!, constant: 10).isActive = true
//            }
//
//            column.topAnchor.constraint(equalTo: scroll.top, constant: 70).isActive = true
//            scroll.bottom.constraint(greaterThanOrEqualTo: column.bottomAnchor, constant: 70).isActive = true
//            left = column.rightAnchor
//        }
//
//        if left != nil {
//            scroll.right.constraint(greaterThanOrEqualTo: left!, constant: 80).isActive = true
//        }
    }
    
    @objc private func card() {
//        app.session.add(app.project, list: 0)
        refresh()
        scroll.views.compactMap { $0 as? Card }.first { $0.index == 0 && $0.column == 0 }!.edit()
    }
}
