import UIKit

final class Main: UIView {
    private(set) weak var base: UIView?
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
        
        let base = UIView()
        base.translatesAutoresizingMaskIntoConstraints = false
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
        switch app.mode {
//        case .kanban: show(Kanban())
        default: break
        }
    }
    
    @objc func kanban() {
        app.mode = .kanban
        bar?._kanban.selected = true
        bar?._todo.selected = false
        bar?._shopping.selected = false
        bar?._shop.selected = false
        show(Detail())
    }
    
    @objc func todo() {
        app.mode = .todo
        bar?._kanban.selected = false
        bar?._todo.selected = true
        bar?._shopping.selected = false
        bar?._shop.selected = false
        show(Detail())
    }
    
    @objc func shopping() {
        app.mode = .shopping
        bar?._kanban.selected = false
        bar?._todo.selected = false
        bar?._shopping.selected = true
        bar?._shop.selected = false
        show(Detail())
    }
    
    @objc func shop() {
        app.mode = .off
        bar?._kanban.selected = false
        bar?._todo.selected = false
        bar?._shopping.selected = false
        bar?._shop.selected = true
        show(Shop())
    }
    
    @objc func more() {
        
    }
    
    @objc func about() {
        
    }
    
    private func show(_ view: UIView) {
        guard let base = self.base else { return }
        base.subviews.forEach { $0.removeFromSuperview() }
        view.alpha = 0
        base.addSubview(view)
        
        view.topAnchor.constraint(equalTo: base.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: base.bottomAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: base.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: base.rightAnchor).isActive = true
        
        UIView.animate(withDuration: 0.4) { [weak view] in view?.alpha = 1 }
    }
}
