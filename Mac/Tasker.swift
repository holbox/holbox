import AppKit

final class Tasker: NSView, NSTextViewDelegate {
    private weak var todo: Todo!
    private weak var text: Text!
    private weak var _clear: Image!
    private weak var _add: Image!
    private weak var width: NSLayoutConstraint! {
        didSet {
            oldValue.isActive = false
            width.isActive = true
        }
    }
    
    private weak var height: NSLayoutConstraint! {
        didSet {
            oldValue.isActive = false
            height.isActive = true
        }
    }
    
    required init?(coder: NSCoder) { nil }
    init(_ todo: Todo) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer!.backgroundColor = .haze()
        layer!.borderWidth = 1
        layer!.borderColor = .black
        layer!.cornerRadius = 20
        self.todo = todo
        
        let text = Text(.Fix(), Active(), storage: Storage())
        text.textContainerInset.width = 20
        text.textContainerInset.height = 20
        text.setAccessibilityLabel(.key("Task"))
        text.insertionPointColor = .black
        text.selectedTextAttributes = [.backgroundColor: NSColor(white: 0, alpha: 0.2)]
        text.font = .regular(14)
        (text.textStorage as! Storage).attributes = [.plain: [.font: NSFont.regular(14), .foregroundColor: NSColor.black],
                                                     .emoji: [.font: NSFont.regular(24)],
                                                     .bold: [.font: NSFont.bold(22), .foregroundColor: NSColor.black],
                                                     .tag: [.font: NSFont.medium(14), .foregroundColor: NSColor.black]]
        text.intro = true
        text.tab = true
        (text.layoutManager as! Layout).padding = 2
        text.delegate = self
        text.isHidden = true
        addSubview(text)
        self.text = text
        
        let _add = Image("plus")
        addSubview(_add)
        self._add = _add
        
        let _clear = Image("clear", tint: .black)
        _clear.isHidden = true
        addSubview(_clear)
        self._clear = _clear
        
        width = widthAnchor.constraint(equalToConstant: 40)
        width.isActive = true
        height = heightAnchor.constraint(equalToConstant: 40)
        height.isActive = true
        
        text.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30).isActive = true
        text.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        text.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        _add.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        _add.widthAnchor.constraint(equalToConstant: 30).isActive = true
        _add.heightAnchor.constraint(equalToConstant: 30).isActive = true
        _add.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        
        _clear.leftAnchor.constraint(equalTo: leftAnchor, constant: 5).isActive = true
        _clear.widthAnchor.constraint(equalToConstant: 30).isActive = true
        _clear.heightAnchor.constraint(equalToConstant: 30).isActive = true
        _clear.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
    }
    
    override func keyDown(with: NSEvent) {
        switch with.keyCode {
        case 36:
            if with.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command {
                if !_clear.isHidden {
                    confirm()
                } else {
                    add()
                }
            } else {
                add()
            }
        case 48:
            add()
        case 53:
            clear()
        default: super.keyDown(with: with)
        }
    }
    
    override func mouseDown(with: NSEvent) {
        if _clear.isHidden && with.clickCount == 1 {
            add()
        }
    }
    
    override func mouseUp(with: NSEvent) {
        if !_clear.isHidden && with.clickCount == 1 {
            if _clear.frame.contains(convert(with.locationInWindow, from: nil)) {
                clear()
            } else if _add.frame.contains(convert(with.locationInWindow, from: nil)) {
                confirm()
            } else if window!.firstResponder != text {
                window!.makeFirstResponder(text)
            }
        }
    }
    
    func add() {
        width = widthAnchor.constraint(equalTo: todo.scroll.width, constant: -80)
        height = topAnchor.constraint(equalTo: text.topAnchor)
        _clear.isHidden = false
        text.isHidden = false
        text.setSelectedRange(.init(location: text.string.count, length: 0))
        window!.makeFirstResponder(text)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            layer!.cornerRadius = 6
            layoutSubtreeIfNeeded()
        }
    }
    
    private func confirm() {
        if !text.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            app.session.add(app.project, list: 0, content: text.string)
            app.alert(.key("Task"), message: text.string)
            NSAnimationContext.runAnimationGroup {
                $0.duration = 0.3
                $0.allowsImplicitAnimation = true
                todo.scroll.contentView.scroll(to: .zero)
            }
            todo.refresh()
            todo.scroll.documentView!.layoutSubtreeIfNeeded()
            clear()
        } else {
            add()
        }
    }
    
    private func clear() {
        window!.makeFirstResponder(todo)
        width = widthAnchor.constraint(equalToConstant: 40)
        height = heightAnchor.constraint(equalToConstant: 40)
        _clear.isHidden = true
        text.isHidden = true
        text.string = ""
        text.needsLayout = true
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.35
            $0.allowsImplicitAnimation = true
            layer!.cornerRadius = 20
            layoutSubtreeIfNeeded()
        }
    }
}
