import AppKit

final class Shopping: View {
    private weak var scroll: Scroll!
    private weak var emoji: Text!
    private weak var grocery: Text!
    
    required init?(coder: NSCoder) { nil }
    required init() {
        super.init()
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let border = Border.vertical()
        addSubview(border)
        
        let titleEmoji = Label(.key("Emoji"), .medium(12), .haze())
        addSubview(titleEmoji)
        
        let titleGrocery = Label(.key("Grocery"), .medium(12), .haze())
        addSubview(titleGrocery)
        
        let emoji = Text(.Fix(), Active(), storage: .init())
        emoji.wantsLayer = true
        emoji.layer!.cornerRadius = 6
        emoji.layer!.backgroundColor = .haze(0.2)
        emoji.textContainerInset.width = 10
        emoji.textContainerInset.height = 10
        emoji.setAccessibilityLabel(.key("Emoji"))
        emoji.font = .regular(30)
        emoji.textContainer!.maximumNumberOfLines = 1
        (emoji.layoutManager as! Layout).padding = 2
        addSubview(emoji)
        self.emoji = emoji
        
        let grocery = Text(.Fix(), Active(), storage: Storage())
        grocery.wantsLayer = true
        grocery.layer!.cornerRadius = 6
        grocery.layer!.backgroundColor = .haze(0.2)
        grocery.textContainerInset.width = 10
        grocery.textContainerInset.height = 10
        grocery.setAccessibilityLabel(.key("Grocery"))
        grocery.font = .regular(14)
        (grocery.textStorage as! Storage).attributes = [.plain: [.font: NSFont.regular(14), .foregroundColor: NSColor.white],
                                                        .emoji: [.font: NSFont.regular(14)],
                                                        .bold: [.font: NSFont.medium(18), .foregroundColor: NSColor.white],
                                                        .tag: [.font: NSFont.medium(14), .foregroundColor: NSColor.haze()]]
        grocery.tab = true
        grocery.intro = true
        (grocery.layoutManager as! Layout).padding = 2
        addSubview(grocery)
        self.grocery = grocery
        
        let _add = Button("plus", target: self, action: #selector(add))
        _add.setAccessibilityLabel(.key("Shopping.add"))
        addSubview(_add)
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
        scroll.widthAnchor.constraint(lessThanOrEqualToConstant: 500).isActive = true
        scroll.width.constraint(equalTo: scroll.widthAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: scroll.bottomAnchor).isActive = true

        let width = scroll.widthAnchor.constraint(equalToConstant: 500)
        width.priority = .defaultLow
        width.isActive = true
        
        border.leftAnchor.constraint(equalTo: scroll.rightAnchor).isActive = true
        border.topAnchor.constraint(equalTo: topAnchor).isActive = true
        border.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        
        titleEmoji.topAnchor.constraint(equalTo: topAnchor, constant: 35).isActive = true
        titleEmoji.leftAnchor.constraint(equalTo: border.rightAnchor, constant: 35).isActive = true
        
        titleGrocery.topAnchor.constraint(equalTo: emoji.bottomAnchor, constant: 40).isActive = true
        titleGrocery.leftAnchor.constraint(equalTo: border.rightAnchor, constant: 35).isActive = true
        
        emoji.topAnchor.constraint(equalTo: titleEmoji.bottomAnchor, constant: 5).isActive = true
        emoji.leftAnchor.constraint(equalTo: border.rightAnchor, constant: 35).isActive = true
        emoji.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        grocery.topAnchor.constraint(equalTo: titleGrocery.bottomAnchor, constant: 5).isActive = true
        grocery.leftAnchor.constraint(equalTo: border.rightAnchor, constant: 35).isActive = true
        grocery.widthAnchor.constraint(equalToConstant: 250).isActive = true
        
        _add.topAnchor.constraint(equalTo: grocery.bottomAnchor, constant: 40).isActive = true
        _add.centerXAnchor.constraint(equalTo: grocery.centerXAnchor).isActive = true
        _add.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _add.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        refresh()
    }
    
    override func refresh() {
        scroll.views.forEach { $0.removeFromSuperview() }
        
        var top: NSLayoutYAxisAnchor!
        (0 ..< app.session.cards(app.project, list: 0)).forEach {
            let grocery = Grocery($0, shopping: self)
            scroll.add(grocery)
            
            if top != nil {
                let border = Border.horizontal(0.3)
                scroll.add(border)
                
                border.topAnchor.constraint(equalTo: top).isActive = true
                border.leftAnchor.constraint(equalTo: scroll.left).isActive = true
                border.rightAnchor.constraint(equalTo: scroll.right).isActive = true
                
                grocery.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
            } else {
                grocery.topAnchor.constraint(equalTo: scroll.top, constant: 20).isActive = true
            }
            
            grocery.leftAnchor.constraint(equalTo: scroll.left).isActive = true
            grocery.rightAnchor.constraint(equalTo: scroll.right).isActive = true
            top = grocery.bottomAnchor
        }
        
        if top != nil {
            scroll.bottom.constraint(greaterThanOrEqualTo: top, constant: 20).isActive = true
        }
    }
}
