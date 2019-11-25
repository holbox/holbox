import UIKit

class View: UIView {
    weak var top: NSLayoutConstraint! { didSet { top.isActive = true }  }
    
    required init?(coder: NSCoder) { nil }
    required init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func refresh() { }
    func found(_ ranges: [(Int, Int, NSRange)]) { }
    func select(_ list: Int, _ card: Int, _ range: NSRange) { }
}
