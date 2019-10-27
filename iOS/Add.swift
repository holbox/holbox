import UIKit

final class Add: Modal {
    private weak var _confirm: Control!
    private weak var _purchases: Control!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let scroll = Scroll()
        view.addSubview(scroll)
        
        let icon = Image("new")
        scroll.add(icon)
        
        let title = Label(.key("Add.title.\(app.mode.rawValue)"), 25, .bold, .white)
        scroll.add(title)
        
        let subtitle = Label(.key("Add.subtitle.\(app.mode.rawValue)") + .key("Add.subtitle.bottom"), 14, .regular, .init(white: 1, alpha: 0.6))
        subtitle.textAlignment = .center
        
        let available = Label("\(app.session.available)", 40, .light, UIColor(named: "haze")!)
        
        let capacity = Label([(.key("Add.projects.title"), 14, .bold, .init(white: 1, alpha: 0.4)),
                              ("\(app.session.count)", 16, .light, .init(white: 1, alpha: 0.8)),
                              (.key("Add.capacity.title"), 14, .bold, .init(white: 1, alpha: 0.4)),
                              ("\(app.session.capacity)", 16, .light, .init(white: 1, alpha: 0.8))])
        
        let info = Label(.key("Add.info"), 16, .regular, .white)
        
        let _confirm = Control(.key("Add.title.\(app.mode.rawValue)"), self, #selector(confirm), UIColor(named: "haze")!, .black)
        self._confirm = _confirm
        
        let _purchases = Control(.key("Add.purchases"), self, #selector(purchases), UIColor(named: "haze")!, .black)
        self._purchases = _purchases
        
        let cancel = Control(.key("Add.cancel"), self, #selector(close), .clear, .init(white: 1, alpha: 0.6))
        
        [subtitle, available, capacity, info, _confirm, _purchases, cancel].forEach {
            scroll.add($0)
            $0.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
        }
        
        scroll.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scroll.content.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        scroll.content.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: cancel.bottomAnchor, constant: 10).isActive = true
        
        icon.topAnchor.constraint(equalTo: scroll.content.safeAreaLayoutGuide.topAnchor, constant: 70).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 60).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 60).isActive = true
        icon.rightAnchor.constraint(equalTo: scroll.centerX, constant: -50).isActive = true
        
        title.centerYAnchor.constraint(equalTo: icon.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 10).isActive = true
        
        subtitle.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 30).isActive = true
        
        available.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 30).isActive = true
        
        capacity.topAnchor.constraint(equalTo: available.bottomAnchor, constant: 10).isActive = true
        
        info.widthAnchor.constraint(equalToConstant: 250).isActive = true
        info.topAnchor.constraint(equalTo: capacity.bottomAnchor, constant: 30).isActive = true
        
        _confirm.widthAnchor.constraint(equalToConstant: 140).isActive = true
        _confirm.topAnchor.constraint(equalTo: capacity.bottomAnchor, constant: 20).isActive = true
        
        _purchases.widthAnchor.constraint(equalToConstant: 140).isActive = true
        _purchases.topAnchor.constraint(equalTo: info.bottomAnchor, constant: 30).isActive = true
        
        cancel.widthAnchor.constraint(equalToConstant: 140).isActive = true
        
        if app.session.available > 0 {
            info.isHidden = true
            _purchases.isHidden = true
            _purchases.target = nil
            cancel.topAnchor.constraint(equalTo: _confirm.bottomAnchor).isActive = true
            
        } else {
            _confirm.isHidden = true
            _confirm.target = nil
            cancel.topAnchor.constraint(equalTo: _purchases.bottomAnchor).isActive = true
        }
    }
    
    @objc private func confirm() {
        _confirm.target = nil
        app.session.add(app.mode)
        app.main.project(0)
        close()
    }
    
    @objc private func purchases() {
        _purchases.target = nil
        app.main.shop()
        close()
    }
}
