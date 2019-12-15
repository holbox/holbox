import AppKit

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
        
        let width = widthAnchor.constraint(equalToConstant: 0)
        width.priority = .defaultLow
        width.isActive = true
    }
    
    func refresh() {
        let cards = (0 ..< app.session.lists(app.project)).map { CGFloat(app.session.cards(app.project, list: $0)) }
        let top = cards.max() ?? 1
        
        if subviews.count > cards.count {
            (cards.count ..< subviews.count).forEach {
                subviews[$0].removeFromSuperview()
            }
            if let last = subviews.last {
                right = rightAnchor.constraint(equalTo: last.rightAnchor)
            }
        } else {
            (subviews.count ..< cards.count).forEach {
                let line = Line()
                addSubview(line)
                
                line.topAnchor.constraint(equalTo: topAnchor).isActive = true
                line.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
                line.leftAnchor.constraint(equalTo: $0 == 0 ? leftAnchor : subviews[$0 - 1].rightAnchor).isActive = true
                
                if $0 == cards.count - 1 {
                    right = rightAnchor.constraint(equalTo: line.rightAnchor)
                }
            }
        }
        
        layoutSubtreeIfNeeded()

        (subviews as! [Line]).enumerated().forEach {
            $0.1.line.layer!.cornerRadius = cards[$0.0] == 0 ? 0 : 6
            $0.1.shape.constant = cards[$0.0] == 0 ? 3 : max((cards[$0.0] / max(top, 1)) * 80, 12)
            $0.1.label.attributed([("\(Int(cards[$0.0]))\n", 12, .bold, NSColor(named: "haze")!),
                                   (app.session.name(app.project, list: $0.0), 8, .regular, NSColor(named: "haze")!)],
                                  align: .center)
        }
        
        NSAnimationContext.runAnimationGroup {
            $0.duration = 1.5
            $0.allowsImplicitAnimation = true
            layoutSubtreeIfNeeded()
        }
    }
}

private final class Line: NSView {
    private(set) weak var shape: NSLayoutConstraint!
    private(set) weak var line: NSView!
    private(set) weak var label: Label!
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        wantsLayer = true
        translatesAutoresizingMaskIntoConstraints = false
        
        let line = NSView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.wantsLayer = true
        line.layer!.backgroundColor = NSColor(named: "haze")!.cgColor
        addSubview(line)
        self.line = line
        
        let label = Label([])
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.maximumNumberOfLines = 3
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
