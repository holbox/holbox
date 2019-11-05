import UIKit

final class Base: UIView {
    class View: UIView {
        required init?(coder: NSCoder) { nil }
        init() {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        
        func refresh() {
            isUserInteractionEnabled = false
        }
        
        @objc final func more() {
            app.present(More(self), animated: true)
        }
    }
    
    private weak var top: NSLayoutConstraint?
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
    }
    
    func show(_ view: View) {
        if let previous = subviews.last {
            view.backgroundColor = .black
            view.layer.cornerRadius = 20
            addSubview(view)
            
            view.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
            view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            let top = view.topAnchor.constraint(equalTo: topAnchor, constant: bounds.height)
            top.isActive = true
            let previousTop = self.top
            layoutIfNeeded()
            backgroundColor = UIColor(named: "background")!
            previousTop?.constant = 220
            top.constant = 230
            
            UIView.animate(withDuration: 0.3, animations: {
                self.layoutIfNeeded()
            }) { _ in
                top.constant = 0
                previousTop?.constant = 230
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.layoutIfNeeded()
                }) { _ in
                    previous.removeFromSuperview()
                    view.backgroundColor = .clear
                    view.layer.cornerRadius = 0
                    self.backgroundColor = .clear
                    self.top = top
                }
            }
        } else {
            view.alpha = 0
            addSubview(view)
            
            view.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
            view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            top = view.topAnchor.constraint(equalTo: topAnchor)
            top!.isActive = true
            
            UIView.animate(withDuration: 1) { [weak view] in view?.alpha = 1 }
        }
    }
    
    func refresh() {
        (subviews.first as? View)?.refresh()
    }
}
