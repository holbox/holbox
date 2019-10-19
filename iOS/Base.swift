import UIKit

final class Base: UIView {
    private weak var top: NSLayoutConstraint?
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
    }
    
    func show(_ view: UIView) {
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        if let previous = subviews.last {
            previous.layer.cornerRadius = 20
            view.layer.cornerRadius = 20
            view.backgroundColor = .background
            addSubview(view)
            
            view.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
            view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            let top = view.topAnchor.constraint(equalTo: topAnchor, constant: bounds.height)
            top.isActive = true
            let previousTop = self.top
            layoutIfNeeded()
            previous.backgroundColor = .black
            previousTop?.constant = 50
            top.constant = 100
            
            UIView.animate(withDuration: 0.6, animations: {
                self.layoutIfNeeded()
            }) { _ in
                top.constant = 0
                previousTop?.constant = 60
                
                UIView.animate(withDuration: 0.4, animations: {
                    self.layoutIfNeeded()
                }) { _ in
                    previous.removeFromSuperview()
                    view.layer.cornerRadius = 0
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
}
