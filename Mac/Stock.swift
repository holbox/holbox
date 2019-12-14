import AppKit

class Stock: Modal, NSTextViewDelegate {
    final class New: Stock {
        private weak var shopping: Shopping?
        
        init(_ shopping: Shopping) {
            super.init(.key("Stock.add.title"), .key("Stock.add.done"))
            self.shopping = shopping
            
            emoji.string = .key("Stock.add.emoji")
            label.string = .key("Stock.add.label")
            
            let cancel = Control(.key("Stock.cancel"), self, #selector(close), .clear, NSColor(named: "haze")!.withAlphaComponent(0.7))
            contentView!.addSubview(cancel)
            
            cancel.widthAnchor.constraint(equalToConstant: 140).isActive = true
            cancel.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -40).isActive = true
            cancel.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
            
            emoji.didChangeText()
            label.didChangeText()
        }
        
        override func done() {
            super.done()
            let count = app.session.cards(app.project, list: 0)
            app.session.add(app.project, emoji: emoji.string, description: label.string)
            if app.session.cards(app.project, list: 0) > count {
                app.alert(.key("Product"), message: {
                    $0.0 + " " + $0.1
                } (app.session.product(app.project, index: count)))
                app.main.refresh()
                shopping?.stockLast()
            }
            close()
        }
    }
    
    final class Edit: Stock {
        private let index: Int
        
        init(_ index: Int) {
            self.index = index
            super.init(.key("Stock.edit.title"), .key("Stock.edit.done"))
            let content = app.session.product(app.project, index: index)
            emoji.string = content.0
            label.string = content.1

            let _delete = Control(.key("Stock.delete"), self, #selector(delete), .clear, NSColor(named: "haze")!.withAlphaComponent(0.7))
            contentView!.addSubview(_delete)

            _delete.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -40).isActive = true
            _delete.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
            _delete.widthAnchor.constraint(equalToConstant: 140).isActive = true

            emoji.didChangeText()
            label.didChangeText()
        }
        
        override func done() {
            super.done()
            let old = app.session.product(app.project, index: index)
            app.session.product(app.project, index: index, emoji: emoji.string, description: label.string)
            let content = app.session.product(app.project, index: index)
            if old != content {
                app.alert(.key("Product"), message: content.0 + " " + content.1)
                app.main.refresh()
            }
            close()
        }
        
        @objc private func delete() {
            makeFirstResponder(nil)
            close()
            app.runModal(for: Delete.Product(index))
        }
    }
    
    private weak var emoji: Text!
    private weak var label: Text!
    
    private init(_ title: String, _ button: String) {
        super.init(400, 320)
        let _title = Label(title, 18, .bold, NSColor(named: "haze")!)
        contentView!.addSubview(_title)
        
        let emoji = Text(.Expand(150, 150), Active())
        emoji.textContainerInset.width = 10
        emoji.textContainerInset.height = 10
        emoji.font = NSFont(name: "Times New Roman", size: 70)
        emoji.setAccessibilityLabel(.key("Product.emoji"))
        (emoji.textStorage as! Storage).fonts = [.plain: (NSFont(name: "Times New Roman", size: 70)!, .white),
                                               .emoji: (NSFont(name: "Times New Roman", size: 70)!, .white),
                                               .bold: (NSFont(name: "Times New Roman", size: 70)!, .white),
                                               .tag: (NSFont(name: "Times New Roman", size: 70)!, .white)]
        emoji.textContainer!.maximumNumberOfLines = 1
        (emoji.layoutManager as! Layout).padding = 2
        emoji.delegate = self
        contentView!.addSubview(emoji)
        self.emoji = emoji
        
        let label = Text(.Fix(), Active())
        label.textContainerInset.width = 10
        label.textContainerInset.height = 10
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.setAccessibilityLabel(.key("Product.description"))
        (label.textStorage as! Storage).fonts = [.plain: (.systemFont(ofSize: 16, weight: .medium), .white),
                                                 .emoji: (NSFont(name: "Times New Roman", size: 22)!, .white),
                                                 .bold: (.systemFont(ofSize: 18, weight: .bold), NSColor(named: "haze")!),
                                                 .tag: (.systemFont(ofSize: 14, weight: .bold), NSColor(named: "haze")!)]
        label.textContainer!.maximumNumberOfLines = 10
        label.intro = true
        (label.layoutManager as! Layout).padding = 2
        label.delegate = self
        contentView!.addSubview(label)
        self.label = label
        
        let _done = Control(button, self, #selector(done), NSColor(named: "haze")!.cgColor, .black)
        contentView!.addSubview(_done)
        
        _title.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 30).isActive = true
        _title.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        
        emoji.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 40).isActive = true
        emoji.topAnchor.constraint(equalTo: _title.bottomAnchor, constant: 20).isActive = true
        
        label.leftAnchor.constraint(equalTo: emoji.rightAnchor, constant: 10).isActive = true
        label.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -40).isActive = true
        label.topAnchor.constraint(equalTo: emoji.topAnchor, constant: 20).isActive = true
        
        _done.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 40).isActive = true
        _done.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -82).isActive = true
        _done.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        _done.widthAnchor.constraint(equalToConstant: 140).isActive = true
        
        app.orderFrontCharacterPalette(nil)
    }
    
    func textView(_ text: NSTextView, shouldChangeTextIn: NSRange, replacementString: String?) -> Bool {
        if text == emoji {
            if replacementString?.mark({ mode, _ in mode }).first(where: { $0 != .emoji }) != nil {
                return false
            }
        }
        return true
    }
    
    func textDidChange(_ notification: Notification) {
        if (notification.object as! Text) == emoji {
            if emoji.string.count > 1 {
                emoji.string = .init(emoji.string.suffix(1))
            }
        }
    }
    
    @objc func done() {
        makeFirstResponder(nil)
    }
    
    override func keyDown(with: NSEvent) {
        switch with.keyCode {
        case 36:
            DispatchQueue.main.async { [weak self] in
                self?.relabel()
            }
        case 48:
            if firstResponder == emoji {
                DispatchQueue.main.async { [weak self] in
                    self?.relabel()
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.reemoji()
                }
            }
        default: super.keyDown(with: with)
        }
    }
    
    private func relabel() {
        makeFirstResponder(label)
        label.setSelectedRange(.init(location: 0, length: label.string.count))
    }
    
    private func reemoji() {
        makeFirstResponder(emoji)
        emoji.setSelectedRange(.init(location: 0, length: emoji.string.count))
    }
}
