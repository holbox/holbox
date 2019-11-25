import UIKit

class Edit: UIViewController, UITextViewDelegate {
    private(set) weak var text: Text!
    private(set) weak var done: Capsule!
    private weak var bottom: NSLayoutConstraint!
    private weak var _bold: Button!
    
    required init?(coder: NSCoder) { nil }
    init() { super.init(nibName: nil, bundle: nil) }
    deinit { NotificationCenter.default.removeObserver(self) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.layer.borderColor = UIColor(named: "haze")!.cgColor
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 20
        
        let text = Text()
        text.delegate = self
        view.addSubview(text)
        self.text = text
        
        let border = Border()
        border.backgroundColor = UIColor(named: "background")!
        view.addSubview(border)
        
        let done = Capsule(.key("Card.done"), self, #selector(close), UIColor(named: "haze")!, .black)
        view.addSubview(done)
        self.done = done
        
        let _bold = Button("hash", target: self, action: #selector(bold))
        _bold.alpha = 0
        view.addSubview(_bold)
        self._bold = _bold
        
        text.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1).isActive = true
        text.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        text.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        text.bottomAnchor.constraint(equalTo: border.topAnchor).isActive = true
        
        border.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        bottom = border.bottomAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70)
        bottom.isActive = true
        
        done.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 5).isActive = true
        done.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -15).isActive = true
        
        _bold.centerYAnchor.constraint(equalTo: done.centerYAnchor).isActive = true
        _bold.rightAnchor.constraint(equalTo: done.leftAnchor).isActive = true
        _bold.widthAnchor.constraint(equalToConstant: 100).isActive = true
        _bold.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(show(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        text.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(_: UITextView) { }
    
    override func willTransition(to: UITraitCollection, with: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: to, with: with)
//        app.win.endEditing(true)
    }
    
    @objc final func close() {
//        app.win.endEditing(true)
        presentingViewController!.dismiss(animated: true)
    }
    
    @objc private func bold() {
        text.insertText("#")
    }

    @objc private func show(_ notification: NSNotification) {
        preferredContentSize.height = 200
        bottom.constant = -((notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height + 70 - view.safeAreaInsets.bottom)
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.view.layoutIfNeeded()
            self?._bold.alpha = 1
        }
    }

    @objc private func hide() {
        bottom.constant = -70
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.view.layoutIfNeeded()
            self?._bold.alpha = 0
        }
    }
}
