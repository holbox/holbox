import AppKit

final class Kanban: Base.View {
    private weak var drag: Card?
    private weak var scroll: Scroll!
    
    required init?(coder: NSCoder) { nil }
    required init() {
        super.init()
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll

        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        scroll.right.constraint(greaterThanOrEqualTo: rightAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: bottomAnchor).isActive = true

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
        end(with)
    }
    
    override func mouseDown(with: NSEvent) {
        end(with)
        super.mouseDown(with: with)
    }
    
    override func refresh() {
        scroll.views.forEach { $0.removeFromSuperview() }
        
        let add = Button("plus", target: self, action: #selector(card))
        scroll.add(add)
        
        add.widthAnchor.constraint(equalToConstant: 30).isActive = true
        add.heightAnchor.constraint(equalToConstant: 30).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: add.bottomAnchor, constant: 20).isActive = true
        
        var left: NSLayoutXAxisAnchor?
        (0 ..< app.session.lists(app.project!)).forEach { list in
            let column = Column(list)
            scroll.add(column)
            
            if list == 0 {
                add.leftAnchor.constraint(equalTo: column.leftAnchor, constant: 25).isActive = true
                add.topAnchor.constraint(equalTo: column.bottomAnchor, constant: 40).isActive = true
            }
            
            var top: Card?
            (0 ..< app.session.cards(app.project!, list: list)).forEach {
                let card = Card(self, index: $0, column: list)
                scroll.add(card)

                if top == nil {
                    if list == 0 {
                        card.top = card.topAnchor.constraint(equalTo: add.bottomAnchor, constant: 40)
                    } else {
                        card.top = card.topAnchor.constraint(equalTo: column.bottomAnchor, constant: 20)
                    }
                } else {
                    card.top = card.topAnchor.constraint(equalTo: top!.bottomAnchor, constant: 20)
                    top!.child = card
                }

                scroll.bottom.constraint(greaterThanOrEqualTo: card.bottomAnchor, constant: 30).isActive = true
                card.right = column.rightAnchor.constraint(greaterThanOrEqualTo: card.rightAnchor)
                card.left = card.leftAnchor.constraint(equalTo: column.leftAnchor)
                card.update()
                top = card
            }

            if left == nil {
                column.leftAnchor.constraint(equalTo: scroll.left, constant: 60).isActive = true
            } else {
                column.leftAnchor.constraint(equalTo: left!, constant: 50).isActive = true
            }

            column.topAnchor.constraint(equalTo: scroll.top, constant: 40).isActive = true
            scroll.bottom.constraint(greaterThanOrEqualTo: column.bottomAnchor, constant: 90).isActive = true
            left = column.rightAnchor
        }

        if left != nil {
            scroll.right.constraint(greaterThanOrEqualTo: left!, constant: 60).isActive = true
        }
    }
    
    private func end(_ event: NSEvent) {
        drag?.stop(event.locationInWindow.x + scroll.documentVisibleRect.origin.x, scroll.documentVisibleRect.height - event.locationInWindow.y + scroll.documentVisibleRect.origin.y)
        drag = nil
    }
    
    @objc private func card() {
        app.session.add(app.project!, list: 0)
        refresh()
        scroll.views.compactMap { $0 as? Card }.first { $0.index == 0 && $0.column == 0 }!.edit()
    }
}
