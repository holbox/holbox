import AppKit

final class Detail: Base.View {
    private weak var scroll: Scroll!
    private weak var height: NSLayoutConstraint!
    
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
        app.session.projects.enumerated().forEach {
            let item = Project($0.1, order: $0.0)
            scroll.add(item)
            item.top = item.topAnchor.constraint(equalTo: scroll.top)
            item.left = item.leftAnchor.constraint(equalTo: scroll.left)
        }
        order()
    }
    
    override func viewDidEndLiveResize() {
        super.viewDidEndLiveResize()
        order()
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.4
            $0.allowsImplicitAnimation = true
            scroll.documentView!.layoutSubtreeIfNeeded()
        }
    }
    
    func order() {
        let size = app.main.frame.width + 4
        let count = Int(size) / 164
        let margin = (size - (.init(count) * 164)) / 2
        var top = CGFloat(20)
        var left = margin
        var counter = 0
        scroll.views.map { $0 as! Project }.sorted { $0.order < $1.order }.forEach {
            if counter >= count {
                counter = 0
                left = margin
                top += 174
            }
            $0.top.constant = top
            $0.left.constant = left
            left += 164
            counter += 1
        }
        height.constant = top + 200
    }
    
    @objc private func add() {
        app.runModal(for: Add())
    }
}
