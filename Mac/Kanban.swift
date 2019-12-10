import AppKit

final class Kanban: View {
    private(set) weak var tags: Tags!
    private(set) weak var _add: Button!
    private(set) weak var scroll: Scroll!
    private weak var drag: Card?
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
        _add.setAccessibilityLabel(.key("Kanban.add"))
        scroll.add(_add)
        self._add = _add
        
        let ring = Ring()
        scroll.add(ring)
        self.ring = ring

        let bars = Bars()
        scroll.add(bars)
        self.bars = bars
        
        let column = Control(.key("Kanban.column"), self, #selector(self.column), NSColor(named: "haze")!.withAlphaComponent(0.2).cgColor, NSColor(named: "haze")!)
        scroll.add(column)
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        scroll.right.constraint(greaterThanOrEqualTo: rightAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: bottomAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: column.bottomAnchor, constant: 50).isActive = true
        
        tags.leftAnchor.constraint(equalTo: scroll.left, constant: 10).isActive = true
        tags.widthAnchor.constraint(greaterThanOrEqualTo: ring.widthAnchor, constant: 20).isActive = true
        tags.widthAnchor.constraint(greaterThanOrEqualTo: bars.widthAnchor, constant: 20).isActive = true
        tags.topAnchor.constraint(equalTo: bars.bottomAnchor, constant: 40).isActive = true
        
        column.widthAnchor.constraint(equalToConstant: 120).isActive = true
        column.leftAnchor.constraint(equalTo: scroll.left, constant: 25).isActive = true
        column.topAnchor.constraint(equalTo: tags.bottomAnchor, constant: 60).isActive = true
        
        _add.widthAnchor.constraint(equalToConstant: 30).isActive = true
        _add.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        ring.topAnchor.constraint(equalTo: scroll.top).isActive = true
        ring.leftAnchor.constraint(equalTo: scroll.left, constant: 10).isActive = true
        
        bars.topAnchor.constraint(equalTo: ring.bottomAnchor, constant: 20).isActive = true
        bars.leftAnchor.constraint(equalTo: scroll.left, constant: 20).isActive = true
        
        refresh()
    }
    
    override func mouseDragged(with: NSEvent) {
        if let drag = self.drag {
            drag.drag(with.deltaX, with.deltaY)
        } else if let view = hitTest(with.locationInWindow) {
            if let drag = view as? Card ?? view.superview as? Card ?? view.superview?.superview as? Card {
                drag.layer!.removeFromSuperlayer()
                scroll.documentView!.layer!.addSublayer(drag.layer!)
                self.drag = drag
            }
        } else {
            end(with)
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
        
        var left = tags.rightAnchor
        (0 ..< app.session.lists(app.project)).forEach { list in
            let column = Column(self, index: list)
            scroll.add(column)
            
            if list == 0 {
                _add.leftAnchor.constraint(equalTo: column.leftAnchor, constant: 25).isActive = true
                _add.topAnchor.constraint(equalTo: column.bottomAnchor, constant: 40).isActive = true
            }
            
            var top: Card?
            (0 ..< app.session.cards(app.project, list: list)).forEach {
                let card = Card(self, index: $0)
                scroll.add(card)

                if top == nil {
                    if list == 0 {
                        card.top = card.topAnchor.constraint(equalTo: _add.bottomAnchor, constant: 40)
                    } else {
                        card.top = card.topAnchor.constraint(equalTo: column.bottomAnchor, constant: 20)
                    }
                } else {
                    top!.child = card
                }

                scroll.bottom.constraint(greaterThanOrEqualTo: card.bottomAnchor, constant: 30).isActive = true
                card.column = column
                card.update(false)
                top = card
            }
            
            column.leftAnchor.constraint(equalTo: left, constant: 60).isActive = true
            column.topAnchor.constraint(equalTo: scroll.top, constant: 30).isActive = true
            left = column.rightAnchor
        }
        
        scroll.right.constraint(greaterThanOrEqualTo: left, constant: 40).isActive = true
        tags.refresh()
        charts()
    }
    
    override func add() {
        app.session.add(app.project, list: 0)
        let cards = scroll.views.compactMap { $0 as? Card }.filter { $0.column.index == 0 }
        let card = Card(self, index: 0)
        scroll.add(card)

        scroll.bottom.constraint(greaterThanOrEqualTo: card.bottomAnchor, constant: 30).isActive = true
        card.top = card.topAnchor.constraint(equalTo: _add.bottomAnchor, constant: 40)
        card.child = cards.first { $0.index == 0 }
        
        cards.forEach {
            $0.index += 1
        }
        
        card.column = scroll.views.compactMap { $0 as? Column }.first { $0.index == 0 }!
        card.update(false)
        
        NSAnimationContext.runAnimationGroup ({
            $0.duration = 0.4
            $0.allowsImplicitAnimation = true
            scroll.documentView!.layoutSubtreeIfNeeded()
            scroll.contentView.scroll(to: .zero)
        }) { [weak self, weak card] in
            card?.edit()
            self?.charts()
        }
    }
    
    override func found(_ ranges: [(Int, Int, NSRange)]) {
        scroll.views.compactMap { $0 as? Card }.forEach { card in
            let ranges = ranges.filter { $0.0 == card.column.index && $0.1 == card.index }.map { $0.2 as NSValue }
            if ranges.isEmpty {
                card.setSelectedRange(.init())
            } else {
                card.setSelectedRanges(ranges, affinity: .downstream, stillSelecting: true)
            }
        }
    }
    
    override func select(_ list: Int, _ card: Int, _ range: NSRange) {
        let text = scroll.views.compactMap { $0 as? Card }.first { $0.column.index == list && $0.index == card }!
        text.showFindIndicator(for: range)
        scroll.center(scroll.contentView.convert(text.layoutManager!.boundingRect(forGlyphRange: range, in: text.textContainer!), from: text))
    }
    
    func charts() {
        ring.current = .init(app.session.cards(app.project, list: app.session.lists(app.project) - 1))
        ring.total = .init((0 ..< app.session.lists(app.project)).map { app.session.cards(app.project, list: $0) }.reduce(0, +))
        ring.refresh()
        bars.refresh()
    }
    
    private func end(_ event: NSEvent) {
        drag?.stop()
        drag = nil
    }
    
    @objc private func column() {
        window!.makeFirstResponder(self)
        app.session.add(app.project)
        app.session.name(app.project, list: app.session.lists(app.project) - 1, name: .key("Kanban.new"))
        refresh()
        app.alert(app.session.name(app.project), message: .key("Kanban.added"))
    }
}
