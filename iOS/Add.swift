import UIKit

final class Add: Modal {
    private weak var _confirm: Control!
    private weak var _purchases: Control!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            view.addSubview($0)
            $0.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        }
        
        icon.bottomAnchor.constraint(equalTo: title.topAnchor, constant: -40).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 60).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        title.bottomAnchor.constraint(equalTo: subtitle.topAnchor, constant: -10).isActive = true
        
        subtitle.bottomAnchor.constraint(equalTo: available.topAnchor, constant: -50).isActive = true
        
        available.bottomAnchor.constraint(equalTo: info.topAnchor, constant: -50).isActive = true
        
        info.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.7).isActive = true
        info.bottomAnchor.constraint(equalTo: _purchases.topAnchor, constant: -20).isActive = true
        
        _confirm.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.7).isActive = true
        _confirm.bottomAnchor.constraint(equalTo: cancel.topAnchor).isActive = true
        
        _purchases.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.7).isActive = true
        _purchases.bottomAnchor.constraint(equalTo: cancel.topAnchor).isActive = true
        
        cancel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.7).isActive = true
        cancel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        
        if app.session.available > 0 {
            info.isHidden = true
            _purchases.isHidden = true
            _purchases.target = nil
        } else {
            _confirm.isHidden = true
            _confirm.target = nil
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
