import AppKit

final class Todo: View {
    private(set) weak var scroll: Scroll!
    private weak var tasker: Tasker!
    private weak var ring: Ring!
    private weak var timeline: Timeline!
    private weak var count: Label!
    
    required init?(coder: NSCoder) { nil }
    required init() {
        super.init()
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let border = Border.vertical()
        addSubview(border)
        
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
        
        let tasker = Tasker(self)
        addSubview(tasker)
        self.tasker = tasker
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        scroll.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 1).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        scroll.widthAnchor.constraint(lessThanOrEqualToConstant: 600).isActive = true
        scroll.width.constraint(equalTo: scroll.widthAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: scroll.bottomAnchor).isActive = true
        
        let width = scroll.widthAnchor.constraint(equalToConstant: 600)
        width.priority = .defaultLow
        width.isActive = true
        
        border.topAnchor.constraint(equalTo: scroll.topAnchor).isActive = true
        border.bottomAnchor.constraint(equalTo: scroll.bottomAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: scroll.leftAnchor).isActive = true
        
        tasker.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30).isActive = true
        tasker.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
        
        count.centerYAnchor.constraint(equalTo: ring.centerYAnchor).isActive = true
        count.leftAnchor.constraint(equalTo: ring.rightAnchor, constant: 5).isActive = true
        count.rightAnchor.constraint(lessThanOrEqualTo: border.leftAnchor, constant: -25).isActive = true
        
        ring.topAnchor.constraint(equalTo: topAnchor, constant: 30).isActive = true
        let ringLeft = ring.leftAnchor.constraint(equalTo: leftAnchor, constant: 30)
        ringLeft.priority = .defaultLow
        ringLeft.isActive = true
        
        timeline.rightAnchor.constraint(lessThanOrEqualTo: border.leftAnchor, constant: -25).isActive = true
        timeline.topAnchor.constraint(greaterThanOrEqualTo: ring.bottomAnchor).isActive = true
        let timelineLeft = timeline.leftAnchor.constraint(equalTo: leftAnchor, constant: 25)
        timelineLeft.priority = .defaultLow
        timelineLeft.isActive = true
        let timelineBottom = timeline.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        timelineBottom.priority = .defaultLow
        timelineBottom.isActive = true
        
        refresh()
    }
    
    override func refresh() {
        scroll.views.forEach { $0.removeFromSuperview() }
        
        var top = scroll.top
        [0, 1].forEach { list in
            (0 ..< app.session.cards(app.project, list: list)).forEach {
                let task = Task($0, list: list, todo: self)
                scroll.add(task)
                
                task.topAnchor.constraint(equalTo: top, constant: 2).isActive = true
                task.leftAnchor.constraint(equalTo: scroll.left).isActive = true
                task.rightAnchor.constraint(equalTo: scroll.right).isActive = true
                top = task.bottomAnchor
            }
        }
        
        if top != scroll.top {
            scroll.bottom.constraint(greaterThanOrEqualTo: top).isActive = true
        }
    
        ring.current = .init(app.session.cards(app.project, list: 1))
        ring.total = .init(app.session.cards(app.project, list: 0) + app.session.cards(app.project, list: 1))
        ring.refresh()
        count.attributed([("\(app.session.cards(app.project, list: 0) + app.session.cards(app.project, list: 1))", .medium(18), .haze()), ("\n" + .key("Todo.count"), .regular(12), .haze())])
        DispatchQueue.main.async { [weak self] in
            self?.timeline.refresh()
        }
    }
    
    override func viewDidEndLiveResize() {
        timeline.refresh()
    }
    
    override func add() {
        tasker.add()
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
}
