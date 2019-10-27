import UIKit

class Modal: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "background")!
    }
    
    @objc final func close() {
        app.win.endEditing(true)
        presentingViewController!.dismiss(animated: true)
    }
}
