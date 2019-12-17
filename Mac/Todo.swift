import AppKit

final class Todo: View {
    private(set) weak var tags: Tags!
    private(set) weak var scroll: Scroll!
    private weak var tasker: Tasker!
    private weak var ring: Ring!
    
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
        
        let ring = Ring()
        addSubview(ring)
        self.ring = ring
        
        let tasker = Tasker(self)
        addSubview(tasker)
        self.tasker = tasker
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        scroll.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 1).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        scroll.widthAnchor.constraint(lessThanOrEqualToConstant: 500).isActive = true
        scroll.width.constraint(equalTo: scroll.widthAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: scroll.bottomAnchor).isActive = true
        
        let width = scroll.widthAnchor.constraint(equalToConstant: 500)
        width.priority = .defaultLow
        width.isActive = true
        
        border.topAnchor.constraint(equalTo: scroll.topAnchor).isActive = true
        border.bottomAnchor.constraint(equalTo: scroll.bottomAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: scroll.leftAnchor).isActive = true
        
        tasker.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30).isActive = true
        tasker.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
        
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
        
        refresh()
    }
    
    override func refresh() {
        scroll.views.forEach { $0.removeFromSuperview() }
        
        var top: NSLayoutYAxisAnchor!
        [0, 1].forEach { list in
            (0 ..< app.session.cards(app.project, list: list)).forEach {
                let task = Task($0, list: list, todo: self)
                scroll.add(task)
                
                if top != nil {
                    let border = Border.horizontal(0.2)
                    scroll.add(border)
                    
                    border.topAnchor.constraint(equalTo: top).isActive = true
                    border.leftAnchor.constraint(equalTo: scroll.left).isActive = true
                    border.rightAnchor.constraint(equalTo: scroll.right).isActive = true
                    
                    task.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
                } else {
                    task.topAnchor.constraint(equalTo: scroll.top, constant: 20).isActive = true
                }
                
                task.leftAnchor.constraint(equalTo: scroll.left).isActive = true
                task.rightAnchor.constraint(equalTo: scroll.right).isActive = true
                top = task.bottomAnchor
            }
        }
        
        if top != nil {
            scroll.bottom.constraint(greaterThanOrEqualTo: top, constant: 100).isActive = true
        }
    
        ring.current = .init(app.session.cards(app.project, list: 1))
        ring.total = .init(app.session.cards(app.project, list: 0) + app.session.cards(app.project, list: 1))
        ring.refresh()
        tags.refresh()
    }
    
    override func add() {
        tasker.add()
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
}
