import UIKit

final class Bars: Chart {
    private weak var right: NSLayoutConstraint! {
        didSet {
            oldValue?.isActive = false
            right.isActive = true
        }
    }
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        heightAnchor.constraint(equalToConstant: 160).isActive = true
    }
    
    func refresh() {
        let cards = (0 ..< app.session.lists(app.project)).map { CGFloat(app.session.cards(app.project, list: $0)) }
        let top = cards.max() ?? 1
        
        if subviews.count > cards.count {
            (cards.count ..< subviews.count).forEach {
                subviews[$0].removeFromSuperview()
            }
            if let last = subviews.last {
                right = rightAnchor.constraint(equalTo: last.rightAnchor, constant: 5)
            }
        } else {
            (subviews.count ..< cards.count).forEach {
                let line = Line()
                addSubview(line)
                
                line.topAnchor.constraint(equalTo: topAnchor).isActive = true
                line.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
                line.leftAnchor.constraint(equalTo: $0 == 0 ? leftAnchor : subviews[$0 - 1].rightAnchor, constant: 5).isActive = true
                
                if $0 == cards.count - 1 {
                    right = rightAnchor.constraint(equalTo: line.rightAnchor, constant: 5)
                }
            }
        }
        
        layoutIfNeeded()

        (subviews as! [Line]).enumerated().forEach {
            let amount = max(cards[$0.0] / max(top, 1), 0.02)
            $0.1.line.layer.cornerRadius = amount <= 0.2 ? 0 : 6
            $0.1.shape.constant = amount * 80
            $0.1.label.attributed([("\(Int(cards[$0.0]))\n", 18, .bold, UIColor(named: "haze")!),
                                   (app.session.name(app.project, list: $0.0), 11, .regular, UIColor(named: "haze")!)],
                                  align: .center)
        }
        
        UIView.animate(withDuration: 1.5) { [weak self] in
            self?.layoutIfNeeded()
        }
    }
}

private final class Line: UIView {
    private(set) weak var shape: NSLayoutConstraint!
    private(set) weak var line: UIView!
    private(set) weak var label: Label!
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = UIColor(named: "haze")!
        addSubview(line)
        self.line = line
        
        let label = Label([])
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.numberOfLines = 4
        addSubview(label)
        self.label = label
        
        line.widthAnchor.constraint(equalToConstant: 12).isActive = true
        line.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        line.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -68).isActive = true
        shape = line.heightAnchor.constraint(equalToConstant: 0)
        shape.isActive = true
        
        rightAnchor.constraint(equalTo: label.rightAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        label.topAnchor.constraint(equalTo: bottomAnchor, constant: -60).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 50).isActive = true
    }
}
