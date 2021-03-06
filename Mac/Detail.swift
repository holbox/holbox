import AppKit

final class Detail: View {
    private weak var scroll: Scroll!
    private weak var height: NSLayoutConstraint!
    
    override var frame: NSRect {
        didSet {
            order()
        }
    }
    
    required init?(coder: NSCoder) { nil }
    required init() {
        super.init()
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.right.constraint(equalTo: rightAnchor).isActive = true
        height = scroll.bottom.constraint(equalTo: scroll.top)
        height.isActive = true
        
        refresh()
    }
    
    override func refresh() {
        scroll.views.forEach { $0.removeFromSuperview() }
        app.session.projects(app.main.bar.find.filter).enumerated().forEach {
            let item = Project($0.1, order: $0.0)
            scroll.add(item)
            item.top = item.topAnchor.constraint(equalTo: scroll.top)
            item.left = item.leftAnchor.constraint(equalTo: scroll.left)
        }
        order()
    }
    
    override func add() {
        app.runModal(for: Add())
    }
    
    private func order() {
        let size = app.main.frame.width + 20
        let count = Int(size) / 220
        let margin = (size - (.init(count) * 220)) / 2
        var top = CGFloat(30)
        var left = margin
        var counter = 0
        scroll.views.map { $0 as! Project }.sorted { $0.order < $1.order }.forEach {
            if counter >= count {
                counter = 0
                left = margin
                top += 240
            }
            $0.top.constant = top
            $0.left.constant = left
            left += 220
            counter += 1
        }
        height.constant = top + 260
    }
}
