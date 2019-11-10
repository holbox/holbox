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
            
            let cancel = Control(.key("Stock.cancel"), self, #selector(close), .clear, .init(white: 1, alpha: 0.8))
            view.addSubview(cancel)

            cancel.widthAnchor.constraint(equalToConstant: 140).isActive = true
            cancel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20).isActive = true
            cancel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        }
        
        override func done() {
            super.done()
            let count = app.session.cards(app.project, list: 0)
            app.session.add(app.project, emoji: emoji.text, description: label.text)
            if app.session.cards(app.project, list: 0) > count {
                app.alert(.key("Add.card.\(app.mode.rawValue)"), message: {
                    $0.0 + " " + $0.1
                } (app.session.product(app.project, index: count)))
                shopping?.refresh()
                shopping?.stockLast()
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
            
            let _delete = Control(.key("Stock.delete"), self, #selector(remove), UIColor(named: "haze")!.withAlphaComponent(0.3), .init(white: 1, alpha: 0.8))
            view.addSubview(_delete)
            self._delete = _delete
            
            _delete.widthAnchor.constraint(equalToConstant: 140).isActive = true
            _delete.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20).isActive = true
            _delete.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        }
        
        override func done() {
            super.done()
            let old = app.session.product(app.project, index: index)
            app.session.product(app.project, index: index, emoji: emoji.text, description: label.text)
            let content = app.session.product(app.project, index: index)
            if old != content {
                app.alert(.key("Add.card.\(app.mode.rawValue)"), message: content.0 + " " + content.1)
                shopping?.refresh()
            }
            close()
        }
        
        @objc private func remove() {
            app.win.endEditing(true)
            let alert = UIAlertController(title: .key("Delete.title.card.\(app.mode.rawValue)"), message: nil, preferredStyle: .actionSheet)
            alert.addAction(.init(title: .key("Delete.confirm"), style: .destructive) { [weak self] _ in
                self?.presentingViewController!.dismiss(animated: true) { [weak self] in
                    self?.confirm()
                }
            })
            alert.addAction(.init(title: .key("Delete.cancel"), style: .cancel))
            alert.popoverPresentationController?.sourceView = _delete
            present(alert, animated: true)
        }
        
        private func confirm() {
            let product = app.session.product(app.project, index: index)
            app.alert(.key("Delete.deleted.card.\(app.mode.rawValue)"), message: product.0 + " " + product.1)
            app.session.delete(app.project, product: index)
            shopping?.refresh()
        }
    }
    
    private weak var shopping: Shopping?
    private weak var emoji: Text!
    private weak var label: Text!
    private var button = ""
    
    required init?(coder: NSCoder) { nil }
    private init(_ shopping: Shopping) {
        super.init(nibName: nil, bundle: nil)
        self.shopping = shopping
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let _title = Label(title!, 18, .bold, UIColor(named: "haze")!)
        view.addSubview(_title)
        
        let emoji = Text()
        emoji.accessibilityLabel = .key("Product.emoji")
        emoji.font = .systemFont(ofSize: 60)
        emoji.textAlignment = .center
        (emoji.textStorage as! Storage).fonts = [.plain: emoji.font!,
                                               .emoji: emoji.font!,
                                               .bold: emoji.font!]
        emoji.textContainerInset = .init(top: 10, left: 20, bottom: 0, right: 20)
        emoji.textContainer.maximumNumberOfLines = 1
        emoji.delegate = self
        emoji.isScrollEnabled = false
        emoji.bounces = false
        emoji.returnKeyType = .next
        view.addSubview(emoji)
        self.emoji = emoji
        
        let label = Text()
        label.textAlignment = .center
        label.accessibilityLabel = .key("Product.description")
        label.font = .systemFont(ofSize: 20, weight: .medium)
        (label.textStorage as! Storage).fonts = [.plain: label.font!,
                                               .emoji: label.font!,
                                               .bold: label.font!]
        label.textContainerInset = .init(top: 10, left: 20, bottom: 0, right: 20)
        label.textContainer.maximumNumberOfLines = 2
        label.delegate = self
        label.isScrollEnabled = false
        label.bounces = false
        label.returnKeyType = .done
        view.addSubview(label)
        self.label = label
        
        let _done = Control(button, self, #selector(done), UIColor(named: "haze")!, .black)
        view.addSubview(_done)
        
        _title.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        _title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        
        emoji.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        emoji.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        emoji.topAnchor.constraint(equalTo: _done.bottomAnchor, constant: 10).isActive = true
        emoji.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        label.topAnchor.constraint(equalTo: emoji.bottomAnchor).isActive = true
        label.heightAnchor.constraint(equalToConstant: 90).isActive = true
    
        _done.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        _done.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        _done.widthAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emoji.becomeFirstResponder()
    }
    
    func textView(_ text: UITextView, shouldChangeTextIn: NSRange, replacementText: String) -> Bool {
        if replacementText == "\n" {
            if text == emoji {
                label.becomeFirstResponder()
                label.selectedRange  = .init(location: 0, length: label.text.count)
            } else {
                done()
            }
            return false
        } else {
            if text == emoji {
                if replacementText.mark({ mode, _ in mode }).first(where: { $0 != .emoji }) != nil {
                    return false
                }
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
        app.win.endEditing(true)
    }
}
