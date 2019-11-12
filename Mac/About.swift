import AppKit

final class About: Window.Modal {
    init() {
        super.init(240, 230)
        
        let logo = Image("logo")
        logo.imageScaling = .scaleProportionallyDown
        contentView!.addSubview(logo)
        
        let title = Label([(.key("About.title") + "\n", 16, .bold, .white),
                           (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String, 16, .light, .white)])
        contentView!.addSubview(title)
        
        let _done = Control(.key("About.done"), self, #selector(close), .clear, NSColor(named: "haze")!)
        contentView!.addSubview(_done)
        
        logo.widthAnchor.constraint(equalToConstant: 70).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 70).isActive = true
        logo.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 60).isActive = true
        logo.rightAnchor.constraint(equalTo: contentView!.centerXAnchor, constant: 5).isActive = true
        
        title.centerYAnchor.constraint(equalTo: logo.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: logo.rightAnchor).isActive = true
        
        _done.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -40).isActive = true
        _done.widthAnchor.constraint(equalToConstant: 140).isActive = true
        _done.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
    }
}
