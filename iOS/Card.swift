import UIKit

final class Card: UIView {
    weak var child: Card?
    weak var top: NSLayoutConstraint! { willSet { top?.isActive = false } didSet { top.isActive = true } }
    weak var left: NSLayoutConstraint! { didSet { left.isActive = true } }
    weak var right: NSLayoutConstraint! { didSet { right.isActive = true } }
    let index: Int
    let column: Int
    private weak var content: UILabel!
    private var dragging = false
    private var deltaX = CGFloat(0)
    private var deltaY = CGFloat(0)

    required init?(coder: NSCoder) { nil }
    init(_ index: Int, column: Int) {
        self.index = index
        self.column = column
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = .black
        
        let content = UILabel()
        content.translatesAutoresizingMaskIntoConstraints = false
        content.font = .monospacedSystemFont(ofSize: 16, weight: .regular)
        content.text = app.session.content(app.project, list: column, card: index)
        content.isAccessibilityElement = true
        content.accessibilityTraits = .staticText
        content.accessibilityLabel = .key("Card")
        content.accessibilityValue = app.session.content(app.project, list: column, card: index)
        content.numberOfLines = 0
        content.alpha = 0.8
        addSubview(content)
        self.content = content
        
        rightAnchor.constraint(equalTo: content.rightAnchor, constant: 10).isActive = true
        bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: 10).isActive = true
        
        content.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        content.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
    }
    
    func drag(_ x: CGFloat, _ y: CGFloat) {
        if dragging {
            top.constant += y
            left.constant += x
        } else {
            deltaX += x
            deltaY += y
            if abs(deltaX) + abs(deltaY) > 15 {
                dragging = true
                right.isActive = false
                top.constant += deltaY
                left.constant += deltaX
                backgroundColor = UIColor.haze.withAlphaComponent(0.95)
                content.textColor = .black
                
                superview!.bringSubviewToFront(self)
                
                if let child = self.child {
                    child.top = child.topAnchor.constraint(equalTo: top.secondAnchor as! NSLayoutAnchor<NSLayoutYAxisAnchor>, constant: 20)
                    self.child = nil
                    UIView.animate(withDuration: 1) { [weak self] in
                        self?.superview?.layoutIfNeeded()
                    }
                }
            }
        }
    }
    
    func stop(_ x: CGFloat, _ y: CGFloat) {
        if dragging {
            let destination = max(superview!.subviews.compactMap { $0 as? Column }.filter { $0.frame.minX < x }.count - 1, 0)
            app.session.move(app.project, list: column, card: index, destination: destination, index:
                superview!.subviews.compactMap { $0 as? Card }.filter { $0.column == destination && $0 !== self }.filter { $0.frame.minY < y }.count)
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.backgroundColor = .clear
                self?.content.textColor = .white
            }) { _ in app.main.project(app.project) }
        }
        dragging = false
        deltaX = 0
        deltaY = 0
    }
    /*
    override func mouseEntered(with: NSEvent) {
        super.mouseEntered(with: with)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            _delete.alphaValue = 1
        }
    }
    
    override func mouseExited(with: NSEvent) {
        super.mouseExited(with: with)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            _delete.alphaValue = 0
        }
    }*/
}
