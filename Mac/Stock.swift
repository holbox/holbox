import AppKit

class Stock: Window.Modal, NSTextViewDelegate {
    final class New: Stock {
        init(_ shopping: Shopping) {
            super.init(shopping, .key("Stock.add.title"), .key("Stock.add.done"))
            
            emoji.string = .key("Stock.add.emoji")
            message.string = .key("Stock.add.message")
            
            let cancel = Control(.key("Stock.cancel"), self, #selector(close), .clear, .init(white: 1, alpha: 0.6))
            contentView!.addSubview(cancel)
            
            cancel.widthAnchor.constraint(equalToConstant: 140).isActive = true
            cancel.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -40).isActive = true
            cancel.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
            
            emoji.didChangeText()
            message.didChangeText()
        }
        
        override func done() {
            super.done()
            let count = app.session.cards(app.project, list: 0)
            app.session.add(app.project, emoji: emoji.string, description: message.string)
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
        
        init(_ shopping: Shopping, index: Int) {
            self.index = index
            super.init(shopping, .key("Stock.edit.title"), .key("Stock.edit.done"))
            let content = app.session.product(app.project, index: index)
            emoji.string = content.0
            message.string = content.1
            
            let _delete = Control(.key("Stock.delete"), self, #selector(delete), NSColor(named: "haze")!.withAlphaComponent(0.2).cgColor, .init(white: 1, alpha: 0.8))
            contentView!.addSubview(_delete)
            
            _delete.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -40).isActive = true
            _delete.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
            _delete.widthAnchor.constraint(equalToConstant: 140).isActive = true
            
            emoji.didChangeText()
            message.didChangeText()
        }
        
        override func done() {
            super.done()
            let old = app.session.product(app.project, index: index)
            app.session.product(app.project, index: index, emoji: emoji.string, description: message.string)
            let content = app.session.product(app.project, index: index)
            if old != content {
                app.alert(.key("Add.card.\(app.mode.rawValue)"), message: content.0 + " " + content.1)
                shopping?.refresh()
            }
            close()
        }
        
        @objc private func delete() {
            close()
            //app.runModal(for: Delete.Card(<#T##base: Base.View##Base.View#>, index: <#T##Int#>, list: <#T##Int#>))
        }
    }
    
    private weak var shopping: Shopping?
    private weak var emoji: Text!
    private weak var message: Text!
    
    private init(_ shopping: Shopping, _ title: String, _ button: String) {
        super.init(400, 440)
        self.shopping = shopping
        
        let _title = Label(title, 18, .bold, NSColor(named: "haze")!)
        contentView!.addSubview(_title)
        
        let emoji = Text(.Both(320, 150), Active())
        emoji.setAccessibilityLabel(.key("Product.emoji"))
        emoji.font = .systemFont(ofSize: 80, weight: .regular)
        (emoji.textStorage as! Storage).fonts = [.plain: emoji.font!,
                                               .emoji: emoji.font!,
                                               .bold: emoji.font!]
        emoji.textContainer!.maximumNumberOfLines = 1
        emoji.delegate = self
        contentView!.addSubview(emoji)
        self.emoji = emoji
        
        let message = Text(.Vertical(320), Active())
        message.setAccessibilityLabel(.key("Product.description"))
        message.font = .systemFont(ofSize: 25, weight: .medium)
        (message.textStorage as! Storage).fonts = [.plain: message.font!,
                                               .emoji: message.font!,
                                               .bold: message.font!]
        message.textContainer!.maximumNumberOfLines = 2
        message.delegate = self
        contentView!.addSubview(message)
        self.message = message
        
        let _done = Control(button, self, #selector(done), NSColor(named: "haze")!.cgColor, .black)
        contentView!.addSubview(_done)
        
        _title.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 50).isActive = true
        _title.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        
        emoji.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        emoji.topAnchor.constraint(equalTo: _title.bottomAnchor, constant: 20).isActive = true
        
        message.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        message.leftAnchor.constraint(greaterThanOrEqualTo: contentView!.leftAnchor).isActive = true
        message.rightAnchor.constraint(lessThanOrEqualTo: contentView!.rightAnchor).isActive = true
        message.topAnchor.constraint(equalTo: emoji.bottomAnchor).isActive = true
        
        _done.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -82).isActive = true
        _done.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        _done.widthAnchor.constraint(equalToConstant: 140).isActive = true
    }
    
    func textView(_ text: NSTextView, shouldChangeTextIn: NSRange, replacementString: String?) -> Bool {
        if text == emoji {
            if replacementString?.mark({ mode, _ in mode }).first(where: { $0 != .emoji }) != nil {
                return false
            }
            return (text.string as NSString).replacingCharacters(in: shouldChangeTextIn, with: replacementString ?? "").count < 2
        }
        return true
    }
    
    @objc func done() {
        makeFirstResponder(nil)
    }
    
    override func keyDown(with: NSEvent) {
        switch with.keyCode {
        case 36: done()
        case 48:
            if firstResponder == emoji {
                DispatchQueue.main.async { [weak self] in
                    self?.makeFirstResponder(self?.message)
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.makeFirstResponder(self?.emoji)
                }
            }
        default: super.keyDown(with: with)
        }
    }
}
