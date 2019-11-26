import UIKit

final class Main: UIView {
    private(set) weak var bar: Bar!
    private weak var base: Base!
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
        
        bar.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bar.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        bar.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        base.topAnchor.constraint(equalTo: bar.bottomAnchor).isActive = true
        base.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        base.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        base.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        refresh()
    }
    
    func refresh() {
        bar.refresh()
        base.refresh()
    }
    
    func rotate() {
        base.rotate()
    }
    
    @objc func shop() {
//        app.runModal(for: Shop())
    }
    
    @objc func settings() {
//        app.runModal(for: Settings())
    }
}
