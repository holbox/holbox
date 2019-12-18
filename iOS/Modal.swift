import UIKit

class Modal: UIViewController {
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
    }
    
    final func addClose() {
        let _close = Button("clear", target: self, action: #selector(close))
        view.addSubview(_close)
        
        _close.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        _close.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        _close.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _close.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    @objc final func close() {
        app.window!.endEditing(true)
        presentingViewController!.dismiss(animated: true)
    }
}
