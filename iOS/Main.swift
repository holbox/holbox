import UIKit

final class Main: UIView {
    private(set) weak var bar: Bar!
    private weak var base: Base!
    private weak var logo: Logo?
    private weak var bottom: NSLayoutConstraint?
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        let logo = Logo()
        logo.start()
        addSubview(logo)
        self.logo = logo
        
        logo.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        logo.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(show(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hide), name: UIResponder.keyboardWillHideNotification, object: nil)
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
        base.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        base.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        bottom = base.bottomAnchor.constraint(equalTo: bottomAnchor)
        bottom!.priority = .defaultLow
        bottom!.isActive = true
        
        layoutIfNeeded()
        refresh()
    }
    
    func refresh() {
        bar.refresh()
        base.refresh()
    }
    
    func rotate() {
        base?.rotate()
    }
    
    @objc private func show(_ notification: Notification) {
        bottom?.constant = -((notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height - safeAreaInsets.bottom)
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.layoutIfNeeded()
        }
    }

    @objc private func hide() {
        bottom?.constant = 0
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.layoutIfNeeded()
        }
    }
}
