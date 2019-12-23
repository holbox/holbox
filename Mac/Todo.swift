import AppKit

final class Todo: View {
    private(set) weak var scroll: Scroll!
    private weak var text: Text!
    private weak var ring: Ring!
    private weak var timeline: Timeline!
    private weak var count: Label!
    private weak var _bottom: NSLayoutConstraint!
    
    weak var _last: Task? {
        didSet {
            _bottom?.isActive = false
            if _last != nil {
                _bottom = scroll.bottom.constraint(greaterThanOrEqualTo: _last!.bottomAnchor, constant: 30)
                _bottom.isActive = true
            }
        }
    }
    
    required init?(coder: NSCoder) { nil }
    required init() {
        super.init()
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let vertical = Border.vertical()
        addSubview(vertical)
        
        let horizontal = Border.horizontal()
        addSubview(horizontal)
        
        let ring = Ring()
        addSubview(ring)
        self.ring = ring
        
        let count = Label([])
        count.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        addSubview(count)
        self.count = count
        
        let timeline = Timeline()
        addSubview(timeline)
        self.timeline = timeline
        
        let _add = Button("plus", target: self, action: #selector(add))
        _add.setAccessibilityLabel(.key("Todo.add"))
        addSubview(_add)
        
        let text = Text(.Fix(), Active(), storage: Storage())
        text.textContainerInset.width = 10
        text.textContainerInset.height = 10
        text.setAccessibilityLabel(.key("Task"))
        text.font = .regular(14)
        (text.textStorage as! Storage).attributes = [.plain: [.font: NSFont.regular(14), .foregroundColor: NSColor.white],
                                                     .emoji: [.font: NSFont.regular(18)],
                                                     .bold: [.font: NSFont.medium(16), .foregroundColor: NSColor.white],
                                                     .tag: [.font: NSFont.medium(12), .foregroundColor: NSColor.haze()]]
        text.intro = true
        text.tab = true
        (text.layoutManager as! Layout).padding = 2
        addSubview(text)
        self.text = text
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        scroll.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 1).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        scroll.widthAnchor.constraint(lessThanOrEqualToConstant: 900).isActive = true
        scroll.width.constraint(equalTo: scroll.widthAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: scroll.bottomAnchor).isActive = true
        
        let width = scroll.widthAnchor.constraint(equalToConstant: 900)
        width.priority = .defaultLow
        width.isActive = true
        
        vertical.topAnchor.constraint(equalTo: scroll.topAnchor).isActive = true
        vertical.bottomAnchor.constraint(equalTo: scroll.bottomAnchor).isActive = true
        vertical.rightAnchor.constraint(equalTo: scroll.leftAnchor).isActive = true
        
        horizontal.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
        horizontal.rightAnchor.constraint(equalTo: vertical.leftAnchor).isActive = true
        horizontal.bottomAnchor.constraint(equalTo: text.topAnchor, constant: -5).isActive = true
        let horizontalBottom = horizontal.bottomAnchor.constraint(equalTo: bottomAnchor)
        horizontalBottom.priority = .defaultLow
        horizontalBottom.isActive = true
        
        text.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        text.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        text.rightAnchor.constraint(equalTo: _add.leftAnchor).isActive = true
        
        _add.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        _add.rightAnchor.constraint(equalTo: vertical.leftAnchor).isActive = true
        _add.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _add.heightAnchor.constraint(equalToConstant: 55).isActive = true
        
        count.centerYAnchor.constraint(equalTo: ring.centerYAnchor).isActive = true
        count.leftAnchor.constraint(equalTo: ring.rightAnchor, constant: 5).isActive = true
        count.rightAnchor.constraint(lessThanOrEqualTo: vertical.leftAnchor, constant: -25).isActive = true
        
        ring.topAnchor.constraint(equalTo: timeline.bottomAnchor, constant: 10).isActive = true
        ring.bottomAnchor.constraint(lessThanOrEqualTo: horizontal.topAnchor, constant: -20).isActive = true
        let ringLeft = ring.leftAnchor.constraint(equalTo: leftAnchor, constant: 30)
        ringLeft.priority = .defaultLow
        ringLeft.isActive = true
        
        timeline.rightAnchor.constraint(lessThanOrEqualTo: vertical.leftAnchor, constant: -25).isActive = true
        let timelineLeft = timeline.leftAnchor.constraint(equalTo: leftAnchor, constant: 25)
        timelineLeft.priority = .defaultLow
        timelineLeft.isActive = true
        let timelineTop = timeline.topAnchor.constraint(equalTo: topAnchor, constant: 10)
        timelineTop.priority = .defaultLow
        timelineTop.isActive = true
        
        refresh()
    }
    
    override func refresh() {
        scroll.views.forEach { $0.removeFromSuperview() }
        
        var _last: Task?
        [0, 1].forEach { list in
            (0 ..< app.session.cards(app.project, list: list)).forEach {
                let task = Task($0, list: list, todo: self)
                scroll.add(task)
                
                task._parent = _last == nil ? scroll : _last
                task.leftAnchor.constraint(greaterThanOrEqualTo: scroll.left, constant: 6).isActive = true
                task.rightAnchor.constraint(lessThanOrEqualTo: scroll.right, constant: -6).isActive = true
                
                let left = task.leftAnchor.constraint(equalTo: scroll.left, constant: 50)
                left.priority = .defaultLow
                left.isActive = true
                
                let right = task.rightAnchor.constraint(equalTo: scroll.right, constant: -50)
                right.priority = .defaultLow
                right.isActive = true
                
                _last = task
            }
        }
        
        self._last = _last
        charts()
    }
    
    override func viewDidEndLiveResize() {
        timeline.refresh()
    }
    
    override func keyDown(with: NSEvent) {
        switch with.keyCode {
        case 36:
            add()
        case 53:
            text.string = ""
            text.needsLayout = true
        default: super.keyDown(with: with)
        }
    }
    
    override func add() {
        if text.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            window!.makeFirstResponder(text)
        } else {
            app.session.add(app.project, list: 0, content: text.string)
            app.alert(.key("Task"), message: text.string)
            NSAnimationContext.runAnimationGroup {
                $0.duration = 0.3
                $0.allowsImplicitAnimation = true
                scroll.contentView.scroll(to: .zero)
            }
            refresh()
            text.string = ""
            text.needsLayout = true
        }
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
        text.showFindIndicator(for: range)
        scroll.center(scroll.contentView.convert(text.layoutManager!.boundingRect(forGlyphRange: range, in: text.textContainer!), from: text))
    }
    
    func charts() {
        let amount = app.session.cards(app.project, list: 0) + app.session.cards(app.project, list: 1)
        count.attributed([("\(amount)", .medium(18), .haze()), ("\n" + (amount == 1 ? .key("Todo.count") : .key("Todo.counts")), .regular(12), .haze())])
        ring.current = .init(app.session.cards(app.project, list: 1))
        ring.total = .init(app.session.cards(app.project, list: 0) + app.session.cards(app.project, list: 1))
        ring.refresh()
        DispatchQueue.main.async { [weak self] in
            self?.timeline.refresh()
        }
    }
}
