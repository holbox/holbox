import holbox
import UIKit
import StoreKit

final class Shop: Modal, SKRequestDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    let formatter = NumberFormatter()
    let map = [Perk.two: "holbox.ios.two",
               Perk.ten: "holbox.ios.ten",
               Perk.hundred: "holbox.ios.hundred"]
    private weak var request: SKProductsRequest?
    private weak var logo: Logo!
    private weak var image: Image!
    private weak var message: Label!
    private weak var scroll: Scroll!
    private weak var _restore: Control!
    private var products = [SKProduct]() { didSet { DispatchQueue.main.async { [weak self] in self?.refresh() } } }
    
    deinit { SKPaymentQueue.default().remove(self) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addClose()
        formatter.numberStyle = .currencyISOCode
        
        let scroll = Scroll()
        view.addSubview(scroll)
        self.scroll = scroll
        
        let title = Label(.key("Shop.title"), .medium(14), .haze())
        view.addSubview(title)
        
        let border = Border.horizontal()
        view.addSubview(border)
        
        let logo = Logo()
        view.addSubview(logo)
        self.logo = logo
        
        let image = Image("error")
        image.isHidden = true
        view.addSubview(image)
        self.image = image
        
        let message = Label("", .regular(14), .init(white: 1, alpha: 0.8))
        message.isHidden = true
        view.addSubview(message)
        self.message = message
        
        let _restore = Control(.key("Shop.restore"), self, #selector(restore), .haze(), .black)
        _restore.isHidden = true
        view.addSubview(_restore)
        self._restore = _restore
        
        scroll.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        scroll.width.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: logo.bottomAnchor, constant: 100).isActive = true
        
        title.leftAnchor.constraint(equalTo: _close.rightAnchor).isActive = true
        title.centerYAnchor.constraint(equalTo: _close.centerYAnchor).isActive = true
        
        border.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20).isActive = true
        border.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        logo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logo.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        image.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 40).isActive = true
        image.leftAnchor.constraint(equalTo: title.leftAnchor).isActive = true
        image.widthAnchor.constraint(equalToConstant: 30).isActive = true
        image.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        message.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 20).isActive = true
        message.leftAnchor.constraint(equalTo: title.leftAnchor).isActive = true
        message.rightAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        
        _restore.centerYAnchor.constraint(equalTo: title.centerYAnchor).isActive = true
        _restore.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
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
    
    private func refresh() {
        view.isUserInteractionEnabled = false
        image.isHidden = true
        _restore.isHidden = false
        message.isHidden = true
        message.text = ""
        logo.stop()
        scroll.views.forEach { $0.removeFromSuperview() }
        var top = scroll.top
        products.sorted { left, right in
            map.first { $0.1 == left.productIdentifier }!.key.rawValue < map.first { $0.1 == right.productIdentifier }!.key.rawValue
        }.forEach {
            let purchase = Purchase($0, shop: self)
            scroll.add(purchase)
            
            purchase.topAnchor.constraint(equalTo: top).isActive = true
            purchase.leftAnchor.constraint(equalTo: scroll.left, constant: 15).isActive = true
            purchase.rightAnchor.constraint(equalTo: scroll.right, constant: -15).isActive = true
            top = purchase.bottomAnchor
        }
        scroll.bottom.constraint(equalTo: top, constant: 20).isActive = true
        view.isUserInteractionEnabled = true
    }
    
    private func loading() {
        logo.start()
        scroll.views.forEach { $0.removeFromSuperview() }
        _restore.isHidden = true
        image.isHidden = true
        message.isHidden = true
        message.text = ""
    }
    
    private func error(_ error: String) {
        app.alert(.key("Error"), message: error)
        logo.stop()
        scroll.views.forEach { $0.removeFromSuperview() }
        _restore.isHidden = true
        image.isHidden = false
        message.isHidden = false
        message.text = error
    }
    
    @objc private func restore() {
        SKPaymentQueue.default().restoreCompletedTransactions()
        loading()
    }
}
