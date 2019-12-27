import AppKit

final class Shopping: View, NSTextViewDelegate {
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
        grocery.tab = true
        grocery.intro = true
        (grocery.layoutManager as! Layout).padding = 2
        addSubview(grocery)
        self.grocery = grocery
        
        let _add = Button("plus", target: self, action: #selector(add))
        _add.setAccessibilityLabel(.key("Shopping.add"))
        addSubview(_add)
        
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
        _add.leftAnchor.constraint(equalTo: grocery.rightAnchor, constant: 20).isActive = true
        _add.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _add.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        border.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        border.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -60).isActive = true
        
        refresh()
    }
    
    override func viewDidEndLiveResize() {
        super.viewDidEndLiveResize()
        animate()
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
        scroll.views.forEach { $0.removeFromSuperview() }
        (0 ..< app.session.cards(app.project, list: 0)).forEach {
            let grocery = Grocery($0, shopping: self)
            scroll.add(grocery)
            
            grocery.top = grocery.topAnchor.constraint(equalTo: scroll.top)
            grocery.left = grocery.leftAnchor.constraint(equalTo: scroll.left)
        }
        scroll.documentView!.layoutSubtreeIfNeeded()
        reorder()
    }
    
    override func add() {
        if !emoji.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !grocery.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            app.alert(.key("Grocery"), message: emoji.string.trimmingCharacters(in: .whitespacesAndNewlines) + " " + grocery.string.trimmingCharacters(in: .whitespacesAndNewlines))
            app.session.add(app.project, emoji: emoji.string, grocery: grocery.string)
            emoji.string = ""
            grocery.string = ""
            scroll.views.map { $0 as! Grocery }.forEach {
                $0.index += 1
            }
            
            let grocery = Grocery(0, shopping: self)
            scroll.add(grocery)
            grocery.top = grocery.topAnchor.constraint(equalTo: scroll.top)
            grocery.left = grocery.leftAnchor.constraint(equalTo: scroll.left)
            scroll.documentView!.layoutSubtreeIfNeeded()
            
            animate()
        }
    }
    
    private func animate() {
        reorder()
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.6
            $0.allowsImplicitAnimation = true
            scroll.documentView!.layoutSubtreeIfNeeded()
        }
    }
    
    private func reorder() {
        var top = margin
        var left = margin
        var bottom = margin + spacing
        scroll.views.map { $0 as! Grocery }.forEach {
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
}
