import UIKit

class Edit: Modal, UITextViewDelegate {
    private(set) weak var text: Text!
    private(set) weak var done: Capsule!
    private weak var bottom: NSLayoutConstraint!
    
    deinit { NotificationCenter.default.removeObserver(self) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let text = Text()
        text.font = .monospacedSystemFont(ofSize: 20, weight: .regular)
        text.delegate = self
        view.addSubview(text)
        self.text = text
        
        let border = Border()
        view.addSubview(border)
        
        let done = Capsule(.key("Card.done"), self, #selector(close), .haze, .black)
        view.addSubview(done)
        self.done = done
        
        text.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1).isActive = true
        text.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        text.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        text.bottomAnchor.constraint(equalTo: border.topAnchor).isActive = true
        
        border.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        bottom = border.bottomAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60)
        bottom.isActive = true
        
        done.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
        done.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        done.widthAnchor.constraint(equalToConstant: 70).isActive = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(show(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        text.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(_: UITextView) { }
    
    override func willTransition(to: UITraitCollection, with: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: to, with: with)
        app.win.endEditing(true)
    }

    @objc private func show(_ notification: NSNotification) {
        bottom.constant = -((notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height + 60 - view.safeAreaInsets.bottom)
        UIView.animate(withDuration: 0.5) { [weak self] in self?.view.layoutIfNeeded() }
    }

    @objc private func hide() {
        bottom.constant = -60
        UIView.animate(withDuration: 0.5) { [weak self] in self?.view.layoutIfNeeded() }
    }
}
