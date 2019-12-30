import UIKit

final class Grocery: UIView, UITextViewDelegate {
    weak var top: NSLayoutConstraint! { didSet { top!.isActive = true } }
    weak var left: NSLayoutConstraint! { didSet { left!.isActive = true } }
    var index: Int
    private(set) weak var emoji: Text!
    private(set) weak var grocery: Text!
    private weak var icon: Image!
    private weak var shopping: Shopping!
    private var stock = false
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int, shopping: Shopping) {
        self.index = index
        self.shopping = shopping
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 6
        isAccessibilityElement = true
        accessibilityLabel = .key("Grocery")
        accessibilityTraits = .button
        stock = app.session.content(app.project, list: 2, card: index) == "1"
        
        let emoji = Text(.init())
        emoji.isScrollEnabled = false
        emoji.isUserInteractionEnabled = false
        emoji.isAccessibilityElement = false
        emoji.font = .regular(30)
        emoji.text = app.session.content(app.project, list: 0, card: index)
        emoji.textAlignment = .center
        addSubview(emoji)
        self.emoji = emoji

        let grocery = Text(Storage())
        grocery.isScrollEnabled = false
        grocery.isUserInteractionEnabled = false
        grocery.isAccessibilityElement = false
        grocery.textContainerInset = .init(top: 20, left: 15, bottom: 20, right: 15)
        grocery.font = .regular(14)
        (grocery.textStorage as! Storage).attributes = [.plain: [.font: UIFont.regular(14), .foregroundColor: UIColor.white],
                                                        .emoji: [.font: UIFont.regular(14)],
                                                        .bold: [.font: UIFont.medium(16), .foregroundColor: UIColor.white],
                                                        .tag: [.font: UIFont.medium(14), .foregroundColor: UIColor.haze()]]
        (grocery.layoutManager as! Layout).padding = 2
        grocery.text = app.session.content(app.project, list: 1, card: index)
        grocery.delegate = self
        addSubview(grocery)
        self.grocery = grocery
        
        let icon = Image("check", template: true)
        icon.tintColor = .haze()
        addSubview(icon)
        self.icon = icon
        
        bottomAnchor.constraint(equalTo: grocery.bottomAnchor).isActive = true
        rightAnchor.constraint(equalTo: grocery.rightAnchor).isActive = true
        
        icon.centerXAnchor.constraint(equalTo: emoji.centerXAnchor).isActive = true
        icon.centerYAnchor.constraint(equalTo: emoji.centerYAnchor).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 30).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        emoji.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        emoji.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        emoji.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        grocery.topAnchor.constraint(equalTo: topAnchor).isActive = true
        grocery.leftAnchor.constraint(equalTo: emoji.rightAnchor, constant: -5).isActive = true
        grocery.width = grocery.widthAnchor.constraint(equalToConstant: 105)
        grocery.height = grocery.heightAnchor.constraint(equalToConstant: 40)
        
        update()
        
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(gesture(_:))))
    }
    
    func textViewDidEndEditing(_: UITextView) {
        grocery.isUserInteractionEnabled = false
        if grocery.text != app.session.content(app.project, list: 1, card: index) {
            app.session.content(app.project, list: 1, card: index, content: grocery.text)
            shopping?.animate()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with: UIEvent?) {
        backgroundColor = .haze(0.2)
        super.touchesBegan(touches, with: with)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with: UIEvent?) {
        backgroundColor = .clear
        super.touchesCancelled(touches, with: with)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with: UIEvent?) {
        backgroundColor = .clear
        if bounds.contains(touches.first!.location(in: self)) && !grocery.isFirstResponder {
            if stock {
                app.alert(.key("Grocery.need"), message: app.session.content(app.project, list: 0, card: index) + " " + app.session.content(app.project, list: 1, card: index))
                app.session.content(app.project, list: 2, card: index, content: "0")
                stock = false
            } else {
                app.alert(.key("Grocery.got"), message: app.session.content(app.project, list: 0, card: index) + " " + app.session.content(app.project, list: 1, card: index))
                app.session.content(app.project, list: 2, card: index, content: "1")
                stock = true
            }
            shopping.stock.refresh()
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.update()
            }
        }
        super.touchesEnded(touches, with: with)
    }
    
    func edit() {
        grocery.isUserInteractionEnabled = true
        grocery.becomeFirstResponder()
        grocery.selectedRange = .init(location: 0, length: grocery.text.utf16.count)
    }
    
    private func update() {
        if stock {
            emoji.alpha = 0.1
            grocery.alpha = 0.4
            icon.isHidden = false
        } else {
            emoji.alpha = 1
            grocery.alpha = 1
            icon.isHidden = true
        }
    }
    
    @objc private func gesture(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            app.present(Edit(self), animated: true)
        }
    }
}
