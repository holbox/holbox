import UIKit

class Delete: UIViewController {
    final class Project: Delete {
        private let index: Int
        
        required init?(coder: NSCoder) { nil }
        init(_ index: Int) {
            self.index = index
            super.init()
        }
    }
    
    required init?(coder: NSCoder) { nil }
    private init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let base = UIView()
        base.backgroundColor = .black
        base.translatesAutoresizingMaskIntoConstraints = false
        base.layer.cornerRadius = 8
        view.addSubview(base)
        
        base.widthAnchor.constraint(equalToConstant: 300).isActive = true
        base.heightAnchor.constraint(equalToConstant: 200).isActive = true
        base.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        base.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    @objc private final func close() {
//        app.win.endEditing(true)
//        presentingViewController!.dismiss(animated: true)
    }
}
