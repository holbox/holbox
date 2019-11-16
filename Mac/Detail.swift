import AppKit

final class Detail: Base.View {
    private weak var scroll: Scroll!
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.right.constraint(equalTo: rightAnchor).isActive = true
        
        refresh()
    }
    
    override func refresh() {
        scroll.views.forEach { $0.removeFromSuperview() }
        
//        if app.session.projects(app.mode).isEmpty {
//            let empty = Label(.key("Detail.empty.\(app.mode.rawValue)"), 16, .medium, NSColor(named: "haze")!.withAlphaComponent(0.6))
//            scroll.add(empty)
//            
//            empty.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
//            empty.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
//            
//            scroll.bottom.constraint(equalTo: empty.bottomAnchor, constant: 40).isActive = true
//        } else {
//            var prev = scroll.top
//            app.session.projects(app.mode).forEach {
//                let item = Project($0)
//                scroll.add(item)
//                
//                item.topAnchor.constraint(equalTo: prev, constant: 20).isActive = true
//                item.leftAnchor.constraint(equalTo: scroll.left, constant: 20).isActive = true
//                item.rightAnchor.constraint(lessThanOrEqualTo: scroll.right, constant: -20).isActive = true
//                prev = item.bottomAnchor
//                
//            }
//            scroll.bottom.constraint(equalTo: prev, constant: 20).isActive = true
//        }
    }
    
    @objc private func add() {
        app.runModal(for: Add())
    }
}
