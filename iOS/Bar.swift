import UIKit

final class Bar: UIView {
    private(set) weak var find: Find!
    private weak var _home: Button!
    private weak var border: Border!
    private weak var bottom: NSLayoutConstraint? { didSet { oldValue?.isActive = false; bottom!.isActive = true } }
    private weak var addRight: NSLayoutConstraint!
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let border = Border()
        border.alpha = 0
        addSubview(border)
        self.border = border
        
        let _home = Button("logo", target: self, action: #selector(home), padding: 15)
        _home.accessibilityLabel = .key("Bar.home")
        _home.icon.contentMode = .scaleAspectFit
        _home.alpha = 0
        self._home = _home
        
        let _add = Button("add", target: self, action: #selector(add))
        _add.accessibilityLabel = .key("Bar.add")
        
        let _shop = Button("cart", target: app.main, action: #selector(app.main.shop))
        _shop.accessibilityLabel = .key("Bar.shop")
        
        let _settings = Button("more", target: app.main, action: #selector(app.main.settings))
        _settings.accessibilityLabel = .key("Bar.settings")
        
        let find = Find()
        find.alpha = 0
        addSubview(find)
        self.find = find
        
        [_home, _add, _shop, _settings].forEach {
            addSubview($0)
            
            $0.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            $0.widthAnchor.constraint(equalToConstant: 60).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 60).isActive = true
        }
        
        addRight = _add.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -240)
        addRight.isActive = true
        
        _home.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        
        _shop.leftAnchor.constraint(equalTo: _add.rightAnchor, constant: 20).isActive = true
        
        _settings.leftAnchor.constraint(equalTo: _shop.rightAnchor, constant: 20).isActive = true
        
        border.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
    
    func refresh() {
        if app.project == nil {
            if app.session.projects().isEmpty {
                empty()
            } else {
                detail()
            }
        } else {
            project()
        }
    }
    
    private func project() {
        
    }
    
    private func detail() {
        bottom = bottomAnchor.constraint(equalTo: superview!.safeAreaLayoutGuide.topAnchor, constant: 120)
        addRight.constant = -240
        UIView.animate(withDuration: 0.35) {
            self._home.alpha = 0
            self.border.alpha = 1
            self.layoutIfNeeded()
        }
    }
    
    private func empty() {
        bottom = bottomAnchor.constraint(equalTo: superview!.bottomAnchor)
        addRight.constant = ((min(app.main.bounds.width, app.main.bounds.height) - 260) / -2) - 240
        UIView.animate(withDuration: 0.35) {
            self._home.alpha = 0
            self.border.alpha = 0
            self.layoutIfNeeded()
        }
    }
    
    @objc private func home() {
        app.window!.endEditing(true)
        app.project = nil
    }
    
    @objc private func add() {
//        app.runModal(for: Add())
    }
}
