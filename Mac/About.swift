import AppKit

final class About: Modal {
    init() {
        super.init(240, 170)
        let logo = Image("logo")
        logo.imageScaling = .scaleProportionallyDown
        contentView!.addSubview(logo)
        
        let title = Label([(.key("About.title") + "\n", .bold(16), .white),
                           (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String, .light(16), .white)])
        contentView!.addSubview(title)
        
        logo.widthAnchor.constraint(equalToConstant: 60).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 60).isActive = true
        logo.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 60).isActive = true
        logo.rightAnchor.constraint(equalTo: contentView!.centerXAnchor, constant: 5).isActive = true
        
        title.centerYAnchor.constraint(equalTo: logo.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: logo.rightAnchor, constant: 10).isActive = true
        
        addClose()
    }
}
