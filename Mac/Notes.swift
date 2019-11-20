import AppKit

final class Notes: View, NSTextViewDelegate {
    private weak var text: Text!
    private weak var scroll: Scroll!
    
    required init?(coder: NSCoder) { nil }
    required init() {
        super.init()
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let text = Text(.Fixed(), Active())
        text.setAccessibilityLabel(.key("Note"))
        text.font = NSFont(name: "Times New Roman", size: 18)
        (text.textStorage as! Storage).fonts = [.plain: (.systemFont(ofSize: 18, weight: .regular), .white),
                                               .emoji: (NSFont(name: "Times New Roman", size: 40)!, .white),
                                               .bold: (.systemFont(ofSize: 28, weight: .bold), NSColor(named: "haze")!),
                                               .tag: (.systemFont(ofSize: 16, weight: .bold), NSColor(named: "haze")!)]
        text.tab = true
        text.intro = true
        (text.layoutManager as! Layout).owns = true
        text.delegate = self
        scroll.add(text)
        self.text = text

        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        scroll.right.constraint(equalTo: rightAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: bottomAnchor).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: text.bottomAnchor, constant: 30).isActive = true
        
        text.topAnchor.constraint(equalTo: scroll.top, constant: 20).isActive = true
        text.leftAnchor.constraint(greaterThanOrEqualTo: scroll.left, constant: 30).isActive = true
        text.rightAnchor.constraint(lessThanOrEqualTo: scroll.right, constant: -30).isActive = true
        text.widthAnchor.constraint(lessThanOrEqualToConstant: 900).isActive = true
        text.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor).isActive = true
        text.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
        
        let width = text.widthAnchor.constraint(equalToConstant: 900)
        width.priority = .defaultLow
        width.isActive = true

        refresh()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.text.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
            self.window?.makeFirstResponder(self.text)
        }
    }
    
    func textDidEndEditing(_: Notification) {
        app.session.content(app.project!, list: 0, card: 0, content: text.string)
    }
    
    override func mouseUp(with: NSEvent) {
        if window!.firstResponder != text && !text.frame.contains(convert(with.locationInWindow, from: nil)) && with.clickCount == 1 {
            window?.makeFirstResponder(text)
        }
        super.mouseUp(with: with)
    }
    
    override func refresh() {
        text.string = app.session.content(app.project!, list: 0, card: 0)
    }
    
    override func found(_ ranges: [(Int, Int, NSRange)]) {
        if ranges.isEmpty {
            text.setSelectedRange(.init())
        } else {
            text.setSelectedRanges(ranges.map { $0.2 as NSValue }, affinity: .downstream, stillSelecting: true)
        }
    }
    
    override func select(_ list: Int, _ card: Int, _ range: NSRange) {
        var frame = scroll.contentView.convert(text.layoutManager!.boundingRect(forGlyphRange: range, in: text.textContainer!), from: text)
        frame.origin.x -= (bounds.width - frame.size.width) / 2
        frame.origin.y -= (bounds.height / 2) - frame.size.height
        frame.size.width = bounds.width
        frame.size.height = bounds.height
        text.showFindIndicator(for: range)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.4
            $0.allowsImplicitAnimation = true
            scroll.contentView.scrollToVisible(frame)
        }
    }
}
