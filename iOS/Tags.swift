import UIKit

final class Tags: UIView {
    private var animate = false
    private var tags = [(String, Int)]()
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let width = widthAnchor.constraint(equalToConstant: 0)
        width.priority = .defaultLow
        width.isActive = true
    }
    
    func refresh() {
        app.session.tags(app.project!, compare: tags, same: { [weak self] in
            self?.animate = true
        }) { [weak self] in
            guard let self = self else { return }
            self.tags = $0
            UIView.animate(withDuration: self.animate ? 0.3 : 0, animations: { [weak self] in
                self?.alpha = 0
            }) { [weak self] _ in
                self?.render()
            }
        }
    }
    
    private func render() {
        subviews.forEach { $0.removeFromSuperview() }
        if !tags.isEmpty {
            var top = topAnchor
            tags.forEach {
                let tag = Tag($0.0, count: $0.1)
                addSubview(tag)
                
                tag.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
                tag.topAnchor.constraint(equalTo: top).isActive = true
                top = tag.bottomAnchor
                rightAnchor.constraint(greaterThanOrEqualTo: tag.rightAnchor, constant: 20).isActive = true
            }
            bottomAnchor.constraint(greaterThanOrEqualTo: top).isActive = true
        }
        layoutIfNeeded()
        UIView.animate(withDuration: animate ? 0.35 : 0, animations: { [weak self] in
            self?.alpha = 1
            self?.superview!.layoutIfNeeded()
        }) { [weak self] _ in
            self?.animate = true
        }
    }
}
