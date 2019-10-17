import UIKit

final class Main: UIView {
    private weak var logo: Logo?
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        
        let logo = Logo()
        logo.start()
        addSubview(logo)
        self.logo = logo
        
        logo.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        logo.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        loaded()
    }
    
    func loaded() {
        logo!.stop()
        logo!.removeFromSuperview()
    }
}
