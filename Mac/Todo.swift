import AppKit

final class Todo: View, NSTextViewDelegate {
    private(set) weak var tags: Tags!
    private weak var ring: Ring!
    private weak var scroll: Scroll!
    private weak var new: Text!
    private weak var _add: Button!
    private weak var _bottom: NSLayoutConstraint!
    
    required init?(coder: NSCoder) { nil }
    required init() {
        super.init()
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let border = Border.vertical()
        addSubview(border)
        
        let tags = Tags()
        addSubview(tags)
        self.tags = tags
        
        let base = NSView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.wantsLayer = true
        base.layer!.cornerRadius = 6
        base.layer!.borderWidth = 1
        base.layer!.borderColor = .black
        base.layer!.backgroundColor = NSColor(named: "background")!.cgColor
        addSubview(base)
        
        let new = Text(.Fix(), Active())
        new.textContainerInset.width = 30
        new.textContainerInset.height = 20
        new.setAccessibilityLabel(.key("Task"))
        new.font = NSFont(name: "Times New Roman", size: 14)
        (new.textStorage as! Storage).fonts = [.plain: (.systemFont(ofSize: 14, weight: .regular), .white),
                                               .emoji: (NSFont(name: "Times New Roman", size: 18)!, .white),
                                               .bold: (.systemFont(ofSize: 16, weight: .bold), NSColor(named: "haze")!),
                                               .tag: (.systemFont(ofSize: 14, weight: .medium), NSColor(named: "haze")!)]
        new.intro = true
        new.tab = true
        new.delegate = self
        base.addSubview(new)
        self.new = new
        
        let _add = Button("plus", target: self, action: #selector(add))
        _add.setAccessibilityLabel(.key("Todo.add"))
        addSubview(_add)
        self._add = _add
        
        let _clear = Button("clear", target: self, action: #selector(clear))
        base.addSubview(_clear)
        
        let _create = Control(.key("Todo.create"), self, #selector(create), NSColor(named: "haze")!.withAlphaComponent(0.1).cgColor, NSColor(named: "haze")!)
        base.addSubview(_create)
        
        let ring = Ring()
        addSubview(ring)
        self.ring = ring
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        scroll.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 1).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        scroll.widthAnchor.constraint(lessThanOrEqualToConstant: 400).isActive = true
        scroll.width.constraint(equalTo: scroll.widthAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: scroll.bottomAnchor).isActive = true
        
        border.topAnchor.constraint(equalTo: scroll.topAnchor).isActive = true
        border.bottomAnchor.constraint(equalTo: scroll.bottomAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: scroll.leftAnchor).isActive = true
        
        tags.rightAnchor.constraint(lessThanOrEqualTo: border.leftAnchor).isActive = true
        tags.topAnchor.constraint(equalTo: ring.bottomAnchor, constant: 50).isActive = true
        let tagsLeft = tags.leftAnchor.constraint(equalTo: leftAnchor, constant: 25)
        tagsLeft.priority = .defaultLow
        tagsLeft.isActive = true
        
        ring.rightAnchor.constraint(lessThanOrEqualTo: border.leftAnchor).isActive = true
        ring.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        let ringLeft = ring.leftAnchor.constraint(equalTo: leftAnchor, constant: 25)
        ringLeft.priority = .defaultLow
        ringLeft.isActive = true
        
        base.leftAnchor.constraint(equalTo: scroll.left, constant: 30).isActive = true
        base.rightAnchor.constraint(equalTo: scroll.right, constant: -30).isActive = true
        base.topAnchor.constraint(equalTo: new.topAnchor, constant: -10).isActive = true
        _bottom = base.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 150)
        _bottom.isActive = true
        
        _create.bottomAnchor.constraint(equalTo: base.bottomAnchor).isActive = true
        _create.leftAnchor.constraint(equalTo: base.leftAnchor).isActive = true
        _create.rightAnchor.constraint(equalTo: base.rightAnchor).isActive = true
        
        new.bottomAnchor.constraint(equalTo: _create.topAnchor).isActive = true
        new.leftAnchor.constraint(equalTo: base.leftAnchor).isActive = true
        new.rightAnchor.constraint(equalTo: base.rightAnchor).isActive = true
        
        _clear.topAnchor.constraint(equalTo: base.topAnchor).isActive = true
        _clear.leftAnchor.constraint(equalTo: base.leftAnchor).isActive = true
        _clear.widthAnchor.constraint(equalToConstant: 35).isActive = true
        _clear.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        _add.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
        _add.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
        _add.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _add.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        refresh()
    }
    
    override func keyDown(with: NSEvent) {
        switch with.keyCode {
        case 36:
            if with.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command {
                if _add.isHidden {
                    create()
                } else {
                    add()
                }
            } else {
                window!.makeFirstResponder(new)
                new.setSelectedRange(.init(location: new.string.count, length: 0))
            }
        case 48:
            window!.makeFirstResponder(new)
            new.setSelectedRange(.init(location: 0, length: new.string.count))
        case 53:
            clear()
        default: super.keyDown(with: with)
        }
    }
    
    override func refresh() {
        scroll.views.forEach { $0.removeFromSuperview() }
        
        if app.session.cards(app.project, list: 0) > 0 {
            var top = scroll.top
            (0 ..< app.session.cards(app.project, list: 0)).forEach {
                let task = Task($0, todo: self)
                scroll.add(task)
                
                if $0 > 0 {
                    let border = Border.horizontal(0.2)
                    scroll.add(border)
                    
                    border.topAnchor.constraint(equalTo: top).isActive = true
                    border.leftAnchor.constraint(equalTo: scroll.left).isActive = true
                    border.rightAnchor.constraint(equalTo: scroll.right).isActive = true
                    top = border.bottomAnchor
                }

                task.topAnchor.constraint(equalTo: top).isActive = true
                task.leftAnchor.constraint(equalTo: scroll.left).isActive = true
                task.rightAnchor.constraint(equalTo: scroll.right).isActive = true
                top = task.bottomAnchor
            }
            
            scroll.bottom.constraint(greaterThanOrEqualTo: top, constant: 100).isActive = true
        }
    
        ring.current = .init(app.session.cards(app.project, list: 1))
        ring.total = .init(app.session.cards(app.project, list: 0) + app.session.cards(app.project, list: 1))
        ring.refresh()
        tags.refresh()
    }
    
    override func found(_ ranges: [(Int, Int, NSRange)]) {
        scroll.views.compactMap { $0 as? Task }.forEach { task in
            let ranges = ranges.filter { $0.0 == 0 && $0.1 == task.index }.map { $0.2 as NSValue }
            if ranges.isEmpty {
                task.text.setSelectedRange(.init())
            } else {
                task.text.setSelectedRanges(ranges, affinity: .downstream, stillSelecting: true)
            }
        }
    }
    
    override func select(_ list: Int, _ card: Int, _ range: NSRange) {
        if list == 0 {
            let text = scroll.views.compactMap { $0 as? Task }.first { $0.index == card }!.text!
            text.showFindIndicator(for: range)
            scroll.center(scroll.contentView.convert(text.layoutManager!.boundingRect(forGlyphRange: range, in: text.textContainer!), from: text))
        }
    }
    
    override func add() {
        guard window!.firstResponder != new else { return }
        _bottom.constant = -50
        _add.isHidden = true
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.4
            $0.allowsImplicitAnimation = true
            layoutSubtreeIfNeeded()
        }) { [weak self] in
            self?.window?.makeFirstResponder(self?.new)
        }
    }
    
    @objc private func create() {
        if !new.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            app.session.add(app.project, list: 0, content: new.string)
            app.alert(.key("Task"), message: new.string)
            NSAnimationContext.runAnimationGroup {
                $0.duration = 0.3
                $0.allowsImplicitAnimation = true
                scroll.contentView.scroll(to: .zero)
            }
            refresh()
            scroll.documentView!.layoutSubtreeIfNeeded()
            clear()
        } else {
            window?.makeFirstResponder(new)
        }
    }
    
    @objc private func clear() {
        window!.makeFirstResponder(self)
        new.string = ""
        new.needsLayout = true
        _bottom.constant = 150
        _add.alphaValue = 1
        _add.isHidden = false
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            layoutSubtreeIfNeeded()
        }
    }
}
