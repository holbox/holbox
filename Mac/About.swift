import AppKit

final class About: Window.Modal {
    init() {
        super.init(440, 520)
        
        let logo = Image("logo")
        logo.imageScaling = .scaleProportionallyDown
        contentView!.addSubview(logo)
        
        let title = Label([(.key("About.title"), 16, .bold, .white),
                           (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String, 16, .light, .white)])
        contentView!.addSubview(title)
        
        let _done = Control(.key("More.done"), self, #selector(close), NSColor(named: "haze")!.cgColor, .black)
        contentView!.addSubview(_done)
        
        var top: NSLayoutYAxisAnchor?
        (0 ..< 5).forEach {
            let item = Item(.key("About.options.\($0)"), index: $0, .medium, 16, .init(white: 0.8, alpha: 1), self, #selector(option(_:)))
            contentView!.addSubview(item)
            
            item.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
            item.widthAnchor.constraint(equalToConstant: 280).isActive = true
            
            if top == nil {
                item.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 20).isActive = true
            } else {
                let border = Border()
                border.layer!.backgroundColor = NSColor(white: 0, alpha: 0.5).cgColor
                contentView!.addSubview(border)
                
                border.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
                border.widthAnchor.constraint(equalToConstant: 240).isActive = true
                border.topAnchor.constraint(equalTo: top!).isActive = true
                
                item.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
            }
            
            top = item.bottomAnchor
        }
        
        logo.widthAnchor.constraint(equalToConstant: 70).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 70).isActive = true
        logo.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 60).isActive = true
        logo.rightAnchor.constraint(equalTo: contentView!.centerXAnchor, constant: 5).isActive = true
        
        title.centerYAnchor.constraint(equalTo: logo.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: logo.rightAnchor).isActive = true
        
        _done.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -50).isActive = true
        _done.widthAnchor.constraint(equalToConstant: 140).isActive = true
        _done.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
    }
    
    @objc private func option(_ item: Item) {
        switch item.index {
        case 0: app.runModal(for: Privacy())
        case 1: NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.notifications?holbox")!)
        case 2:
            let service = NSSharingService(named: .composeEmail)
            service!.recipients = ["holbox@iturbi.de"]
            service!.subject = .key("About.subject")
            service!.perform(withItems: [String.key("About.body")])
        case 3: NSWorkspace.shared.open(URL(string: "https://twitter.com/holboxapp")!)
        case 4: NSWorkspace.shared.open(URL(string: "itms-apps://itunes.apple.com/\(Locale.current.regionCode!.lowercased())/app/holbox/id1483735368")!)
        default: break
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak item] in
            item?.selected = false
        }
    }
}
