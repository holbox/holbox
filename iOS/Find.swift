import UIKit

final class Find: UIView, UITextViewDelegate {
    weak var view: View?
    var filter: String { text.text }
    private weak var text: Text!
    private weak var cancel: Image!
    private weak var icon: Image!
    private weak var _counter: Label!
    private weak var _next: Image!
    private weak var _prev: Image!
    private weak var base: UIView!
    private weak var width: NSLayoutConstraint!
    private var index = 0
    private var ranges = [(Int, Int, NSRange)]() {
        didSet {
            index = 0
            _counter.text = text.text.isEmpty ? "" : "\(ranges.count) " + .key("Find.matches")
        }
    }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        
        let icon = Image("magnifier")
        addSubview(icon)
        self.icon = icon
        
        let cancel = Image("clear")
        cancel.alpha = 0
        addSubview(cancel)
        self.cancel = cancel
        
        let base = UIView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.layer.cornerRadius = 17
        base.layer.borderWidth = 0
        base.layer.borderColor = UIColor(named: "haze")!.cgColor
        addSubview(base)
        self.base = base
        
        let text = Text(.init())
        text.textContainerInset = .init(top: 15, left: 0, bottom: 15, right: 0)
        text.isUserInteractionEnabled = false
        text.accessibilityLabel = .key("Search")
        text.font = .systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 14), weight: .regular)
//        (text.textStorage as! Storage).fonts = [
//            .plain: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 14), weight: .regular), .white),
//            .emoji: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 14), weight: .regular), .white),
//            .bold: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 14), weight: .regular), UIColor(named: "haze")!),
//            .tag: (.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 14), weight: .regular), UIColor(named: "haze")!)]
        text.textContainer.maximumNumberOfLines = 1
        (text.layoutManager as! Layout).padding = 1
        text.delegate = self
        base.addSubview(text)
        self.text = text
        
        let _counter = Label("", 12, .light, UIColor(named: "haze")!)
        addSubview(_counter)
        self._counter = _counter
        
        let _next = Image("next")
        _next.alpha = 0
        addSubview(_next)
        self._next = _next
        
        let _prev = Image("prev")
        _prev.alpha = 0
        addSubview(_prev)
        self._prev = _prev
        
        heightAnchor.constraint(equalToConstant: 60).isActive = true
        width = widthAnchor.constraint(equalToConstant: 60)
        width.isActive = true
        
        icon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        icon.leftAnchor.constraint(equalTo: base.leftAnchor, constant: -10).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 60).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        cancel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        cancel.rightAnchor.constraint(equalTo: base.rightAnchor, constant: 10).isActive = true
        cancel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        cancel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        base.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        base.rightAnchor.constraint(equalTo: text.rightAnchor, constant: 30).isActive = true
        base.leftAnchor.constraint(equalTo: text.leftAnchor, constant: -30).isActive = true
        base.heightAnchor.constraint(equalToConstant: 34).isActive = true
        base.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        text.centerYAnchor.constraint(equalTo: base.centerYAnchor).isActive = true
        text.height = text.heightAnchor.constraint(equalToConstant: ceil(text.layoutManager.usedRect(for: text.textContainer).size.height) + 30)
        text.width = text.widthAnchor.constraint(equalToConstant: 0)
        
        _counter.centerXAnchor.constraint(equalTo: _prev.rightAnchor).isActive = true
        _counter.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
        
        _next.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        _next.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _next.heightAnchor.constraint(equalToConstant: 60).isActive = true
        _next.rightAnchor.constraint(equalTo: rightAnchor, constant: -170).isActive = true
        
        _prev.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        _prev.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _prev.heightAnchor.constraint(equalToConstant: 60).isActive = true
        _prev.rightAnchor.constraint(equalTo: _next.leftAnchor).isActive = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with: UIEvent?) {
        let location = touches.first!.location(in: self)
        if bounds.contains(location) {
            if !text.isUserInteractionEnabled {
                show()
            }
            if cancel.frame.contains(location) {
                if !text.isFirstResponder {
                    text.becomeFirstResponder()
                }
                if text.text != "" {
                    text.text = ""
                    update()
                } else {
                    text.resignFirstResponder()
                }
            } else if _next.frame.contains(location) {
                next()
            } else if _prev.frame.contains(location) {
                prev()
            }
        }
        super.touchesEnded(touches, with: with)
    }
    
    func textView(_: UITextView, shouldChangeTextIn: NSRange, replacementText: String) -> Bool {
        if replacementText == "\n" {
            text.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidEndEditing(_: UITextView) {
        if text.text.isEmpty {
            hide()
        }
    }
    
    func textViewDidChange(_: UITextView) {
        update()
    }
    
    func search(_ string: String) {
        show()
        text.text = string
        update()
    }
    
    func next() {
        if index < ranges.count - 1 {
            index += 1
        } else {
            index = 0
        }
        send()
        UIView.animate(withDuration: 0.3, animations: {
            self._next.alpha = 0
        }) { _ in
            self._next.alpha = 1
        }
    }
    
    func prev() {
        if index > 0 {
            index -= 1
        } else {
            index = ranges.count - 1
        }
        send()
        UIView.animate(withDuration: 0.3, animations: {
            self._prev.alpha = 0
        }) { _ in
            self._prev.alpha = 1
        }
    }
    
    func clear() {
        text.text = ""
        hide()
    }
    
    private func show() {
        text.isUserInteractionEnabled = true
        text.selectedRange = .init(location: 0, length: text.text.count)
        text.becomeFirstResponder()
        base.layer.borderWidth = 1
        width.constant = app.project == nil ? 170 : min(app.main.bounds.width, app.main.bounds.height) - 70
        text.width.constant = 110
        if text.text.isEmpty {
            _counter.text = ""
        }
        _counter.alpha = 1
        UIView.animate(withDuration: 0.35) {
            self.cancel.alpha = 1
            self._next.alpha = 1
            self._prev.alpha = 1
            self.superview!.layoutIfNeeded()
        }
    }
    
    private func hide() {
        text.isUserInteractionEnabled = false
        base.layer.borderWidth = 0
        width.constant = 60
        text.width.constant = 0
        _counter.text = ""
        _counter.alpha = 0
        ranges = []
        UIView.animate(withDuration: 0.35) {
            self.cancel.alpha = 0
            self._next.alpha = 0
            self._prev.alpha = 0
            self.superview!.layoutIfNeeded()
        }
    }
    
    private func update() {
        if let project = app.project {
            app.session.search(project, string: text.text) { [weak self] in
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
