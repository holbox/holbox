import UIKit

class Stock: Modal, UITextViewDelegate {
    final class New: Stock {
        required init?(coder: NSCoder) { nil }
        override init(_ shopping: Shopping) {
            super.init(shopping)
            title = .key("Stock.add.title")
            button = .key("Stock.add.done")
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            emoji.text = .key("Stock.add.emoji")
            label.text = .key("Stock.add.label")

            let cancel = Control(.key("Stock.cancel"), self, #selector(close), UIColor(named: "background")!, UIColor(named: "haze")!)
            view.addSubview(cancel)

            cancel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
            cancel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            cancel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        }

        override func done() {
            super.done()
            let count = app.session.cards(app.project, list: 0)
            app.session.add(app.project, emoji: emoji.text, description: label.text)
            if app.session.cards(app.project, list: 0) > count {
                app.alert(.key("Product"), message: {
                    $0.0 + " " + $0.1
                } (app.session.product(app.project, index: count)))
                shopping.refresh()
                shopping.stockLast()
            }
            close()
        }
    }
    
    final class Edit: Stock {
        private let index: Int
        private weak var _delete: Control!
        
        required init?(coder: NSCoder) { nil }
        init(_ shopping: Shopping, index: Int) {
            self.index = index
            super.init(shopping)
            title = .key("Stock.edit.title")
            button = .key("Stock.edit.done")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            let content = app.session.product(app.project, index: index)
            emoji.text = content.0
            label.text = content.1

            let _delete = Control(.key("Stock.delete"), self, #selector(remove), UIColor(named: "background")!, UIColor(named: "haze")!)
            view.addSubview(_delete)
            self._delete = _delete

            _delete.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
            _delete.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            _delete.widthAnchor.constraint(equalToConstant: 100).isActive = true
        }
        
        override func done() {
            super.done()
            let old = app.session.product(app.project, index: index)
            app.session.product(app.project, index: index, emoji: emoji.text, description: label.text)
            let content = app.session.product(app.project, index: index)
            if old != content {
                app.alert(.key("Product"), message: content.0 + " " + content.1)
                shopping.refresh()
            }
            close()
        }
        
        @objc private func remove() {
            close()
            app.present(Delete.Product(index), animated: true)
        }
    }
    
    private weak var shopping: Shopping!
    private weak var emoji: Text!
    private weak var label: Text!
    private var button = ""
    
    required init?(coder: NSCoder) { nil }
    private init(_ shopping: Shopping) {
        super.init()
        self.shopping = shopping
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let _title = Label(title!, 16, .bold, UIColor(named: "haze")!)
        view.addSubview(_title)
        
        let emoji = Text()
        emoji.accessibilityLabel = .key("Product.emoji")
        emoji.font = .systemFont(ofSize: 60)
        (emoji.textStorage as! Storage).fonts = [.plain: (emoji.font!, .white),
                                               .emoji: (emoji.font!, .white),
                                               .bold: (emoji.font!, .white),
                                               .tag: (emoji.font!, .white)]
        emoji.textContainerInset = .init(top: 20, left: 30, bottom: 20, right: 5)
        emoji.textContainer.maximumNumberOfLines = 1
        emoji.delegate = self
        emoji.isScrollEnabled = false
        emoji.bounces = false
        emoji.returnKeyType = .next
        (emoji.layoutManager as! Layout).padding = 2
        view.addSubview(emoji)
        self.emoji = emoji
        
        let label = Text()
        label.accessibilityLabel = .key("Product.description")
        label.font = .systemFont(ofSize: 16, weight: .regular)
        (label.textStorage as! Storage).fonts = [
            .plain: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 16), weight: .bold), .white),
            .emoji: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 22), weight: .regular), .white),
            .bold: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 18), weight: .bold), UIColor(named: "haze")!),
            .tag: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 14), weight: .bold), UIColor(named: "haze")!)]
        label.textContainerInset = .init(top: 30, left: 5, bottom: 10, right: 20)
        label.delegate = self
        label.isScrollEnabled = false
        label.bounces = false
        label.returnKeyType = .done
        (label.layoutManager as! Layout).padding = 2
        view.addSubview(label)
        self.label = label
        
        let _done = Control(button, self, #selector(done), UIColor(named: "haze")!, .black)
        view.addSubview(_done)
        
        _title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        _title.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        
        emoji.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        emoji.topAnchor.constraint(equalTo: _done.bottomAnchor, constant: 10).isActive = true
        emoji.heightAnchor.constraint(equalToConstant: 100).isActive = true
        emoji.widthAnchor.constraint(equalToConstant: 110).isActive = true
        
        label.leftAnchor.constraint(equalTo: emoji.rightAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        label.topAnchor.constraint(equalTo: emoji.topAnchor).isActive = true
        label.bottomAnchor.constraint(greaterThanOrEqualTo: emoji.bottomAnchor).isActive = true
    
        _done.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        _done.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        _done.widthAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emoji.becomeFirstResponder()
    }
    
    func textView(_ text: UITextView, shouldChangeTextIn: NSRange, replacementText: String) -> Bool {
        if text == emoji {
            if replacementText == "\n" {
                label.becomeFirstResponder()
                label.selectedRange  = .init(location: 0, length: label.text.count)
                return false
            } else if replacementText.mark({ mode, _ in mode }).first(where: { $0 != .emoji }) != nil {
                return false
            }
        }
        return true
    }
    
    func textViewDidChange(_ text: UITextView) {
        if text == emoji {
            if emoji.text.count > 1 {
                emoji.text = .init(emoji.text.suffix(1))
            }
        }
    }
    
    @objc func done() {
        app.window!.endEditing(true)
    }
}
