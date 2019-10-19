import UIKit

final class Add: Modal {
    private weak var _confirm: Control!
    private weak var _purchases: Control!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scroll = Scroll()
        view.addSubview(scroll)
        
        let icon = Image("new")
        
        let title = Label(.key("Add.title.\(app.mode.rawValue)"), 20, .bold, .white)
        
        let subtitle = Label(.key("Add.subtitle.\(app.mode.rawValue)") + .key("Add.subtitle.bottom"), 14, .regular, .init(white: 1, alpha: 0.4))
        subtitle.textAlignment = .center
        
        let available = Label("\(app.session.available)", 60, .light, .haze)
        
        let info = Label(.key("Add.info"), 16, .light, .init(white: 1, alpha: 0.8))
        info.textAlignment = .center
        
        let _confirm = Control(.key("Add.title.\(app.mode.rawValue)"), self, #selector(confirm), .haze, .black)
        self._confirm = _confirm
        
        let _purchases = Control(.key("Add.purchases"), self, #selector(purchases), .haze, .black)
        self._purchases = _purchases
        
        let cancel = Control(.key("Add.cancel"), self, #selector(close), .clear, .init(white: 1, alpha: 0.4))
        
        [title, subtitle, info, _confirm, _purchases, cancel, icon, available].forEach {
            scroll.add($0)
            $0.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
        }
        
        scroll.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scroll.right.constraint(equalTo: view.rightAnchor).isActive = true
        scroll.content.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: cancel.bottomAnchor, constant: 20).isActive = true
        
        icon.topAnchor.constraint(equalTo: scroll.content.safeAreaLayoutGuide.topAnchor, constant: 80).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 60).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        title.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 30).isActive = true
        
        subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10).isActive = true
        
        available.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 20).isActive = true
        
        info.widthAnchor.constraint(equalTo: scroll.content.safeAreaLayoutGuide.widthAnchor, multiplier: 0.6).isActive = true
        info.topAnchor.constraint(equalTo: available.bottomAnchor, constant: 20).isActive = true
        
        _confirm.widthAnchor.constraint(equalTo: scroll.content.safeAreaLayoutGuide.widthAnchor, multiplier: 0.6).isActive = true
        _confirm.topAnchor.constraint(equalTo: available.bottomAnchor, constant: 20).isActive = true
        
        _purchases.widthAnchor.constraint(equalTo: scroll.content.safeAreaLayoutGuide.widthAnchor, multiplier: 0.6).isActive = true
        _purchases.topAnchor.constraint(equalTo: info.bottomAnchor, constant: 20).isActive = true
        
        cancel.widthAnchor.constraint(equalTo: scroll.content.widthAnchor, multiplier: 0.6).isActive = true
        
        if app.session.available > 0 {
            info.isHidden = true
            _purchases.isHidden = true
            _purchases.target = nil
            cancel.topAnchor.constraint(equalTo: _confirm.bottomAnchor, constant: 10).isActive = true
        } else {
            _confirm.isHidden = true
            _confirm.target = nil
            cancel.topAnchor.constraint(equalTo: _purchases.bottomAnchor, constant: 10).isActive = true
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
