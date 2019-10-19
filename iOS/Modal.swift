import UIKit

class Modal: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        let background = UIView()
        background.isUserInteractionEnabled = false
        background.translatesAutoresizingMaskIntoConstraints = false
        background.backgroundColor = UIColor.haze.withAlphaComponent(0.2)
        view.addSubview(background)
        
        background.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        background.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        background.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        background.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    @objc final func close() {
        presentingViewController!.dismiss(animated: true)
    }
}
