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

        let border = Border.horizontal(0.3)
        addSubview(border)

        let image = Image("shop.\(product.productIdentifier.components(separatedBy: ".").last!)")
        addSubview(image)

        let title = Label([
            (.key("Shop.short.\(product.productIdentifier.components(separatedBy: ".").last!)"), .medium(26), .haze()),
            (.key("Shop.title.\(product.productIdentifier.components(separatedBy: ".").last!)"), .regular(16), .haze())])
        addSubview(title)

        let label = Label(.key("Shop.descr.mac.\(product.productIdentifier.components(separatedBy: ".").last!)"), .light(12), .white)
        addSubview(label)

        shop.formatter.locale = product.priceLocale

        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        border.topAnchor.constraint(equalTo: topAnchor).isActive = true

        image.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 40).isActive = true
        image.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        image.widthAnchor.constraint(equalToConstant: 52).isActive = true
        image.heightAnchor.constraint(equalToConstant: 52).isActive = true

        title.topAnchor.constraint(equalTo: image.topAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: image.rightAnchor, constant: 10).isActive = true

        label.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 30).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 450).isActive = true

        if app.session.purchased(shop.map.first { $0.1 == product.productIdentifier }!.key) {
            let purchased = Label(.key("Shop.purchased"), .medium(14), .haze())
            addSubview(purchased)
            
            bottomAnchor.constraint(equalTo: purchased.bottomAnchor, constant: 20).isActive = true
            
            purchased.leftAnchor.constraint(equalTo: label.leftAnchor).isActive = true
            purchased.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 12).isActive = true
        } else {
            let price = Label(shop.formatter.string(from: product.price) ?? "", .regular(15), .white)
            addSubview(price)
            
            let control = Control(.key("Shop.purchase"), self, #selector(purchase), .haze(), .black)
            addSubview(control)
            
            bottomAnchor.constraint(equalTo: control.bottomAnchor, constant: 20).isActive = true
            
            price.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 30).isActive = true
            price.centerXAnchor.constraint(equalTo: label.centerXAnchor).isActive = true
            
            control.topAnchor.constraint(equalTo: price.bottomAnchor).isActive = true
            control.centerXAnchor.constraint(equalTo: label.centerXAnchor).isActive = true
            control.widthAnchor.constraint(equalToConstant: 110).isActive = true
        }
    }

    @objc private func purchase() {
        shop.purchase(product)
    }
}
