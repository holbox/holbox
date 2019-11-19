import AppKit

final class Find: NSView, NSTextViewDelegate {
    weak var view: View?
    private weak var text: Text!
    private weak var base: NSView!
    private weak var width: NSLayoutConstraint!
    private weak var left: NSLayoutConstraint!
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let icon = Image("magnifier")
        addSubview(icon)
        
        let base = NSView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.wantsLayer = true
        base.layer!.cornerRadius = 16
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
        
        icon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        icon.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 10).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        base.rightAnchor.constraint(equalTo: text.rightAnchor, constant: 2).isActive = true
        base.heightAnchor.constraint(equalToConstant: 32).isActive = true
        base.centerYAnchor.constraint(equalTo: text.centerYAnchor).isActive = true
        left = base.leftAnchor.constraint(equalTo: leftAnchor, constant: 160)
        left.isActive = true
        
        text.centerYAnchor.constraint(equalTo: icon.centerYAnchor).isActive = true
        text.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: -10).isActive = true
        width = text.widthAnchor.constraint(equalToConstant: 20)
        width.isActive = true
        
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        widthAnchor.constraint(equalToConstant: 240).isActive = true
    }
    
    override func mouseUp(with: NSEvent) {
        if window?.firstResponder != text && bounds.contains(convert(with.locationInWindow, from: nil)) && with.clickCount == 1 {
            show()
        }
        super.mouseUp(with: with)
    }
    
    func textDidEndEditing(_: Notification) {
        base.layer!.borderWidth = 0
        if text.string.isEmpty {
            hide()
        }
    }
    
    func textDidChange(_: Notification) {
        app.session.search(app.project!, string: text.string) { [weak self] in
            self?.view?.found($0)
        }
    }
    
    func start() {
        show()
    }
    
    func clear() {
        text.string = ""
        hide()
    }
    
    private func show() {
        base.layer!.borderWidth = 2
        animate(160, 0) {
            self.window!.makeFirstResponder(self.text)
        }
    }
    
    private func hide() {
        animate(20, 190) { }
    }
    
    private func animate(_ _width: CGFloat, _ _left: CGFloat, completion: @escaping () -> Void) {
        width.constant = _width
        left.constant = _left
        NSAnimationContext.runAnimationGroup ({
            $0.duration = 0.4
            $0.allowsImplicitAnimation = true
            layoutSubtreeIfNeeded()
        }, completionHandler: completion)
    }
}
