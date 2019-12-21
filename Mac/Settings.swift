import AppKit

final class Settings: Modal {
    init() {
        super.init(440, 400)
        let _spell = Option.Check(.key("Settings.spell"), settings: self)
        _spell.on = app.session.spell
        contentView!.addSubview(_spell)
        
        var top = _spell.bottomAnchor
        (0 ..< 5).forEach {
            let item = Option.Item($0, settings: self)
            contentView!.addSubview(item)
            
            let border = Border.horizontal(0.2)
            contentView!.addSubview(border)
            
            item.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
            item.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 5).isActive = true
            
            border.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
            border.widthAnchor.constraint(equalToConstant: 340).isActive = true
            border.topAnchor.constraint(equalTo: top, constant: 5).isActive = true
            top = item.bottomAnchor
        }
        
        _spell.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 50).isActive = true
        _spell.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        
        addClose()
    }
    
    func option(_ index: Int) {
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
    
    @objc func check(_ check: Option.Check) {
        check.on.toggle()
        app.session.spell(check.on)
        app.main.refresh()
    }
}
