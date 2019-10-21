import UIKit

final class Card: UIView {
    private final class Edit: Modal, UITextViewDelegate {
        private weak var card: Card!
        private weak var text: Text!
        private weak var bottom: NSLayoutConstraint!
        
        deinit { NotificationCenter.default.removeObserver(self) }
        required init?(coder: NSCoder) { return nil }
        init(_ card: Card) {
            super.init(nibName: nil, bundle: nil)
            self.card = card
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            let text = Text()
            text.font = .monospacedSystemFont(ofSize: 20, weight: .regular)
            text.text = card.content.text!
            text.delegate = self
            view.addSubview(text)
            self.text = text
            
            let border = Border()
            view.addSubview(border)
            
            let done = Capsule(.key("Card.done"), self, #selector(close), .haze, .black)
            view.addSubview(done)
            
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
        
        override func viewDidDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            card.update(false)
        }
        
        func textViewDidEndEditing(_: UITextView) {
            card.update(text.text)
        }
        
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
    
    let index: Int
    let column: Int
    private weak var content: UILabel!
    private weak var base: UIView!

    required init?(coder: NSCoder) { nil }
    init(_ index: Int, column: Int) {
        self.index = index
        self.column = column
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let base = UIView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.isUserInteractionEnabled = false
        base.layer.cornerRadius = 8
        base.layer.borderColor = .black
        addSubview(base)
        self.base = base
        
        let content = Label(app.session.content(app.project, list: column, card: index), 14, .light, .white)
        content.font = .monospacedSystemFont(ofSize: 14, weight: .light)
        content.accessibilityLabel = .key("Card")
        content.accessibilityValue = app.session.content(app.project, list: column, card: index)
        addSubview(content)
        self.content = content
        
        rightAnchor.constraint(equalTo: content.rightAnchor, constant: 30).isActive = true
        bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: 30).isActive = true
        
        base.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        base.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        base.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        base.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        
        content.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
        content.topAnchor.constraint(equalTo: topAnchor, constant: 30).isActive = true
        content.widthAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        
        update(false)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with: UIEvent?) {
        update(true)
        super.touchesBegan(touches, with: with)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with: UIEvent?) {
        update(false)
        super.touchesCancelled(touches, with: with)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with: UIEvent?) {
        if app.presentedViewController == nil && bounds.contains(touches.first!.location(in: self)) {
            app.present(Edit(self), animated: true)
        } else {
            update(false)
        }
        super.touchesEnded(touches, with: with)
    }
    
    func edit() {
        UIView.animate(withDuration: 0.35, animations: { [weak self] in
            self?.update(true)
        }) { [weak self] _ in
            guard let self = self else { return }
            app.present(Edit(self), animated: true)
        }
    }
    
    private func update(_ text: String) {
        content.text = text
        app.session.content(app.project, list: column, card: index, content: text)
    }
    
    private func update(_ active: Bool) {
        base.layer.borderWidth = content.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 1 : 0
        base.backgroundColor = active ? .haze : .clear
        content.textColor = active ? .black : .white
        content.alpha = active ? 1 : 0.8
    }
}
