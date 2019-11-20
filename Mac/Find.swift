import AppKit

final class Find: NSView, NSTextViewDelegate {
    weak var view: View?
    var filter: String { text.string }
    private weak var text: Text!
    private weak var cancel: Image!
    private weak var base: NSView!
    private weak var width: NSLayoutConstraint!
    private weak var left: NSLayoutConstraint!
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let icon = Image("magnifier")
        addSubview(icon)
        
        let cancel = Image("clear")
        cancel.isHidden = true
        addSubview(cancel)
        self.cancel = cancel
        
        let base = NSView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.wantsLayer = true
        base.layer!.cornerRadius = 16
        base.layer!.borderWidth = 0
        base.layer!.borderColor = NSColor(named: "haze")!.cgColor
        addSubview(base)
        self.base = base
        
        let text = Text(.Fixed(), Block())
        text.setAccessibilityLabel(.key("Search"))
        text.font = NSFont(name: "Times New Roman", size: 14)
        (text.textStorage as! Storage).fonts = [.plain: (.systemFont(ofSize: 14, weight: .light), .white),
                                               .emoji: (NSFont(name: "Times New Roman", size: 14)!, .white),
                                               .bold: (.systemFont(ofSize: 14, weight: .light), NSColor(named: "haze")!),
                                               .tag: (.systemFont(ofSize: 14, weight: .light), NSColor(named: "haze")!)]
        text.textContainer!.maximumNumberOfLines = 1
        text.delegate = self
        base.addSubview(text)
        self.text = text
        
        icon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        icon.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 10).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        cancel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        cancel.rightAnchor.constraint(equalTo: base.rightAnchor, constant: -8).isActive = true
        cancel.widthAnchor.constraint(equalToConstant: 20).isActive = true
        cancel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        base.rightAnchor.constraint(equalTo: text.rightAnchor, constant: 14).isActive = true
        base.heightAnchor.constraint(equalToConstant: 32).isActive = true
        base.centerYAnchor.constraint(equalTo: text.centerYAnchor).isActive = true
        left = base.leftAnchor.constraint(equalTo: leftAnchor, constant: 160)
        left.isActive = true
        
        text.centerYAnchor.constraint(equalTo: icon.centerYAnchor).isActive = true
        text.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 20).isActive = true
        width = text.widthAnchor.constraint(equalToConstant: 20)
        width.isActive = true
        
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        widthAnchor.constraint(equalToConstant: 240).isActive = true
    }
    
    override func mouseUp(with: NSEvent) {
        if with.clickCount == 1 && bounds.contains(convert(with.locationInWindow, from: nil)) {
            if cancel.frame.contains(convert(with.locationInWindow, from: nil)) {
                text.string = ""
                update()
            }
            if window?.firstResponder != text {
                show()
            }
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
        update()
    }
    
    func start() {
        show()
    }
    
    func clear() {
        text.string = ""
        hide()
    }
    
    private func show() {
        text.edit.click()
        window!.makeFirstResponder(text)
        text.setSelectedRange(.init(location: 0, length: text.string.count))
        base.layer!.borderWidth = 2
        animate(150, 0)
        cancel.isHidden = false
    }
    
    private func hide() {
        cancel.isHidden = true
        animate(20, 190)
    }
    
    private func animate(_ _width: CGFloat, _ _left: CGFloat) {
        left.constant = _left
        width.constant = _width
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.4
            $0.allowsImplicitAnimation = true
            layoutSubtreeIfNeeded()
        }
    }
    
    private func update() {
        if let project = app.project {
            app.session.search(project, string: text.string) { [weak self] in
                self?.view?.found($0)
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.view?.refresh()
            }
        }
    }
}
