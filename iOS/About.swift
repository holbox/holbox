import UIKit
import MessageUI

final class About: Modal, MFMailComposeViewControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scroll = Scroll()
        view.addSubview(scroll)
        
        let logo = Image("logo")
        logo.contentMode = .scaleAspectFit
        scroll.add(logo)
        
        let title = Label([(.key("About.title"), 16, .bold, .white),
        (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String, 16, .light, .white)])
        scroll.add(title)
        
        let settings = Label(.key("More.title"), 22, .bold, .init(white: 1, alpha: 0.2))
        scroll.add(settings)
        
        let _spell = Check(.key("More.spell"), target: self, action: #selector(spell(_:)))
        _spell.on = app.session.spell
        scroll.add(_spell)
        
        var top: NSLayoutYAxisAnchor?
        (0 ..< 5).forEach {
            let item = Item(.key("About.options.\($0)"), index: $0, .medium, 16, .init(white: 0.8, alpha: 1), self, #selector(option(_:)))
            scroll.add(item)
            
            item.leftAnchor.constraint(equalTo: scroll.left, constant: 23).isActive = true
            item.widthAnchor.constraint(equalTo: scroll.width, constant: -46).isActive = true
            
            if top == nil {
                item.topAnchor.constraint(equalTo: _spell.bottomAnchor, constant: 30).isActive = true
            } else {
                let border = Border()
                border.backgroundColor = .init(white: 0, alpha: 0.5)
                scroll.add(border)
                
                border.leftAnchor.constraint(equalTo: scroll.left, constant: 43).isActive = true
                border.rightAnchor.constraint(equalTo: scroll.right, constant: -43).isActive = true
                border.topAnchor.constraint(equalTo: top!).isActive = true
                
                item.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
            }
            
            top = item.bottomAnchor
        }
        
        let done = Control(.key("More.done"), self, #selector(close), UIColor(named: "haze")!, .black)
        scroll.add(done)
        
        scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1).isActive = true
        scroll.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        scroll.bottom.constraint(equalTo: done.bottomAnchor, constant: 30).isActive = true
        
        logo.widthAnchor.constraint(equalToConstant: 70).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 70).isActive = true
        logo.topAnchor.constraint(equalTo: scroll.top, constant: 60).isActive = true
        logo.rightAnchor.constraint(equalTo: scroll.centerX, constant: 5).isActive = true
        
        title.centerYAnchor.constraint(equalTo: logo.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: logo.rightAnchor).isActive = true
        
        settings.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 70).isActive = true
        settings.leftAnchor.constraint(equalTo: scroll.left, constant: 43).isActive = true
        
        _spell.topAnchor.constraint(equalTo: settings.bottomAnchor, constant: 10).isActive = true
        _spell.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
        
        done.topAnchor.constraint(equalTo: top!, constant: 50).isActive = true
        done.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
        done.widthAnchor.constraint(equalToConstant: 140).isActive = true
    }
    
    func mailComposeController(_: MFMailComposeViewController, didFinishWith: MFMailComposeResult, error: Error?) { dismiss(animated: true) }
    
    @objc private func spell(_ check: Check) {
        app.session.spell(check.on)
    }
    
    @objc private func option(_ item: Item) {
        switch item.index {
        case 0: present(Privacy(), animated: true)
        case 1: UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        case 2:
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients(["holbox@iturbi.de"])
                mail.setSubject(.key("About.subject"))
                mail.setMessageBody(.key("About.body"), isHTML: false)
                present(mail, animated: true)
            } else {
                app.alert(.key("Error"), message: .key("Error.email"))
            }
        case 3: UIApplication.shared.open(URL(string: "https://twitter.com/holboxapp")!)
        case 4: UIApplication.shared.open(URL(string: "itms-apps://itunes.apple.com/\(Locale.current.regionCode!.lowercased())/app/holbox/id1484470903")!)
        default: break
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak item] in
            item?.selected = false
        }
    }
}
