import AppKit

final class Find: NSView, NSTextViewDelegate {
    private weak var text: Text!
    private weak var base: NSView!
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let icon = Image("magnifier")
        addSubview(icon)
        
        let base = NSView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.wantsLayer = true
        base.layer!.cornerRadius = 18
        base.layer!.borderWidth = 0
        base.layer!.borderColor = NSColor(named: "haze")!.cgColor
        addSubview(base)
        self.base = base
        
        let text = Text(.Fixed(), Active())
        text.setAccessibilityLabel(.key("Search"))
        text.font = NSFont(name: "Times New Roman", size: 14)
        (text.textStorage as! Storage).fonts = [.plain: (.systemFont(ofSize: 14, weight: .light), .white),
                                               .emoji: (NSFont(name: "Times New Roman", size: 14)!, .white),
                                               .bold: (.systemFont(ofSize: 14, weight: .light), NSColor(named: "haze")!),
                                               .tag: (.systemFont(ofSize: 14, weight: .light), NSColor(named: "haze")!)]
        text.textContainer!.maximumNumberOfLines = 1
        text.delegate = self
        addSubview(text)
        self.text = text
        
        icon.topAnchor.constraint(equalTo: topAnchor, constant: 30).isActive = true
        icon.leftAnchor.constraint(equalTo: leftAnchor, constant: 40).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        base.leftAnchor.constraint(equalTo: text.leftAnchor, constant: -2).isActive = true
        base.rightAnchor.constraint(equalTo: text.rightAnchor, constant: 2).isActive = true
        base.heightAnchor.constraint(equalToConstant: 36).isActive = true
        base.centerYAnchor.constraint(equalTo: text.centerYAnchor).isActive = true
        
        text.centerYAnchor.constraint(equalTo: icon.centerYAnchor).isActive = true
        text.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 10).isActive = true
        text.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
        heightAnchor.constraint(equalToConstant: 70).isActive = true
        widthAnchor.constraint(equalToConstant: 500).isActive = true
    }
    
    func textDidBeginEditing(_: Notification) {
        base.layer!.borderWidth = 2
    }
    
    func textDidEndEditing(_: Notification) {
        base.layer!.borderWidth = 0
    }
}
