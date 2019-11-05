import UIKit

final class Main: UIView {
    private(set) weak var base: Base?
    private weak var bar: Bar?
    private weak var logo: Logo?
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        
        let logo = Logo()
        logo.start()
        addSubview(logo)
        self.logo = logo
        
        logo.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        logo.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    func loaded() {
        logo!.stop()
        logo!.removeFromSuperview()
        
        let bar = Bar()
        addSubview(bar)
        self.bar = bar
        
        let base = Base()
        addSubview(base)
        self.base = base
        
        bar.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bar.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        bar.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        base.topAnchor.constraint(equalTo: topAnchor).isActive = true
        base.bottomAnchor.constraint(equalTo: bar.topAnchor).isActive = true
        base.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        base.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        kanban()
    }
    
    func project(_ project: Int) {
        app.project = project
        bar?._kanban.selected = false
        bar?._todo.selected = false
        bar?._shopping.selected = false
        bar?._shop.selected = false
        switch app.mode {
        case .kanban: base?.show(Kanban())
        case .todo: base?.show(Todo())
        default: break
        }
    }
    
    @objc func kanban() {
        app.refresh()
        app.mode = .kanban
        bar?._kanban.selected = true
        bar?._todo.selected = false
        bar?._shopping.selected = false
        bar?._shop.selected = false
        base?.show(Detail())
    }
    
    @objc func todo() {
        app.refresh()
        app.mode = .todo
        bar?._kanban.selected = false
        bar?._todo.selected = true
        bar?._shopping.selected = false
        bar?._shop.selected = false
        base?.show(Detail())
    }
    
    @objc func shopping() {
        app.refresh()
        app.mode = .shopping
        bar?._kanban.selected = false
        bar?._todo.selected = false
        bar?._shopping.selected = true
        bar?._shop.selected = false
        base?.show(Detail())
    }
    
    @objc func shop() {
        app.mode = .off
        bar?._kanban.selected = false
        bar?._todo.selected = false
        bar?._shopping.selected = false
        bar?._shop.selected = true
        base?.show(Shop())
    }
    
    @objc func more() {
        app.present(About(), animated: true)
    }
}
