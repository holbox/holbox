import UIKit

final class Shopping: View, UITextViewDelegate {
    private weak var scroll: Scroll!
    private weak var emoji: Text!
    private weak var grocery: Text!
    private weak var border: Border!
    
    required init?(coder: NSCoder) { nil }
    required init() {
        super.init()
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let border = Border.horizontal()
        scroll.add(border)
        self.border = border
        
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
        emoji.textContainerInset = .init(top: 10, left: 10, bottom: 10, right: 10)
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
        grocery.textContainerInset = .init(top: 10, left: 10, bottom: 10, right: 10)
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
        
        border.leftAnchor.constraint(equalTo: scroll.left).isActive = true
        border.rightAnchor.constraint(equalTo: scroll.right).isActive = true
        
        titleEmoji.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 30).isActive = true
        titleEmoji.leftAnchor.constraint(equalTo: scroll.left, constant: 20).isActive = true
        
        titleGrocery.topAnchor.constraint(equalTo: emoji.bottomAnchor, constant: 40).isActive = true
        titleGrocery.leftAnchor.constraint(equalTo: scroll.left, constant: 20).isActive = true
        
        emoji.topAnchor.constraint(equalTo: titleEmoji.bottomAnchor, constant: 5).isActive = true
        emoji.leftAnchor.constraint(equalTo: scroll.left, constant: 20).isActive = true
        emoji.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        grocery.topAnchor.constraint(equalTo: titleGrocery.bottomAnchor, constant: 5).isActive = true
        grocery.leftAnchor.constraint(equalTo: scroll.left, constant: 20).isActive = true
        grocery.widthAnchor.constraint(equalToConstant: 250).isActive = true
        
        _add.topAnchor.constraint(equalTo: grocery.bottomAnchor, constant: 10).isActive = true
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
    
    override func refresh() {
        isUserInteractionEnabled = false
        scroll.views.filter { $0 is Grocery }.forEach { $0.removeFromSuperview() }
        
        var top: NSLayoutYAxisAnchor!
        (0 ..< app.session.cards(app.project, list: 0)).forEach {
            let grocery = Grocery($0, shopping: self)
            scroll.add(grocery)
            
            if $0 < app.session.cards(app.project, list: 0) - 1 {
                let border = Border.horizontal(0.3)
                grocery.addSubview(border)
                
                border.bottomAnchor.constraint(equalTo: grocery.bottomAnchor).isActive = true
                border.leftAnchor.constraint(equalTo: grocery.leftAnchor).isActive = true
                border.rightAnchor.constraint(equalTo: grocery.rightAnchor).isActive = true
            }
            
            if top != nil {
                grocery.topAnchor.constraint(equalTo: top).isActive = true
            } else {
                grocery.topAnchor.constraint(equalTo: scroll.top, constant: 20).isActive = true
            }
            
            grocery.leftAnchor.constraint(equalTo: scroll.left).isActive = true
            grocery.rightAnchor.constraint(equalTo: scroll.right).isActive = true
            top = grocery.bottomAnchor
        }
        
        if top != nil {
            border.topAnchor.constraint(equalTo: top, constant: 20).isActive = true
        }
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
        if !emoji.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !grocery.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            app.alert(.key("Grocery"), message: emoji.text.trimmingCharacters(in: .whitespacesAndNewlines) + " " + grocery.text.trimmingCharacters(in: .whitespacesAndNewlines))
            app.session.add(app.project, list: 0, content: emoji.text.trimmingCharacters(in: .whitespacesAndNewlines))
            app.session.add(app.project, list: 1, content: grocery.text.trimmingCharacters(in: .whitespacesAndNewlines))
            app.session.add(app.project, list: 2, content: "0")
            emoji.text = ""
            grocery.text = ""
            refresh()
        }
    }
}
