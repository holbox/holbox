import UIKit

final class Alert: UIView {
    required init?(coder: NSCoder) { nil }
    init(_ title: String, message: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor(named: "background")!
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor(named: "haze")!.cgColor
        isAccessibilityElement = true
        accessibilityTraits = .staticText
        accessibilityViewIsModal = true
        accessibilityLabel = title + ": " + message
        
        let label = Label([(title + "\n", 14, .bold, .white), (message, 14, .light, .white)])
        label.isAccessibilityElement = false
        addSubview(label)
        
        bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 15).isActive = true
        
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -30).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in self?.close() }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with: UIEvent?) {
        close()
        super.touchesBegan(touches, with: with)
    }
    
    private func close() {
        UIView.animate(withDuration: 0.4, animations: { [weak self] in
            self?.alpha = 0
        }) { [weak self] _ in self?.removeFromSuperview() }
    }
}
