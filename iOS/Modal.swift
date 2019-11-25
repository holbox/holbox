import UIKit

class Modal: UIViewController {
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "background")!
    }
    
    @objc final func close() {
//        app.win.endEditing(true)
//        presentingViewController!.dismiss(animated: true)
    }
}
