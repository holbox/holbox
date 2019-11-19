import AppKit

final class Settings: Window.Modal {
    private final class Option: Item {
        private let index: Int
        private weak var settings: Settings?
        
        required init?(coder: NSCoder) { nil }
        init(_ index: Int, settings: Settings) {
            self.index = index
            self.settings = settings
            super.init(settings, title: .key("Settings.options.\(index)"))
            setAccessibilityRole(.button)
        }
        
        override func click() {
            settings?.option(index)
        }
    }
    
    private final class Check: Item {
        var value = false {
            didSet {
                circle.layer!.backgroundColor = value ? NSColor(named: "haze")!.cgColor : .clear
                check.alphaValue = value ? 1 : 0
            }
        }
        
        private weak var settings: Settings?
        private weak var circle: NSView!
        private weak var check: Image!
        override func accessibilityValue() -> Any? { value }
        
        required init?(coder: NSCoder) { nil }
        init(_ title: String, settings: Settings) {
            self.settings = settings
            super.init(settings, title: title)
            setAccessibilityRole(.button)
            
            let circle = NSView()
            circle.translatesAutoresizingMaskIntoConstraints = false
            circle.wantsLayer = true
            circle.layer!.cornerRadius = 12
            circle.layer!.borderWidth = 1
            circle.layer!.borderColor = NSColor(named: "haze")!.cgColor
            addSubview(circle)
            self.circle = circle
            
            let check = Image("check")
            addSubview(check)
            self.check = check
            
            circle.widthAnchor.constraint(equalToConstant: 24).isActive = true
            circle.heightAnchor.constraint(equalToConstant: 24).isActive = true
            circle.centerYAnchor.constraint(lessThanOrEqualTo: centerYAnchor).isActive = true
            circle.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
            
            check.widthAnchor.constraint(equalToConstant: 24).isActive = true
            check.heightAnchor.constraint(equalToConstant: 24).isActive = true
            check.centerYAnchor.constraint(lessThanOrEqualTo: circle.centerYAnchor, constant: 1).isActive = true
            check.centerXAnchor.constraint(lessThanOrEqualTo: circle.centerXAnchor).isActive = true
        }
        
        override func click() {
            settings?.check(self)
        }
    }
    
    private class Item: NSView {
        private weak var settings: Settings?
        override var mouseDownCanMoveWindow: Bool { false }
        
        required init?(coder: NSCoder) { nil }
        init(_ settings: Settings, title: String) {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            setAccessibilityElement(true)
            setAccessibilityLabel(title)
            wantsLayer = true
            layer!.cornerRadius = 4
            self.settings = settings
            
            let label = Label(title, 16, .regular, NSColor(named: "haze")!)
            addSubview(label)
            
            heightAnchor.constraint(equalToConstant: 40).isActive = true
            widthAnchor.constraint(equalToConstant: 340).isActive = true
            
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
            label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
            
            addTrackingArea(.init(rect: .zero, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self))
        }
        
        override func resetCursorRects() { addCursorRect(bounds, cursor: .pointingHand) }
        
        override func mouseEntered(with: NSEvent) {
            super.mouseEntered(with: with)
            NSAnimationContext.runAnimationGroup {
                $0.duration = 0.4
                $0.allowsImplicitAnimation = true
                layer!.backgroundColor = NSColor(named: "haze")!.withAlphaComponent(0.3).cgColor
            }
        }
        
        override func mouseExited(with: NSEvent) {
            super.mouseExited(with: with)
            NSAnimationContext.runAnimationGroup {
                $0.duration = 0.5
                $0.allowsImplicitAnimation = true
                layer!.backgroundColor = .clear
            }
        }
        
        override func mouseDown(with: NSEvent) {
            alphaValue = 0.4
            super.mouseDown(with: with)
        }
        
        override func mouseUp(with: NSEvent) {
            if bounds.contains(convert(with.locationInWindow, from: nil)) && with.clickCount == 1 {
                click()
            }
            alphaValue = 1
            super.mouseUp(with: with)
        }
        
        func click() { }
    }
    
    init() {
        super.init(440, 500)
        let title = Label(.key("Settings.title"), 20, .bold, NSColor(named: "haze")!)
        contentView!.addSubview(title)
        
        let _done = Control(.key("Settings.done"), self, #selector(close), .clear, NSColor(named: "haze")!)
        contentView!.addSubview(_done)
        
        let _spell = Check(.key("Settings.spell"), settings: self)
        _spell.value = app.session.spell
        contentView!.addSubview(_spell)
        
        var top = _spell.bottomAnchor
        (0 ..< 5).forEach {
            let item = Option($0, settings: self)
            contentView!.addSubview(item)
            
            let border = Border()
            border.layer!.backgroundColor = NSColor(named: "haze")!.withAlphaComponent(0.2).cgColor
            contentView!.addSubview(border)
            
            item.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
            item.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 5).isActive = true
            
            border.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
            border.widthAnchor.constraint(equalToConstant: 340).isActive = true
            border.topAnchor.constraint(equalTo: top, constant: 5).isActive = true
            top = item.bottomAnchor
        }
        
        title.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 40).isActive = true
        title.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 50).isActive = true
        
        _spell.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 40).isActive = true
        _spell.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        
        _done.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -30).isActive = true
        _done.widthAnchor.constraint(equalToConstant: 140).isActive = true
        _done.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
    }
    
    private func option(_ index: Int) {
        switch index {
        case 0:
            app.runModal(for: Privacy())
        case 1:
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.notifications?holbox")!)
        case 2:
            let service = NSSharingService(named: .composeEmail)
            service!.recipients = ["holbox@iturbi.de"]
            service!.subject = .key("About.subject")
            service!.perform(withItems: [String.key("About.body")])
        case 3:
            NSWorkspace.shared.open(URL(string: "https://twitter.com/holboxapp")!)
        case 4:
            NSWorkspace.shared.open(URL(string: "itms-apps://itunes.apple.com/\(Locale.current.regionCode!.lowercased())/app/holbox/id1483735368")!)
        default: break
        }
    }
    
    @objc private func check(_ check: Check) {
        check.value.toggle()
        app.session.spell(check.value)
        app.main.refresh()
    }
}
