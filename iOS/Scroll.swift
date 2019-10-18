import UIKit

final class Scroll: UIScrollView {
    var views: [UIView] { content.subviews }
    var top: NSLayoutYAxisAnchor { content.topAnchor }
    var bottom: NSLayoutYAxisAnchor { content.bottomAnchor }
    var left: NSLayoutXAxisAnchor { content.leftAnchor }
    var right: NSLayoutXAxisAnchor { content.rightAnchor }
    var centerX: NSLayoutXAxisAnchor { content.centerXAnchor }
    private(set) weak var content: UIView!
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        indicatorStyle = .white
        keyboardDismissMode = .interactive
        clipsToBounds = true
        
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        content.clipsToBounds = true
        addSubview(content)
        self.content = content
        
        content.topAnchor.constraint(equalTo: topAnchor).isActive = true
        content.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        content.widthAnchor.constraint(greaterThanOrEqualTo: widthAnchor).isActive = true
        content.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor).isActive = true
    }
    
    func add(_ view: UIView) { content.addSubview(view) }
}