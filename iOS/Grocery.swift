import UIKit

final class Grocery: UIView {
    let index: Int
    private(set) weak var text: Text!
    private weak var shopping: Shopping!
    private weak var emoji: Label!
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int, _ shopping: Shopping) {
        self.index = index
        self.shopping = shopping
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = .button
        
        let product = app.session.reference(app.project, index: index)
        accessibilityLabel = product.1

        let emoji = Label(product.0, 35, .regular, .white)
        emoji.isAccessibilityElement = false
        addSubview(emoji)
        self.emoji = emoji

        let text = Text()
        text.isScrollEnabled = false
        text.isUserInteractionEnabled = false
        text.isAccessibilityElement = false
        text.textContainerInset = .init(top: 15, left: 10, bottom: 15, right: 20)
        text.font = .systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 14), weight: .regular)
        (text.textStorage as! Storage).fonts = [
            .plain: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 14), weight: .bold), .white),
            .emoji: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 14), weight: .regular), .white),
            .bold: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 16), weight: .bold), UIColor(named: "haze")!),
            .tag: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 14), weight: .bold), UIColor(named: "haze")!)]
        text.text = product.1
        addSubview(text)
        self.text = text

        bottomAnchor.constraint(greaterThanOrEqualTo: text.bottomAnchor).isActive = true
        heightAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
        
        let height = heightAnchor.constraint(equalToConstant: 0)
        height.priority = .defaultLow
        height.isActive = true

        emoji.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        emoji.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        emoji.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        text.topAnchor.constraint(equalTo: topAnchor).isActive = true
        text.leftAnchor.constraint(equalTo: emoji.rightAnchor, constant: -15).isActive = true
        text.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(gesture(_:))))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with: UIEvent?) {
        UIView.animate(withDuration: 0.35) { [weak self] in
            self?.backgroundColor = UIColor(named: "haze")!.withAlphaComponent(0.3)
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
            guard let self = self else { return }
            if self.bounds.contains(touches.first!.location(in: self)) {
                self.shopping?.isUserInteractionEnabled = false
                let product = app.session.reference(app.project, index: self.index)
                app.alert(.key("Shopping.got"), message: product.0 + " " + product.1)
                app.session.delete(app.project, list: 1, card: self.index)
                self.shopping?.refresh()
            }
        }
        super.touchesEnded(touches, with: with)
    }
    
    @objc private func gesture(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            app.present(Stock.Edit(shopping, index: Int(app.session.content(app.project, list: 1, card: index))!), animated: true)
        }
    }
}
