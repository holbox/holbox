import holbox
import UIKit
import StoreKit

final class Shop: Modal, SKRequestDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    private final class Item: UIView {
        private weak var shop: Shop!
        private let product: SKProduct

        required init?(coder: NSCoder) { nil }
        init(_ product: SKProduct, shop: Shop) {
            self.product = product
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            self.shop = shop

            let border = Border()
            addSubview(border)

            let image = Image("shop.\(product.productIdentifier.components(separatedBy: ".").last!)")
            addSubview(image)

            let title = Label([
                (.key("Shop.short.\(product.productIdentifier.components(separatedBy: ".").last!)"), 30, .bold, .init(white: 1, alpha: 0.9)),
                (.key("Shop.title.\(product.productIdentifier.components(separatedBy: ".").last!)"), 14, .regular, .init(white: 1, alpha: 0.9))])
            addSubview(title)

            let label = Label(.key("Shop.descr.mac.\(product.productIdentifier.components(separatedBy: ".").last!)"), 14, .light, .init(white: 1, alpha: 0.6))
            addSubview(label)

            shop.formatter.locale = product.priceLocale
            let price = Label(shop.formatter.string(from: product.price) ?? "", 16, .regular, .white)
            addSubview(price)

            let purchased = Label(.key("Shop.purchased"), 16, .medium, UIColor(named: "haze")!)
            addSubview(purchased)

            let control = Control(.key("Shop.purchase"), self, #selector(purchase), UIColor(named: "haze")!, .black)
            addSubview(control)

            bottomAnchor.constraint(equalTo: control.bottomAnchor, constant: 20).isActive = true

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
    
    private weak var request: SKProductsRequest?
    private weak var logo: Logo!
    private weak var image: Image!
    private weak var message: Label!
    private weak var scroll: Scroll!
    private weak var _restore: Control!
    private var products = [SKProduct]() { didSet { DispatchQueue.main.async { [weak self] in self?.refresh() } } }
    private let formatter = NumberFormatter()
    private let map = [Perk.two: "holbox.ios.two",
                       Perk.ten: "holbox.ios.ten",
                       Perk.hundred: "holbox.ios.hundred"]
    
    deinit { SKPaymentQueue.default().remove(self) }
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        formatter.numberStyle = .currencyISOCode
        
        let scroll = Scroll()
        view.addSubview(scroll)
        self.scroll = scroll
        
        let title = Label(.key("Shop.title"), 30, .bold, UIColor(named: "haze")!.withAlphaComponent(0.7))
        scroll.add(title)
        
        let logo = Logo()
        scroll.add(logo)
        self.logo = logo
        
        let image = Image("error")
        image.isHidden = true
        scroll.add(image)
        self.image = image
        
        let message = Label("", 16, .light, .init(white: 1, alpha: 0.8))
        message.isHidden = true
        scroll.add(message)
        self.message = message
        
        let _restore = Control(.key("Shop.restore"), self, #selector(restore), UIColor(named: "background")!, .white)
        _restore.isHidden = true
        scroll.add(_restore)
        self._restore = _restore
        
        scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1).isActive = true
        scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        scroll.width.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: logo.bottomAnchor, constant: 100).isActive = true
        
        title.leftAnchor.constraint(equalTo: scroll.left, constant: 20).isActive = true
        title.topAnchor.constraint(equalTo: scroll.top, constant: 50).isActive = true
        
        logo.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
        logo.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 80).isActive = true
        
        image.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20).isActive = true
        image.leftAnchor.constraint(equalTo: scroll.left, constant: 20).isActive = true
        image.widthAnchor.constraint(equalToConstant: 30).isActive = true
        image.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        message.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 20).isActive = true
        message.leftAnchor.constraint(equalTo: scroll.left, constant: 20).isActive = true
        message.rightAnchor.constraint(lessThanOrEqualTo: scroll.right, constant: -20).isActive = true
        
        _restore.centerYAnchor.constraint(equalTo: title.centerYAnchor).isActive = true
        _restore.rightAnchor.constraint(equalTo: scroll.right, constant: -20).isActive = true
        _restore.widthAnchor.constraint(equalToConstant: 90).isActive = true
        
        loading()
        SKPaymentQueue.default().add(self)

        let request = SKProductsRequest(productIdentifiers: .init(map.values))
        request.delegate = self
        self.request = request
        request.start()
    }
    
    func productsRequest(_: SKProductsRequest, didReceive: SKProductsResponse) { products = didReceive.products }
    func paymentQueue(_: SKPaymentQueue, updatedTransactions: [SKPaymentTransaction]) { update(updatedTransactions) }
    func paymentQueue(_: SKPaymentQueue, removedTransactions: [SKPaymentTransaction]) { update(removedTransactions) }
    func paymentQueueRestoreCompletedTransactionsFinished(_: SKPaymentQueue) { DispatchQueue.main.async { [weak self] in self?.refresh() } }
    func request(_: SKRequest, didFailWithError: Error) { DispatchQueue.main.async { [weak self] in self?.error(didFailWithError.localizedDescription) } }
    func paymentQueue(_: SKPaymentQueue, restoreCompletedTransactionsFailedWithError: Error) { DispatchQueue.main.async { [weak self] in self?.error(restoreCompletedTransactionsFailedWithError.localizedDescription) } }
    
    private func update(_ transactions: [SKPaymentTransaction]) {
        guard transactions.first(where: { $0.transactionState == .purchasing }) == nil else { return }
        transactions.forEach { transaction in
            switch transaction.transactionState {
            case .failed: SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                app.session.purchase(map.first { $0.1 == transaction.payment.productIdentifier }!.key)
            case .purchased:
                app.session.purchase(map.first { $0.1 == transaction.payment.productIdentifier }!.key)
                SKPaymentQueue.default().finishTransaction(transaction)
            default: break
            }
        }
        if !products.isEmpty {
            DispatchQueue.main.async { [weak self] in self?.refresh() }
        }
    }
    
    private func refresh() {
        view.isUserInteractionEnabled = false
        image.isHidden = true
        _restore.isHidden = false
        message.isHidden = true
        message.text = ""
        logo.stop()
        scroll.views.filter { $0 is Item }.forEach { $0.removeFromSuperview() }
        var top: NSLayoutYAxisAnchor?
        products.sorted { left, right in
            map.first { $0.1 == left.productIdentifier }!.key.rawValue < map.first { $0.1 == right.productIdentifier }!.key.rawValue
        }.forEach {
            let item = Item($0, shop: self)
            scroll.add(item)
            
            if top == nil {
                item.topAnchor.constraint(equalTo: scroll.top, constant: 100).isActive = true
            } else {
                item.topAnchor.constraint(equalTo: top!).isActive = true
            }
            
            item.leftAnchor.constraint(equalTo: scroll.left, constant: 20).isActive = true
            item.rightAnchor.constraint(equalTo: scroll.right, constant: -20).isActive = true
            top = item.bottomAnchor
        }
        if top != nil {
            scroll.bottom.constraint(equalTo: top!, constant: 10).isActive = true
        }
        view.isUserInteractionEnabled = true
    }
    
    private func loading() {
        logo.start()
        scroll.views.filter { $0 is Item }.forEach { $0.removeFromSuperview() }
        _restore.isHidden = true
        image.isHidden = true
        message.isHidden = true
        message.text = ""
    }
    
    private func error(_ error: String) {
        app.alert(.key("Error"), message: error)
        logo.stop()
        scroll.views.filter { $0 is Item }.forEach { $0.removeFromSuperview() }
        _restore.isHidden = true
        image.isHidden = false
        message.isHidden = false
        message.text = error
    }
    
    private func purchase(_ product: SKProduct) {
        loading()
        SKPaymentQueue.default().add(.init(product: product))
    }
    
    @objc private func restore() {
        SKPaymentQueue.default().restoreCompletedTransactions()
        loading()
    }
}
