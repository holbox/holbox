import AppKit

final class About: Window.Modal {
    init() {
        super.init(400, 580)
        
        let logo = Image("logo")
        logo.imageScaling = .scaleProportionallyDown
        contentView!.addSubview(logo)
        
        let title = Label([(.key("About.title"), 20, .bold, .white), (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String, 20, .light, .white)])
        contentView!.addSubview(title)
        
        let options = Label(.key("About.options"), 24, .bold, .init(white: 1, alpha: 0.3))
        
        let _done = Control(.key("More.done"), self, #selector(close), NSColor(named: "haze")!.cgColor, .black)

        [options, _done].forEach {
            contentView!.addSubview($0)
            $0.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 200).isActive = true
        }
        
        var top: NSLayoutYAxisAnchor?
        (0 ..< 4).forEach {
            let item = Item(.key("About.options.\($0)"), index: $0, .light, self, #selector(option(_:)))
            contentView!.addSubview(item)
            
            item.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
            item.widthAnchor.constraint(equalToConstant: 240).isActive = true
            
            if top == nil {
                item.topAnchor.constraint(equalTo: options.bottomAnchor, constant: 10).isActive = true
            } else {
                let border = Border()
                border.alphaValue = 0.2
                contentView!.addSubview(border)
                
                border.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
                border.widthAnchor.constraint(equalToConstant: 200).isActive = true
                border.topAnchor.constraint(equalTo: top!).isActive = true
                
                item.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
            }
            
            top = item.bottomAnchor
        }
        
        logo.widthAnchor.constraint(equalToConstant: 70).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 70).isActive = true
        logo.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 60).isActive = true
        logo.rightAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        
        title.centerYAnchor.constraint(equalTo: logo.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: logo.rightAnchor, constant: 10).isActive = true
        
        options.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 50).isActive = true

        _done.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -40).isActive = true
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
        case 3: NSWorkspace.shared.open(URL(string: "itms-apps://itunes.apple.com/\(Locale.current.regionCode!.lowercased())/app/holbox/id1483735368")!)
        default: break
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak item] in
            item?.selected = false
        }
    }
}
