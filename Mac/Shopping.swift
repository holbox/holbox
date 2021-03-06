import AppKit

final class Shopping: View, NSTextViewDelegate {
    private(set) weak var stock: Stock!
    private weak var scroll: Scroll!
    private weak var emoji: Text!
    private weak var grocery: Text!
    private weak var _height: NSLayoutConstraint!
    private let margin = CGFloat(40)
    private let spacing = CGFloat(15)
    
    required init?(coder: NSCoder) { nil }
    required init() {
        super.init()
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let titleEmoji = Label(.key("Grocery.emoji"), .medium(12), .haze())
        addSubview(titleEmoji)
        
        let titleGrocery = Label(.key("Grocery.descr"), .medium(12), .haze())
        addSubview(titleGrocery)
        
        let emoji = Text(.Fix(), Active(), storage: .init())
        emoji.wantsLayer = true
        emoji.layer!.cornerRadius = 6
        emoji.layer!.backgroundColor = .haze(0.2)
        emoji.textContainerInset.width = 5
        emoji.textContainerInset.height = 5
        emoji.setAccessibilityLabel(.key("Grocery.emoji"))
        emoji.font = .regular(14)
        emoji.alignment = .center
        emoji.textContainer!.maximumNumberOfLines = 1
        (emoji.layoutManager as! Layout).padding = 2
        emoji.delegate = self
        addSubview(emoji)
        self.emoji = emoji
        
        let grocery = Text(.Fix(), Active(), storage: Storage())
        grocery.wantsLayer = true
        grocery.layer!.cornerRadius = 6
        grocery.layer!.backgroundColor = .haze(0.2)
        grocery.textContainerInset.width = 5
        grocery.textContainerInset.height = 5
        grocery.textContainer!.maximumNumberOfLines = 1
        grocery.setAccessibilityLabel(.key("Grocery.descr"))
        grocery.font = .regular(14)
        (grocery.textStorage as! Storage).attributes = [.plain: [.font: NSFont.regular(14), .foregroundColor: NSColor.white],
                                                        .emoji: [.font: NSFont.regular(14)],
                                                        .bold: [.font: NSFont.medium(16), .foregroundColor: NSColor.white],
                                                        .tag: [.font: NSFont.medium(14), .foregroundColor: NSColor.haze()]]
        grocery.intro = true
        (grocery.layoutManager as! Layout).padding = 2
        addSubview(grocery)
        self.grocery = grocery
        
        let _add = Button("plus", target: self, action: #selector(add))
        _add.setAccessibilityLabel(.key("Shopping.add"))
        addSubview(_add)
        
        let stock = Stock()
        scroll.add(stock)
        self.stock = stock
        
        let border = Border.horizontal()
        addSubview(border)
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: border.topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        scroll.width.constraint(equalTo: scroll.widthAnchor).isActive = true
        _height = scroll.height.constraint(equalToConstant: 0)
        _height.isActive = true
        
        titleEmoji.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 25).isActive = true
        titleEmoji.leftAnchor.constraint(equalTo: leftAnchor, constant: 35).isActive = true
        
        titleGrocery.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 25).isActive = true
        titleGrocery.leftAnchor.constraint(equalTo: emoji.rightAnchor, constant: 20).isActive = true
        
        emoji.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 15).isActive = true
        emoji.leftAnchor.constraint(equalTo: titleEmoji.rightAnchor, constant: 5).isActive = true
        emoji.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        grocery.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 15).isActive = true
        grocery.leftAnchor.constraint(equalTo: titleGrocery.rightAnchor, constant: 5).isActive = true
        grocery.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        _add.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
        _add.leftAnchor.constraint(equalTo: grocery.rightAnchor, constant: 10).isActive = true
        _add.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _add.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        stock.topAnchor.constraint(equalTo: scroll.top, constant: 35).isActive = true
        stock.leftAnchor.constraint(equalTo: scroll.left, constant: 60).isActive = true
        stock.rightAnchor.constraint(equalTo: scroll.right, constant: -60).isActive = true
        
        border.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        border.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -70).isActive = true
        
        refresh()
    }
    
    override func keyDown(with: NSEvent) {
        switch with.keyCode {
        case 36:
            add()
        case 48:
            window!.makeFirstResponder(grocery)
        case 53:
            emoji.string = ""
            grocery.string = ""
        default: super.keyDown(with: with)
        }
    }
    
    override func viewDidEndLiveResize() {
        super.viewDidEndLiveResize()
        animate()
        stock.resize()
    }
    
    func textDidBeginEditing(_: Notification) {
        app.orderFrontCharacterPalette(nil)
    }
    
    func textView(_: NSTextView, shouldChangeTextIn: NSRange, replacementString: String?) -> Bool {
       if replacementString?.mark({ mode, _ in mode }).first(where: { $0 != .emoji }) != nil {
           return false
       }
       return true
    }
    
    func textDidChange(_: Notification) {
        if emoji.string.count > 1 {
            emoji.string = .init(emoji.string.suffix(1))
        }
    }
    
    override func refresh() {
        scroll.views.filter { $0 is Grocery }.forEach { $0.removeFromSuperview() }
        (0 ..< app.session.cards(app.project, list: 0)).forEach(grocery(_:))
        scroll.documentView!.layoutSubtreeIfNeeded()
        reorder()
        stock.refresh()
    }
    
    override func add() {
        if !emoji.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !grocery.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            app.alert(.key("Grocery"), message: emoji.string.trimmingCharacters(in: .whitespacesAndNewlines) + " " + grocery.string.trimmingCharacters(in: .whitespacesAndNewlines))
            app.session.add(app.project, emoji: emoji.string, grocery: grocery.string)
            emoji.string = ""
            grocery.string = ""
            scroll.views.compactMap { $0 as? Grocery }.forEach { $0.index += 1 }
            grocery(0)
            scroll.documentView!.layoutSubtreeIfNeeded()
            
            animate()
            stock.refresh()
        } else {
            window!.makeFirstResponder(emoji)
        }
    }
    
    override func found(_ ranges: [(Int, Int, NSRange)]) {
        scroll.views.compactMap { $0 as? Grocery }.forEach { grocery in
            let emojis = ranges.filter { $0.0 == 0 && $0.1 == grocery.index }.map { $0.2 as NSValue }
            let groceries = ranges.filter { $0.0 == 1 && $0.1 == grocery.index }.map { $0.2 as NSValue }
            if emojis.isEmpty {
                grocery.emoji.setSelectedRange(.init())
            } else {
                grocery.emoji.setSelectedRanges(emojis, affinity: .downstream, stillSelecting: true)
            }
            if groceries.isEmpty {
                grocery.grocery.setSelectedRange(.init())
            } else {
                grocery.grocery.setSelectedRanges(groceries, affinity: .downstream, stillSelecting: true)
            }
        }
    }
    
    override func select(_ list: Int, _ card: Int, _ range: NSRange) {
        let text: Text
        if list == 0 {
            text = scroll.views.compactMap { $0 as? Grocery }.first { $0.index == card }!.emoji
        } else {
            text = scroll.views.compactMap { $0 as? Grocery }.first { $0.index == card }!.grocery
        }
        text.showFindIndicator(for: range)
        scroll.center(scroll.contentView.convert(text.layoutManager!.boundingRect(forGlyphRange: range, in: text.textContainer!), from: text))
    }
    
    func animate() {
        reorder()
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.6
            $0.allowsImplicitAnimation = true
            scroll.documentView!.layoutSubtreeIfNeeded()
        }
    }
    
    private func reorder() {
        var top = margin + 50
        var left = margin
        var bottom = margin + spacing
        scroll.views.compactMap { $0 as? Grocery }.sorted { $0.index < $1.index }.forEach {
            if left + $0.bounds.width > app.main.frame.width - margin {
                left = margin
                top = bottom + spacing
                bottom = top
            }
            $0.top.constant = top
            $0.left.constant = left
            bottom = max(top + $0.bounds.height, bottom)
            left += $0.bounds.width + spacing
        }
        _height.constant = bottom + margin
    }
    
    private func grocery(_ index: Int) {
        let grocery = Grocery(index, shopping: self)
        scroll.add(grocery)
        
        grocery.top = grocery.topAnchor.constraint(equalTo: scroll.top)
        grocery.left = grocery.leftAnchor.constraint(equalTo: scroll.left)
    }
}
