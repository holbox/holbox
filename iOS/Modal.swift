import UIKit

class Modal: UIViewController {
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gradient = Gradient()
        view.addSubview(gradient)
        
        gradient.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        gradient.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        gradient.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        gradient.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    @objc final func close() {
        app.window!.endEditing(true)
        presentingViewController!.dismiss(animated: true)
    }
}
