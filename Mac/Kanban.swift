import AppKit

final class Kanban: View {
    private(set) weak var tags: Tags!
    private(set) weak var find: Find!
    private weak var drag: Card?
    private weak var scroll: Scroll!
    private weak var _add: Button!
    
    required init?(coder: NSCoder) { nil }
    required init() {
        super.init()
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll

        let find = Find(self)
        scroll.add(find)
        self.find = find
        
        let tags = Tags()
        scroll.add(tags)
        self.tags = tags
        
        let _add = Button("plus", target: self, action: #selector(add))
        scroll.add(_add)
        self._add = _add

        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        scroll.right.constraint(greaterThanOrEqualTo: rightAnchor).isActive = true
        scroll.right.constraint(greaterThanOrEqualTo: find.rightAnchor, constant: 20).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: bottomAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: tags.bottomAnchor, constant: 20).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: _add.bottomAnchor, constant: 20).isActive = true
        
        find.topAnchor.constraint(equalTo: scroll.top).isActive = true
        find.leftAnchor.constraint(equalTo: scroll.left).isActive = true
        
        tags.topAnchor.constraint(equalTo: find.bottomAnchor, constant: 10).isActive = true
        tags.leftAnchor.constraint(equalTo: scroll.left).isActive = true
        
        _add.widthAnchor.constraint(equalToConstant: 30).isActive = true
        _add.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
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
        scroll.views.filter { $0 is Card || $0 is Column }.forEach { $0.removeFromSuperview() }
        
        var left: NSLayoutXAxisAnchor?
        (0 ..< app.session.lists(app.project!)).forEach { list in
            let column = Column(list)
            scroll.add(column)
            
            if list == 0 {
                _add.leftAnchor.constraint(equalTo: column.leftAnchor, constant: 25).isActive = true
                _add.topAnchor.constraint(equalTo: column.bottomAnchor, constant: 40).isActive = true
            }
            
            var top: Card?
            (0 ..< app.session.cards(app.project!, list: list)).forEach {
                let card = Card(self, index: $0, column: list)
                scroll.add(card)

                if top == nil {
                    if list == 0 {
                        card.top = card.topAnchor.constraint(equalTo: _add.bottomAnchor, constant: 40)
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
                column.leftAnchor.constraint(equalTo: tags.rightAnchor, constant: 60).isActive = true
            } else {
                column.leftAnchor.constraint(equalTo: left!, constant: 50).isActive = true
            }

            column.topAnchor.constraint(equalTo: find.bottomAnchor, constant: 10).isActive = true
            scroll.bottom.constraint(greaterThanOrEqualTo: column.bottomAnchor, constant: 90).isActive = true
            left = column.rightAnchor
        }

        if left != nil {
            scroll.right.constraint(greaterThanOrEqualTo: left!, constant: 60).isActive = true
        }
        
        tags.refresh()
    }
    
    override func add() {
        app.session.add(app.project!, list: 0)
        refresh()
        scroll.views.compactMap { $0 as? Card }.first { $0.index == 0 && $0.column == 0 }!.edit()
    }
    
    override func search() {
        find.start()
    }
    
    override func found(_ ranges: [(Int, Int, Range<String.Index>)]) {
        scroll.views.compactMap { $0 as? Card }.forEach { card in
            card.content.layoutSubtreeIfNeeded()
            let ranges = ranges.filter { $0.0 == card.column && $0.1 == card.index }.map {
                NSRange($0.2, in: app.session.content(app.project!, list: $0.0, card: $0.1)) as NSValue
            }
            if ranges.isEmpty {
                card.content.setSelectedRange(.init())
            } else {
                card.content.setSelectedRanges(ranges, affinity: .downstream, stillSelecting: true)
            }
        }
    }
    
    private func end(_ event: NSEvent) {
        drag?.stop(event.locationInWindow.x + scroll.documentVisibleRect.origin.x, scroll.documentVisibleRect.height - event.locationInWindow.y + scroll.documentVisibleRect.origin.y)
        drag = nil
    }
}
