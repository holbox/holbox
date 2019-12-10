import UIKit

final class Product: UIView {
    let index: Int
    private(set) weak var text: Text!
    private weak var shopping: Shopping!
    private var active = true
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int, _ shopping: Shopping) {
        self.index = index
        self.shopping = shopping
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = .button
        layer.cornerRadius = 10

        active = !app.session.contains(app.project, reference: index)
        let product = app.session.product(app.project, index: index)
        accessibilityLabel = product.1
        
        let text = Text()
        text.isScrollEnabled = false
        text.isUserInteractionEnabled = false
        text.isAccessibilityElement = false
        text.textContainerInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        text.font = .systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 12), weight: .regular)
        if active {
            (text.textStorage as! Storage).fonts = [
                .plain: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 12), weight: .bold), .white),
                .emoji: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 18), weight: .regular), .white),
                .bold: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 14), weight: .bold), UIColor(named: "haze")!),
                .tag: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 12), weight: .bold), UIColor(named: "haze")!)]
        } else {
            (text.textStorage as! Storage).fonts = [
                .plain: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 12), weight: .bold), UIColor(named: "haze")!.withAlphaComponent(0.7)),
                .emoji: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 18), weight: .regular), UIColor(named: "haze")!.withAlphaComponent(0.7)),
                .bold: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 14), weight: .bold), UIColor(named: "haze")!.withAlphaComponent(0.5)),
                .tag: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 12), weight: .bold), UIColor(named: "haze")!.withAlphaComponent(0.5))]
        }
        text.textContainer.maximumNumberOfLines = 3
        text.text = product.0 + " " + product.1
        addSubview(text)
        self.text = text

        heightAnchor.constraint(equalToConstant: 100).isActive = true
        widthAnchor.constraint(equalToConstant: 110).isActive = true
        
        text.topAnchor.constraint(equalTo: topAnchor).isActive = true
        text.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        text.rightAnchor.constraint(equalTo: rightAnchor).isActive = true

        if active {
            let circle = UIView()
            circle.translatesAutoresizingMaskIntoConstraints = false
            circle.isUserInteractionEnabled = false
            circle.layer.cornerRadius = 11
            circle.backgroundColor = UIColor(named: "haze")!
            addSubview(circle)
            
            let icon = Image("check")
            addSubview(icon)
            
            circle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6).isActive = true
            circle.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            circle.widthAnchor.constraint(equalToConstant: 22).isActive = true
            circle.heightAnchor.constraint(equalToConstant: 22).isActive = true
            
            icon.widthAnchor.constraint(equalToConstant: 14).isActive = true
            icon.heightAnchor.constraint(equalToConstant: 14).isActive = true
            icon.centerXAnchor.constraint(equalTo: circle.centerXAnchor).isActive = true
            icon.centerYAnchor.constraint(equalTo: circle.centerYAnchor).isActive = true
        } else {
            alpha = 0.6
        }
        
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(gesture(_:))))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with: UIEvent?) {
        if active {
            UIView.animate(withDuration: 0.35) { [weak self] in
                self?.backgroundColor = UIColor(named: "haze")!.withAlphaComponent(0.3)
            }
        }
        super.touchesBegan(touches, with: with)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with: UIEvent?) {
        if active {
            UIView.animate(withDuration: 0.35) { [weak self] in
                self?.backgroundColor = .clear
            }
        }
        super.touchesCancelled(touches, with: with)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with: UIEvent?) {
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.backgroundColor = .clear
        }) { [weak self] _ in
            guard let self = self else { return }
            if self.active {
                if self.bounds.contains(touches.first!.location(in: self)) {
                    self.active = false
                    self.shopping?.isUserInteractionEnabled = false
                    let product = app.session.product(app.project, index: self.index)
                    app.alert(.key("Shopping.added"), message: product.0 + " " + product.1)
                    app.session.add(app.project, reference: self.index)
                    self.shopping?.refresh()
                    self.shopping?.groceryLast()
                }
            }
        }
        super.touchesEnded(touches, with: with)
    }
    
    @objc private func gesture(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            app.present(Stock.Edit(shopping, index: index), animated: true)
        }
    }
}
