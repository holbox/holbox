import AppKit

final class Kanban: View {
    private(set) weak var tags: Tags!
    private(set) weak var _add: Button!
    private(set) weak var scroll: Scroll!
    private weak var count: Label!
    private weak var drag: Card?
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
        
        let count = Label([])
        scroll.add(count)
        self.count = count

        let bars = Bars()
        scroll.add(bars)
        self.bars = bars
        
        let _column = Control(.key("Kanban.column"), self, #selector(column), NSColor(named: "haze")!.withAlphaComponent(0.2).cgColor, NSColor(named: "haze")!)
        scroll.add(_column)
        
        let _csv = Control(.key("Kanban.csv"), self, #selector(csv), NSColor(named: "haze")!.withAlphaComponent(0.2).cgColor, NSColor(named: "haze")!)
        scroll.add(_csv)
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        scroll.right.constraint(greaterThanOrEqualTo: rightAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: bottomAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: tags.bottomAnchor, constant: 50).isActive = true
        
        tags.leftAnchor.constraint(equalTo: scroll.left, constant: 35).isActive = true
        tags.widthAnchor.constraint(greaterThanOrEqualTo: bars.widthAnchor, constant: 20).isActive = true
        tags.widthAnchor.constraint(greaterThanOrEqualTo: _column.widthAnchor, constant: 20).isActive = true
        tags.topAnchor.constraint(equalTo: _csv.bottomAnchor, constant: 40).isActive = true
        
        _column.widthAnchor.constraint(equalToConstant: 100).isActive = true
        _column.leftAnchor.constraint(equalTo: scroll.left, constant: 30).isActive = true
        _column.topAnchor.constraint(equalTo: count.bottomAnchor, constant: 20).isActive = true
        
        _csv.widthAnchor.constraint(equalToConstant: 100).isActive = true
        _csv.leftAnchor.constraint(equalTo: scroll.left, constant: 30).isActive = true
        _csv.topAnchor.constraint(equalTo: _column.bottomAnchor, constant: 10).isActive = true
        
        _add.widthAnchor.constraint(equalToConstant: 30).isActive = true
        _add.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        count.topAnchor.constraint(equalTo: bars.bottomAnchor).isActive = true
        count.leftAnchor.constraint(equalTo: scroll.left, constant: 35).isActive = true
        
        bars.topAnchor.constraint(equalTo: scroll.top, constant: 40).isActive = true
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
        end(with)
    }
    
    override func mouseDown(with: NSEvent) {
        end(with)
        window!.makeFirstResponder(self)
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
        card.child = cards.first { $0.index == 0 }
        
        cards.forEach {
            $0.index += 1
        }
        
        card.top = card.centerYAnchor.constraint(equalTo: _add.centerYAnchor)
        card.column = scroll.views.compactMap { $0 as? Column }.first { $0.index == 0 }!
        card.update(false)
        scroll.documentView!.layoutSubtreeIfNeeded()
        
        card.top = card.topAnchor.constraint(equalTo: _add.bottomAnchor, constant: 40)
        
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
                card.text.setSelectedRange(.init())
            } else {
                card.text.setSelectedRanges(ranges, affinity: .downstream, stillSelecting: true)
            }
        }
    }
    
    override func select(_ list: Int, _ card: Int, _ range: NSRange) {
        let text = scroll.views.compactMap { $0 as? Card }.first { $0.column.index == list && $0.index == card }!.text!
        text.showFindIndicator(for: range)
        scroll.center(scroll.contentView.convert(text.layoutManager!.boundingRect(forGlyphRange: range, in: text.textContainer!), from: text))
    }
    
    func charts() {
        count.attributed([("\((0 ..< app.session.lists(app.project)).map { app.session.cards(app.project, list: $0) }.reduce(0, +))", 18, .medium, NSColor(named: "haze")!),
                          (" " + .key("Kanban.count"), 12, .regular, NSColor(named: "haze")!)])
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
    
    @objc private func csv() {
        let save = NSSavePanel()
        save.nameFieldStringValue = app.session.name(app.project)
        save.allowedFileTypes = ["csv"]
        save.beginSheetModal(for: window!) {
            if app.project != nil && $0 == .OK {
                app.session.csv(app.project) {
                    try? $0.write(to: save.url!, options: .atomic)
                }
            }
        }
    }
}
