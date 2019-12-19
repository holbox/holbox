import AppKit

final class Find: NSView, NSTextViewDelegate {
    weak var view: View?
    var filter: String { text.string }
    private weak var text: Text!
    private weak var cancel: Image!
    private weak var _counter: Label!
    private weak var _next: Image!
    private weak var _prev: Image!
    private weak var base: NSView!
    private weak var width: NSLayoutConstraint!
    private weak var baseWidth: NSLayoutConstraint!
    private var index = 0
    private var ranges = [(Int, Int, NSRange)]() {
        didSet {
            index = 0
            _counter.stringValue = text.string.isEmpty ? "" : "\(ranges.count) " + .key("Find.matches")
        }
    }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let icon = Image("magnifier")
        addSubview(icon)
        
        let cancel = Image("clear")
        cancel.alphaValue = 0
        addSubview(cancel)
        self.cancel = cancel
        
        let base = NSView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.wantsLayer = true
        base.layer!.cornerRadius = 16
        base.layer!.borderWidth = 0
        base.layer!.borderColor = .haze()
        addSubview(base)
        self.base = base
        
        let text = Text(.Fix(), Block(), storage: .init())
        text.textContainerInset.width = 10
        text.textContainerInset.height = 10
        text.setAccessibilityLabel(.key("Search"))
        text.font = .init(light: 14)
        text.textColor = .white
        text.textContainer!.maximumNumberOfLines = 1
        (text.layoutManager as! Layout).padding = 1
        text.clear = true
        text.delegate = self
        base.addSubview(text)
        self.text = text
        
        let _counter = Label("", .init(regular: 12), .haze())
        addSubview(_counter)
        self._counter = _counter
        
        let _next = Image("next")
        _next.alphaValue = 0
        addSubview(_next)
        self._next = _next
        
        let _prev = Image("prev")
        _prev.alphaValue = 0
        addSubview(_prev)
        self._prev = _prev
        
        heightAnchor.constraint(equalToConstant: 51).isActive = true
        width = widthAnchor.constraint(equalToConstant: 40)
        width.isActive = true
        
        icon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        icon.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 10).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        cancel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        cancel.rightAnchor.constraint(equalTo: base.rightAnchor, constant: -5).isActive = true
        cancel.widthAnchor.constraint(equalToConstant: 25).isActive = true
        cancel.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        base.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        base.heightAnchor.constraint(equalToConstant: 32).isActive = true
        base.centerYAnchor.constraint(equalTo: text.centerYAnchor).isActive = true
        baseWidth = base.widthAnchor.constraint(equalToConstant: 40)
        baseWidth.isActive = true
        
        text.centerYAnchor.constraint(equalTo: icon.centerYAnchor).isActive = true
        text.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 20).isActive = true
        text.rightAnchor.constraint(equalTo: base.rightAnchor, constant: -10).isActive = true
        
        _counter.rightAnchor.constraint(equalTo: rightAnchor, constant: -265).isActive = true
        _counter.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 1).isActive = true
        
        _next.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 1).isActive = true
        _next.widthAnchor.constraint(equalToConstant: 25).isActive = true
        _next.heightAnchor.constraint(equalToConstant: 35).isActive = true
        _next.leftAnchor.constraint(equalTo: _prev.rightAnchor).isActive = true
        
        _prev.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 1).isActive = true
        _prev.widthAnchor.constraint(equalToConstant: 25).isActive = true
        _prev.heightAnchor.constraint(equalToConstant: 35).isActive = true
        _prev.leftAnchor.constraint(equalTo: _counter.rightAnchor, constant: 5).isActive = true
    }
    
    override func mouseUp(with: NSEvent) {
        let location = convert(with.locationInWindow, from: nil)
        if with.clickCount == 1 && bounds.contains(location) {
            if window!.firstResponder != text {
                show()
            }
            if cancel.frame.contains(location) {
                if text.string != "" {
                    text.string = ""
                    update()
                } else if window!.firstResponder == text {
                    window!.makeFirstResponder(self)
                }
            } else if _next.frame.contains(location) {
                next()
            } else if _prev.frame.contains(location) {
                prev()
            }
        }
    }
    
    func textDidEndEditing(_: Notification) {
        if text.string.isEmpty {
            hide()
        }
    }
    
    func textDidChange(_: Notification) {
        update()
    }
    
    func search(_ string: String) {
        show()
        text.string = string
        update()
    }
    
    func next() {
        if index < ranges.count - 1 {
            index += 1
        } else {
            index = 0
        }
        send()
        NSAnimationContext.runAnimationGroup ({
            $0.duration = 0.2
            $0.allowsImplicitAnimation = true
            _next.alphaValue = 0
        }) { [weak self] in
            self?._next.alphaValue = 1
        }
    }
    
    func prev() {
        if index > 0 {
            index -= 1
        } else {
            index = ranges.count - 1
        }
        send()
        NSAnimationContext.runAnimationGroup ({
            $0.duration = 0.2
            $0.allowsImplicitAnimation = true
            _prev.alphaValue = 0
        }) { [weak self] in
            self?._prev.alphaValue = 1
        }
    }
    
    func clear() {
        text.string = ""
        hide()
    }
    
    func show() {
        text.edit.click()
        window!.makeFirstResponder(text)
        text.setSelectedRange(.init(location: 0, length: text.string.count))
        base.layer!.borderWidth = 1
        width.constant = app.project == nil ? 202 : 345
        baseWidth.constant = 200
        if text.string.isEmpty {
            _counter.stringValue = ""
        }
        _counter.alphaValue = 1
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.4
            $0.allowsImplicitAnimation = true
            cancel.alphaValue = 1
            _next.alphaValue = 1
            _prev.alphaValue = 1
            layoutSubtreeIfNeeded()
        }
    }
    
    private func hide() {
        width.constant = 40
        baseWidth.constant = 40
        base.layer!.borderWidth = 0
        _counter.stringValue = ""
        _counter.alphaValue = 0
        ranges = []
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.4
            $0.allowsImplicitAnimation = true
            cancel.alphaValue = 0
            _next.alphaValue = 0
            _prev.alphaValue = 0
            layoutSubtreeIfNeeded()
        }
    }
    
    private func update() {
        if let project = app.project {
            app.session.search(project, string: text.string) { [weak self] in
                self?.ranges = $0
                self?.view?.found($0)
                self?.send()
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.view?.refresh()
            }
        }
    }
    
    private func send() {
        guard !ranges.isEmpty else { return }
        view?.select(ranges[index].0, ranges[index].1, ranges[index].2)
    }
}
