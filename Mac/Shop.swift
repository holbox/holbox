import holbox
import AppKit
import StoreKit

final class Shop: NSView, SKRequestDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    private final class Item: NSView {
        private weak var shop: Shop!
        private let product: SKProduct
        
        required init?(coder: NSCoder) { nil }
        init(_ product: SKProduct, bordered: Bool, shop: Shop) {
            self.product = product
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            self.shop = shop
            
            let border = NSView()
            border.translatesAutoresizingMaskIntoConstraints = false
            border.wantsLayer = true
            border.layer!.backgroundColor = bordered ? .black : .clear
            addSubview(border)
            
            let image = Image("shop.\(product.productIdentifier.components(separatedBy: ".").last!)")
            addSubview(image)
            
            let label = Label()
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            label.attributedStringValue = {
                $0.append(.init(string: .key("Shop.title.\(product.productIdentifier.components(separatedBy: ".").last!)"), attributes: [.font: NSFont.systemFont(ofSize: 20, weight: .medium), .foregroundColor: NSColor(white: 1, alpha: 0.8)]))
                $0.append(.init(string: .key("Shop.descr.\(product.productIdentifier.components(separatedBy: ".").last!)"), attributes: [.font: NSFont.systemFont(ofSize: 16, weight: .regular), .foregroundColor: NSColor(white: 1, alpha: 0.6)]))
                return $0
            } (NSMutableAttributedString())
            addSubview(label)
            
            shop.formatter.locale = product.priceLocale
            let price = Label(shop.formatter.string(from: product.price) ?? "")
            price.textColor = .white
            price.font = .systemFont(ofSize: 18, weight: .bold)
            addSubview(price)
            
            let purchased = Label(.key("Shop.purchased"))
            purchased.textColor = .haze
            purchased.font = .systemFont(ofSize: 20, weight: .bold)
            addSubview(purchased)
            
            let control = Control(.key("Shop.purchase"), target: self, action: #selector(purchase))
            control.layer!.backgroundColor = .haze
            control.label.textColor = .black
            addSubview(control)
            
            bottomAnchor.constraint(equalTo: control.bottomAnchor, constant: 40).isActive = true
            
            border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            border.heightAnchor.constraint(equalToConstant: 1).isActive = true
            border.topAnchor.constraint(equalTo: topAnchor).isActive = true
            
            image.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 20).isActive = true
            image.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            image.widthAnchor.constraint(equalToConstant: 80).isActive = true
            image.heightAnchor.constraint(equalToConstant: 80).isActive = true
            
            label.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 20).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor).isActive = true
            
            price.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 40).isActive = true
            price.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            
            purchased.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            purchased.topAnchor.constraint(equalTo: price.bottomAnchor, constant: 5).isActive = true
            
            control.topAnchor.constraint(equalTo: price.bottomAnchor, constant: 10).isActive = true
            control.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            control.widthAnchor.constraint(equalToConstant: 110).isActive = true
            
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
    private let map = [Perk.two: "holbox.mac.two",
                       Perk.ten: "holbox.mac.ten",
                       Perk.hundred: "holbox.mac.hundred"]
    
    deinit { SKPaymentQueue.default().remove(self) }
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        formatter.numberStyle = .currencyISOCode
        
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let title = Label(.key("Shop.title"))
        title.font = .systemFont(ofSize: 30, weight: .bold)
        title.textColor = .init(white: 1, alpha: 0.3)
        scroll.documentView!.addSubview(title)
        
        let border = NSView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.wantsLayer = true
        border.layer!.backgroundColor = .black
        scroll.documentView!.addSubview(border)
        
        let logo = Logo()
        scroll.documentView!.addSubview(logo)
        self.logo = logo
        
        let image = Image("error")
        image.isHidden = true
        scroll.documentView!.addSubview(image)
        self.image = image
        
        let message = Label()
        message.textColor = .init(white: 1, alpha: 0.7)
        message.font = .systemFont(ofSize: 16, weight: .light)
        message.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        message.isHidden = true
        scroll.documentView!.addSubview(message)
        self.message = message
        
        let _restore = Control(.key("Shop.restore"), target: self, action: #selector(restore))
        _restore.isHidden = true
        _restore.layer!.backgroundColor = .black
        _restore.label.textColor = .haze
        scroll.documentView!.addSubview(_restore)
        self._restore = _restore
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.documentView!.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: logo.bottomAnchor, constant: 100).isActive = true
        
        title.leftAnchor.constraint(equalTo: scroll.leftAnchor, constant: 70).isActive = true
        title.topAnchor.constraint(equalTo: scroll.documentView!.topAnchor, constant: 50).isActive = true
        
        border.leftAnchor.constraint(equalTo: scroll.documentView!.leftAnchor, constant: 70).isActive = true
        border.rightAnchor.constraint(equalTo: scroll.documentView!.rightAnchor, constant: -70).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20).isActive = true
        
        logo.centerXAnchor.constraint(equalTo: scroll.documentView!.centerXAnchor).isActive = true
        logo.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 100).isActive = true
        
        image.topAnchor.constraint(equalTo: border.topAnchor, constant: 20).isActive = true
        image.leftAnchor.constraint(equalTo: border.leftAnchor).isActive = true
        image.widthAnchor.constraint(equalToConstant: 30).isActive = true
        image.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        message.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 20).isActive = true
        message.leftAnchor.constraint(equalTo: border.leftAnchor).isActive = true
        message.rightAnchor.constraint(lessThanOrEqualTo: border.rightAnchor).isActive = true
        
        _restore.bottomAnchor.constraint(equalTo: border.topAnchor, constant: -15).isActive = true
        _restore.rightAnchor.constraint(equalTo: border.rightAnchor).isActive = true
        _restore.widthAnchor.constraint(equalToConstant: 160).isActive = true
        
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
        image.isHidden = true
        _restore.isHidden = false
        message.isHidden = true
        message.stringValue = ""
        logo.stop()
        scroll.documentView!.subviews.filter { $0 is Item }.forEach { $0.removeFromSuperview() }
        var top: NSLayoutYAxisAnchor?
        products.sorted { left, right in
            map.first { $0.1 == left.productIdentifier }!.key.rawValue < map.first { $0.1 == right.productIdentifier }!.key.rawValue
        }.forEach {
            let item = Item($0, bordered: top != nil, shop: self)
            scroll.documentView!.addSubview(item)
            
            if top == nil {
                item.topAnchor.constraint(equalTo: scroll.documentView!.topAnchor, constant: 120).isActive = true
            } else {
                item.topAnchor.constraint(equalTo: top!).isActive = true
            }
            
            item.leftAnchor.constraint(equalTo: scroll.documentView!.leftAnchor, constant: 70).isActive = true
            item.widthAnchor.constraint(equalTo: scroll.widthAnchor, constant: -140).isActive = true
            top = item.bottomAnchor
        }
        if top != nil {
            scroll.documentView!.bottomAnchor.constraint(equalTo: top!, constant: 60).isActive = true
        }
    }
    
    private func loading() {
        logo.start()
        scroll.documentView!.subviews.filter { $0 is Item }.forEach { $0.removeFromSuperview() }
        _restore.isHidden = true
        image.isHidden = true
        message.isHidden = true
        message.stringValue = ""
    }
    
    private func error(_ error: String) {
        app.alert(.key("Error"), message: error)
        logo.stop()
        scroll.documentView!.subviews.filter { $0 is Item }.forEach { $0.removeFromSuperview() }
        _restore.isHidden = true
        image.isHidden = false
        message.isHidden = false
        message.stringValue = error
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
