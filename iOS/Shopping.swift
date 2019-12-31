import UIKit

final class Shopping: View, UITextViewDelegate {
    private(set) weak var stock: Stock!
    private weak var scroll: Scroll!
    private weak var emoji: Text!
    private weak var grocery: Text!
    private weak var _border: NSLayoutConstraint!
    private let margin = CGFloat(20)
    private let spacing = CGFloat(5)
    
    required init?(coder: NSCoder) { nil }
    required init() {
        super.init()
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let stock = Stock()
        scroll.add(stock)
        self.stock = stock
        
        let border = Border.horizontal()
        scroll.add(border)
        
        let titleEmoji = Label(.key("Emoji"), .medium(12), .haze())
        scroll.add(titleEmoji)
        
        let titleGrocery = Label(.key("Grocery"), .medium(12), .haze())
        scroll.add(titleGrocery)
        
        let _add = Button("plus", target: self, action: #selector(add))
        _add.accessibilityLabel = .key("Shopping.add")
        scroll.add(_add)
        
        let emoji = Text(.init())
        emoji.backgroundColor = .haze(0.2)
        emoji.layer.cornerRadius = 6
        emoji.isScrollEnabled = false
        emoji.accessibilityLabel = .key("Emoji")
        emoji.textContainerInset = .init(top: 15, left: 10, bottom: 15, right: 10)
        emoji.font = .regular(30)
        emoji.textContainer.maximumNumberOfLines = 1
        (emoji.layoutManager as! Layout).padding = 2
        emoji.delegate = self
        scroll.add(emoji)
        self.emoji = emoji

        let grocery = Text(Storage())
        grocery.backgroundColor = .haze(0.2)
        grocery.layer.cornerRadius = 6
        grocery.isScrollEnabled = false
        grocery.accessibilityLabel = .key("Grocery")
        grocery.textContainerInset = .init(top: 20, left: 15, bottom: 20, right: 15)
        grocery.font = .regular(14)
        (grocery.textStorage as! Storage).attributes = [.plain: [.font: UIFont.regular(14), .foregroundColor: UIColor.white],
                                                        .emoji: [.font: UIFont.regular(14)],
                                                        .bold: [.font: UIFont.medium(16), .foregroundColor: UIColor.white],
                                                        .tag: [.font: UIFont.medium(14), .foregroundColor: UIColor.haze()]]
        (grocery.layoutManager as! Layout).padding = 2
        scroll.add(grocery)
        self.grocery = grocery
        
        scroll.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        scroll.width.constraint(equalTo: safeAreaLayoutGuide.widthAnchor).isActive = true
        scroll.height.constraint(greaterThanOrEqualTo: scroll.heightAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: _add.bottomAnchor, constant: 20).isActive = true
        
        stock.topAnchor.constraint(equalTo: scroll.top, constant: 20).isActive = true
        stock.leftAnchor.constraint(equalTo: scroll.left, constant: 30).isActive = true
        stock.rightAnchor.constraint(equalTo: scroll.right, constant: -30).isActive = true
        
        border.leftAnchor.constraint(equalTo: scroll.left).isActive = true
        border.rightAnchor.constraint(equalTo: scroll.right).isActive = true
        _border = border.topAnchor.constraint(equalTo: scroll.top)
        _border.isActive = true
        
        titleEmoji.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 30).isActive = true
        titleEmoji.leftAnchor.constraint(equalTo: scroll.left, constant: 20).isActive = true
        
        titleGrocery.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 30).isActive = true
        titleGrocery.leftAnchor.constraint(equalTo: emoji.rightAnchor, constant: 20).isActive = true
        
        emoji.topAnchor.constraint(equalTo: titleEmoji.bottomAnchor, constant: 5).isActive = true
        emoji.leftAnchor.constraint(equalTo: scroll.left, constant: 20).isActive = true
        emoji.width = emoji.widthAnchor.constraint(equalToConstant: 60)
        
        grocery.topAnchor.constraint(equalTo: emoji.topAnchor).isActive = true
        grocery.leftAnchor.constraint(equalTo: emoji.rightAnchor, constant: 20).isActive = true
        grocery.width = grocery.widthAnchor.constraint(equalToConstant: 200)
        
        _add.topAnchor.constraint(equalTo: grocery.bottomAnchor, constant: 20).isActive = true
        _add.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
        _add.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _add.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        refresh()
    }
    
    func textView(_: UITextView, shouldChangeTextIn: NSRange, replacementText: String) -> Bool {
        if replacementText.mark({ mode, _ in mode }).first(where: { $0 != .emoji }) != nil {
            return false
        }
        return true
    }
    
    func textViewDidChange(_: UITextView) {
        if emoji.text.count > 1 {
            emoji.text = .init(emoji.text.suffix(1))
        }
    }
    
    override func rotate() {
        animate()
        stock.resize()
    }
    
    override func refresh() {
        isUserInteractionEnabled = false
        scroll.views.filter { $0 is Grocery }.forEach { $0.removeFromSuperview() }
        (0 ..< app.session.cards(app.project, list: 0)).forEach(grocery(_:))
        scroll.content.layoutIfNeeded()
        reorder()
        stock.refresh()
        isUserInteractionEnabled = true
    }
    
    override func found(_ ranges: [(Int, Int, NSRange)]) {
        scroll.views.compactMap { $0 as? Grocery }.forEach {
            $0.emoji.textStorage.removeAttribute(.backgroundColor, range: .init(location: 0, length: $0.emoji.text.count))
            $0.grocery.textStorage.removeAttribute(.backgroundColor, range: .init(location: 0, length: $0.grocery.text.count))
        }
    }
    
    override func select(_ list: Int, _ card: Int, _ range: NSRange) {
        scroll.views.compactMap { $0 as? Grocery }.forEach {
            $0.emoji.textStorage.removeAttribute(.backgroundColor, range: .init(location: 0, length: $0.emoji.text.utf16.count))
            $0.grocery.textStorage.removeAttribute(.backgroundColor, range: .init(location: 0, length: $0.grocery.text.utf16.count))
            if $0.index == card {
                if list == 0 {
                    $0.emoji.textStorage.addAttribute(.backgroundColor, value: UIColor.haze(0.6), range: range)
                    scroll.center(scroll.content.convert($0.emoji.layoutManager.boundingRect(forGlyphRange: range, in: $0.emoji.textContainer), from: $0))
                } else {
                    $0.grocery.textStorage.addAttribute(.backgroundColor, value: UIColor.haze(0.6), range: range)
                    scroll.center(scroll.content.convert($0.emoji.layoutManager.boundingRect(forGlyphRange: range, in: $0.grocery.textContainer), from: $0))
                }
            }
        }
    }
    
    override func add() {
        app.window!.endEditing(true)
        if !emoji.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !grocery.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            app.alert(.key("Grocery"), message: emoji.text.trimmingCharacters(in: .whitespacesAndNewlines) + " " + grocery.text.trimmingCharacters(in: .whitespacesAndNewlines))
            app.session.add(app.project, emoji: emoji.text, grocery: grocery.text)
            emoji.text = ""
            grocery.text = ""
            scroll.views.compactMap { $0 as? Grocery }.forEach { $0.index += 1 }
            grocery(0)
            animate()
            stock.refresh()
        }
    }
    
    func animate() {
        reorder()
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.scroll.contentOffset.y = 0
            self?.scroll.content.layoutIfNeeded()
        }
    }
    
    private func reorder() {
        var top = margin + 30
        var left = CGFloat()
        var bottom = margin + spacing
        let width = app.main.bounds.width / floor(app.main.bounds.width / 150)
        scroll.views.compactMap { $0 as? Grocery }.sorted { $0.index < $1.index }.forEach {
            $0.grocery.width.constant = width - 45
            $0.grocery.textContainer.size.width = width - 75
            $0.grocery.textContainer.size.height = 100_000
            $0.grocery.layoutManager.ensureLayout(for: $0.grocery.textContainer)
            $0.grocery.height.constant = max(ceil($0.grocery.layoutManager.usedRect(for: $0.grocery.textContainer).size.height), 20) + 40
            
            if left + width > app.main.bounds.width {
                left = 0
                top = bottom + spacing
                bottom = top
            }
            $0.top.constant = top
            $0.left.constant = left
            bottom = max(top + $0.grocery.height.constant, bottom)
            left += width
        }
        _border.constant = bottom + margin
    }
    
    private func grocery(_ index: Int) {
        let grocery = Grocery(index, shopping: self)
        scroll.add(grocery)
        
        grocery.top = grocery.topAnchor.constraint(equalTo: scroll.top)
        grocery.left = grocery.leftAnchor.constraint(equalTo: scroll.left)
    }
}
