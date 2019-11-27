import UIKit
import StoreKit

final class Purchase: UIView {
    private weak var shop: Shop!
    private let product: SKProduct

    required init?(coder: NSCoder) { nil }
    init(_ product: SKProduct, shop: Shop) {
        self.product = product
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.shop = shop

        let border = Border()
        border.alpha = 0.3
        addSubview(border)

        let image = Image("shop.\(product.productIdentifier.components(separatedBy: ".").last!)")
        addSubview(image)

        let title = Label([
            (.key("Shop.short.\(product.productIdentifier.components(separatedBy: ".").last!)"), 30, .bold, UIColor(named: "haze")!),
            (.key("Shop.title.\(product.productIdentifier.components(separatedBy: ".").last!)"), 14, .regular, UIColor(named: "haze")!.withAlphaComponent(0.9))])
        addSubview(title)

        let label = Label(.key("Shop.descr.mac.\(product.productIdentifier.components(separatedBy: ".").last!)"), 14, .light, UIColor(named: "haze")!.withAlphaComponent(0.9))
        addSubview(label)

        shop.formatter.locale = product.priceLocale
        let price = Label(shop.formatter.string(from: product.price) ?? "", 16, .regular, .white)
        addSubview(price)

        let purchased = Label(.key("Shop.purchased"), 18, .bold, UIColor(named: "haze")!)
        addSubview(purchased)

        let control = Control(.key("Shop.purchase"), self, #selector(purchase), UIColor(named: "haze")!, .black)
        addSubview(control)

        bottomAnchor.constraint(equalTo: control.bottomAnchor, constant: 10).isActive = true

        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        border.topAnchor.constraint(equalTo: topAnchor).isActive = true

        image.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 20).isActive = true
        image.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        image.widthAnchor.constraint(equalToConstant: 80).isActive = true
        image.heightAnchor.constraint(equalToConstant: 80).isActive = true

        title.bottomAnchor.constraint(equalTo: image.bottomAnchor, constant: -10).isActive = true
        title.leftAnchor.constraint(equalTo: image.rightAnchor, constant: 10).isActive = true
        title.rightAnchor.constraint(lessThanOrEqualTo: label.rightAnchor).isActive = true

        label.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 20).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 450).isActive = true

        price.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 30).isActive = true
        price.centerXAnchor.constraint(equalTo: label.centerXAnchor).isActive = true

        purchased.centerXAnchor.constraint(equalTo: label.centerXAnchor).isActive = true
        purchased.topAnchor.constraint(equalTo: price.bottomAnchor, constant: 5).isActive = true

        control.topAnchor.constraint(equalTo: price.bottomAnchor).isActive = true
        control.centerXAnchor.constraint(equalTo: label.centerXAnchor).isActive = true
        control.widthAnchor.constraint(equalToConstant: 130).isActive = true

        if app.session.purchased(shop.map.first { $0.1 == product.productIdentifier }!.key) {
            control.isHidden = true
        } else {
            purchased.isHidden = true
        }
    }

    @objc private func purchase() {
        shop.purchase(product)
    }
}
