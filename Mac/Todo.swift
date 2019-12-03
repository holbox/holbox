import AppKit

final class Todo: View, NSTextViewDelegate {
    private(set) weak var tags: Tags!
    private weak var scroll: Scroll!
    private weak var new: Text!
    
    required init?(coder: NSCoder) { nil }
    required init() {
        super.init()
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let tags = Tags()
        scroll.add(tags)
        self.tags = tags
        
        let new = Text(.Fix(), Active())
        new.textContainerInset.width = 10
        new.textContainerInset.height = 10
        new.setAccessibilityLabel(.key("Task"))
        new.font = NSFont(name: "Times New Roman", size: 22)
        (new.textStorage as! Storage).fonts = [.plain: (.systemFont(ofSize: 22, weight: .medium), .white),
                                               .emoji: (NSFont(name: "Times New Roman", size: 30)!, .white),
                                               .bold: (.systemFont(ofSize: 24, weight: .bold), .white),
                                               .tag: (.systemFont(ofSize: 20, weight: .medium), NSColor(named: "haze")!)]
        new.intro = true
        new.tab = true
        new.delegate = self
        scroll.add(new)
        self.new = new
        
        let _add = Button("plus", target: self, action: #selector(add))
        scroll.add(_add)
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        scroll.right.constraint(lessThanOrEqualTo: rightAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: _add.bottomAnchor, constant: 40).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: tags.bottomAnchor, constant: 20).isActive = true
        
        tags.leftAnchor.constraint(equalTo: scroll.left).isActive = true
        
        new.leftAnchor.constraint(equalTo: tags.rightAnchor, constant: 60).isActive = true
        new.widthAnchor.constraint(lessThanOrEqualToConstant: 400).isActive = true
        new.rightAnchor.constraint(lessThanOrEqualTo: scroll.right, constant: -10).isActive = true
        new.topAnchor.constraint(equalTo: scroll.top, constant: 10).isActive = true
        
        let width = new.widthAnchor.constraint(equalToConstant: 400)
        width.priority = .defaultLow
        width.isActive = true
        
        _add.topAnchor.constraint(equalTo: new.bottomAnchor).isActive = true
        _add.leftAnchor.constraint(equalTo: tags.rightAnchor, constant: 60).isActive = true
        _add.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _add.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        let top = _add.topAnchor.constraint(equalTo: scroll.top)
        top.priority = .defaultLow
        top.isActive = true
        
        refresh()
    }
    
    override func keyDown(with: NSEvent) {
        switch with.keyCode {
        case 36:
            if with.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command {
                add()
            } else {
                window!.makeFirstResponder(new)
                new.setSelectedRange(.init(location: new.string.count, length: 0))
            }
        case 48:
            window!.makeFirstResponder(new)
            new.setSelectedRange(.init(location: 0, length: new.string.count))
        default: super.keyDown(with: with)
        }
    }
    
    override func refresh() {
        scroll.views.filter { $0 is Task || $0 is Chart }.forEach { $0.removeFromSuperview() }
        
        let ring = Ring(app.session.cards(app.project, list: 1),
                        total: app.session.cards(app.project, list: 0) + app.session.cards(app.project, list: 1))
        scroll.add(ring)
        
        var top: NSLayoutYAxisAnchor?
        [0, 1].forEach { list in
            (0 ..< app.session.cards(app.project, list: list)).forEach {
                let task = Task($0, list: list, todo: self)
                scroll.add(task)

                if top == nil {
                    task.topAnchor.constraint(equalTo: new.bottomAnchor, constant: 60).isActive = true
                } else {
                    task.topAnchor.constraint(equalTo: top!).isActive = true
                }
                task.leftAnchor.constraint(equalTo: tags.rightAnchor, constant: 20).isActive = true
                task.rightAnchor.constraint(lessThanOrEqualTo: scroll.right, constant: -10).isActive = true
                top = task.bottomAnchor
            }
        }
        if top != nil {
            scroll.bottom.constraint(greaterThanOrEqualTo: top!, constant: 50).isActive = true
        }
        
        ring.topAnchor.constraint(equalTo: scroll.top).isActive = true
        ring.leftAnchor.constraint(equalTo: scroll.left, constant: 30).isActive = true
        tags.widthAnchor.constraint(greaterThanOrEqualTo: ring.widthAnchor).isActive = true
        tags.topAnchor.constraint(equalTo: ring.bottomAnchor, constant: 20).isActive = true
        tags.refresh()
    }
    
    override func found(_ ranges: [(Int, Int, NSRange)]) {
        scroll.views.compactMap { $0 as? Task }.forEach { task in
            let ranges = ranges.filter { $0.0 == task.list && $0.1 == task.index }.map { $0.2 as NSValue }
            if ranges.isEmpty {
                task.text.setSelectedRange(.init())
            } else {
                task.text.setSelectedRanges(ranges, affinity: .downstream, stillSelecting: true)
            }
        }
    }
    
    override func select(_ list: Int, _ card: Int, _ range: NSRange) {
        let text = scroll.views.compactMap { $0 as? Task }.first { $0.list == list && $0.index == card }!.text!
        var frame = scroll.contentView.convert(text.layoutManager!.boundingRect(forGlyphRange: range, in: text.textContainer!), from: text)
        frame.origin.x -= (bounds.width - frame.size.width) / 2
        frame.origin.y -= (bounds.height / 2) - frame.size.height
        frame.size.width = bounds.width
        frame.size.height = bounds.height
        text.showFindIndicator(for: range)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.4
            $0.allowsImplicitAnimation = true
            scroll.contentView.scrollToVisible(frame)
        }
    }
    
    override func add() {
        if new.string.isEmpty {
            window!.makeFirstResponder(new)
        } else {
            if !new.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                app.session.add(app.project, list: 0, content: new.string)
                app.alert(.key("Task"), message: new.string)
                refresh()
            }
            new.string = ""
            new.needsLayout = true
        }
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.4
            $0.allowsImplicitAnimation = true
            scroll.contentView.scroll(to: .zero)
        }
    }
}
