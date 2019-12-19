import AppKit

final class Border: NSView {
    class func vertical(_ alpha: CGFloat = 0.4) -> Border {
        let border = Border(alpha)
        border.widthAnchor.constraint(equalToConstant: 1).isActive = true
        return border
    }
    
    class func horizontal(_ alpha: CGFloat = 0.4) -> Border {
        let border = Border(alpha)
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return border
    }
    
    required init?(coder: NSCoder) { nil }
    private init(_ alpha: CGFloat) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer!.backgroundColor = .haze(alpha)
    }
}
