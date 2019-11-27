import holbox
import AppKit
import StoreKit

final class Shop: Window.Modal, SKRequestDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    let formatter = NumberFormatter()
    let map = [Perk.two: "holbox.mac.two",
               Perk.ten: "holbox.mac.ten",
               Perk.hundred: "holbox.mac.hundred"]
    private weak var request: SKProductsRequest?
    private weak var logo: Logo!
    private weak var image: Image!
    private weak var message: Label!
    private weak var scroll: Scroll!
    private weak var _restore: Control!
    private var products = [SKProduct]() { didSet { DispatchQueue.main.async { [weak self] in self?.refresh() } } }
    
    deinit { SKPaymentQueue.default().remove(self) }
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(600, 600)
        formatter.numberStyle = .currencyISOCode
        
        let scroll = Scroll()
        contentView!.addSubview(scroll)
        self.scroll = scroll
        
        let title = Label(.key("Shop.title"), 20, .bold, NSColor(named: "haze")!)
        scroll.add(title)
        
        let logo = Logo()
        scroll.add(logo)
        self.logo = logo
        
        let image = Image("error")
        image.isHidden = true
        scroll.add(image)
        self.image = image
        
        let message = Label("", 16, .regular, .init(white: 1, alpha: 0.8))
        message.isHidden = true
        scroll.add(message)
        self.message = message
        
        let _restore = Control(.key("Shop.restore"), self, #selector(restore), NSColor(named: "haze")!.cgColor, .black)
        _restore.isHidden = true
        scroll.add(_restore)
        self._restore = _restore
        
        let _cancel = Control(.key("Shop.cancel"), self, #selector(close), .clear, NSColor(named: "haze")!)
        scroll.add(_cancel)
        
        scroll.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 1).isActive = true
        scroll.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -1).isActive = true
        scroll.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        scroll.right.constraint(equalTo: contentView!.rightAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: contentView!.bottomAnchor).isActive = true
        
        title.leftAnchor.constraint(equalTo: scroll.leftAnchor, constant: 50).isActive = true
        title.topAnchor.constraint(equalTo: scroll.top, constant: 50).isActive = true
        
        logo.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
        logo.centerYAnchor.constraint(equalTo: scroll.centerY).isActive = true
        
        image.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20).isActive = true
        image.leftAnchor.constraint(equalTo: scroll.left, constant: 50).isActive = true
        image.widthAnchor.constraint(equalToConstant: 30).isActive = true
        image.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        message.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 20).isActive = true
        message.leftAnchor.constraint(equalTo: scroll.left, constant: 50).isActive = true
        message.rightAnchor.constraint(lessThanOrEqualTo: scroll.right, constant: -50).isActive = true
        
        _cancel.centerYAnchor.constraint(equalTo: title.centerYAnchor).isActive = true
        _cancel.rightAnchor.constraint(equalTo: scroll.right, constant: -50).isActive = true
        _cancel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        _restore.centerYAnchor.constraint(equalTo: title.centerYAnchor).isActive = true
        _restore.rightAnchor.constraint(equalTo: _cancel.leftAnchor, constant: -20).isActive = true
        _restore.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
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
    
    func purchase(_ product: SKProduct) {
        loading()
        SKPaymentQueue.default().add(.init(product: product))
    }
    
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
    
    private func loading() {
        logo.start()
        scroll.views.filter { $0 is Purchase }.forEach { $0.removeFromSuperview() }
        _restore.isHidden = true
        image.isHidden = true
        message.isHidden = true
        message.stringValue = ""
    }
    
    private func error(_ error: String) {
        app.alert(.key("Error"), message: error)
        logo.stop()
        scroll.views.filter { $0 is Purchase }.forEach { $0.removeFromSuperview() }
        _restore.isHidden = true
        image.isHidden = false
        message.isHidden = false
        message.stringValue = error
    }
    
    private func refresh() {
        image.isHidden = true
        _restore.isHidden = false
        message.isHidden = true
        message.stringValue = ""
        logo.stop()
        scroll.views.filter { $0 is Purchase }.forEach { $0.removeFromSuperview() }
        var top: NSLayoutYAxisAnchor?
        products.sorted { left, right in
            map.first { $0.1 == left.productIdentifier }!.key.rawValue < map.first { $0.1 == right.productIdentifier }!.key.rawValue
        }.forEach {
            let purchase = Purchase($0, shop: self)
            scroll.add(purchase)
            
            if top == nil {
                purchase.topAnchor.constraint(equalTo: scroll.top, constant: 90).isActive = true
            } else {
                purchase.topAnchor.constraint(equalTo: top!).isActive = true
            }
            
            purchase.leftAnchor.constraint(equalTo: scroll.left, constant: 50).isActive = true
            purchase.widthAnchor.constraint(equalTo: scroll.widthAnchor, constant: -100).isActive = true
            top = purchase.bottomAnchor
        }
        if top != nil {
            scroll.bottom.constraint(equalTo: top!, constant: 20).isActive = true
        }
    }
    
    @objc private func restore() {
        SKPaymentQueue.default().restoreCompletedTransactions()
        loading()
    }
}
