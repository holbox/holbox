import UIKit

final class Main: UIView {
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        
        let logo = Logo()
        logo.start()
        addSubview(logo)
        
        logo.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        logo.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
