import UIKit

final class Grocery: UIView {
    let index: Int
    private(set) weak var emoji: Text!
    private(set) weak var grocery: Text!
    private weak var shopping: Shopping!
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int, shopping: Shopping) {
        self.index = index
        self.shopping = shopping
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = app.session.content(app.project, list: 1, card: index)

        let emoji = Text(.init())
        emoji.isScrollEnabled = false
        emoji.isUserInteractionEnabled = false
        emoji.accessibilityLabel = .key("Emoji")
        emoji.font = .regular(30)
        emoji.text = app.session.content(app.project, list: 0, card: index)
        addSubview(emoji)
        self.emoji = emoji

        let grocery = Text(Storage())
        grocery.isScrollEnabled = false
        grocery.isUserInteractionEnabled = false
        grocery.accessibilityLabel = .key("Grocery")
        grocery.textContainerInset = .init(top: 15, left: 10, bottom: 15, right: 10)
        grocery.font = .regular(14)
        (grocery.textStorage as! Storage).attributes = [.plain: [.font: UIFont.regular(14), .foregroundColor: UIColor.white],
                                                        .emoji: [.font: UIFont.regular(14)],
                                                        .bold: [.font: UIFont.medium(16), .foregroundColor: UIColor.white],
                                                        .tag: [.font: UIFont.medium(14), .foregroundColor: UIColor.haze()]]
        (grocery.layoutManager as! Layout).padding = 2
        grocery.text = app.session.content(app.project, list: 1, card: index)
        addSubview(grocery)
        self.grocery = grocery

        bottomAnchor.constraint(equalTo: grocery.bottomAnchor).isActive = true
        
        let height = heightAnchor.constraint(equalToConstant: 0)
        height.priority = .defaultLow
        height.isActive = true

        emoji.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        emoji.leftAnchor.constraint(equalTo: leftAnchor, constant: 25).isActive = true
        emoji.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        grocery.topAnchor.constraint(equalTo: topAnchor).isActive = true
        grocery.leftAnchor.constraint(equalTo: emoji.rightAnchor, constant: -15).isActive = true
        grocery.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        if app.session.content(app.project, list: 2, card: index) == "1" {
            emoji.alpha = 0.2
            grocery.alpha = 0.5
            
            let icon = Image("check", template: true)
            icon.tintColor = .haze()
            addSubview(icon)
            
            icon.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            icon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            icon.widthAnchor.constraint(equalToConstant: 30).isActive = true
            icon.heightAnchor.constraint(equalToConstant: 30).isActive = true
        }
        
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(gesture(_:))))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with: UIEvent?) {
        UIView.animate(withDuration: 0.35) { [weak self] in
            self?.backgroundColor = .haze(0.3)
        }
        super.touchesBegan(touches, with: with)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with: UIEvent?) {
        UIView.animate(withDuration: 0.35) { [weak self] in
            self?.backgroundColor = .clear
        }
        super.touchesCancelled(touches, with: with)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with: UIEvent?) {
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.backgroundColor = .clear
        }) { [weak self] _ in
            guard let self = self, app.project != nil else { return }
            if self.bounds.contains(touches.first!.location(in: self)) {
                self.shopping?.isUserInteractionEnabled = false
                if app.session.content(app.project, list: 2, card: self.index) == "1" {
                    app.alert(.key("Grocery.need"), message: app.session.content(app.project, list: 0, card: self.index) + " " + app.session.content(app.project, list: 1, card: self.index))
                    app.session.content(app.project, list: 2, card: self.index, content: "0")
                } else {
                    app.alert(.key("Grocery.got"), message: app.session.content(app.project, list: 0, card: self.index) + " " + app.session.content(app.project, list: 1, card: self.index))
                    app.session.content(app.project, list: 2, card: self.index, content: "1")
                }
                self.shopping?.refresh()
            }
        }
        super.touchesEnded(touches, with: with)
    }
    
    @objc private func gesture(_ gesture: UILongPressGestureRecognizer) {
//        if gesture.state == .began {
//            app.present(Stock.Edit(shopping, index: Int(app.session.content(app.project, list: 1, card: index))!), animated: true)
//        }
    }
}
