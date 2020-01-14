import UIKit
import MessageUI

final class Settings: Modal, MFMailComposeViewControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        addClose()
        
        let border = Border.horizontal(1)
        view.addSubview(border)
        
        let scroll = Scroll()
        view.addSubview(scroll)
        
        let logo = Image("logo")
        view.addSubview(logo)
        
        let title = Label([(.key("About.title") + "\n", .medium(16), .white),
                           (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String, .light(16), .white)])
        view.addSubview(title)
        
        let _spell = Option.Check(.key("Settings.spell"), settings: self)
        _spell.on = app.session.spell
        scroll.add(_spell)
        
        var top = _spell.bottomAnchor
        (0 ..< 5).forEach {
            let item = Option.Item($0, settings: self)
            scroll.add(item)
            
            let border = Border.horizontal(0.2)
            scroll.add(border)
            
            item.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
            item.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
            
            border.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
            border.widthAnchor.constraint(equalToConstant: 320).isActive = true
            border.topAnchor.constraint(equalTo: top).isActive = true
            top = item.bottomAnchor
        }
        
        scroll.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        scroll.right.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        scroll.bottom.constraint(equalTo: top, constant: 30).isActive = true
        
        border.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 50).isActive = true
        border.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        logo.widthAnchor.constraint(equalToConstant: 60).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 60).isActive = true
        logo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60).isActive = true
        logo.rightAnchor.constraint(equalTo: view.centerXAnchor, constant: 5).isActive = true
        
        title.centerYAnchor.constraint(equalTo: logo.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: logo.rightAnchor, constant: 10).isActive = true
        
        _spell.topAnchor.constraint(equalTo: scroll.top, constant: 10).isActive = true
        _spell.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
    }
    
    func mailComposeController(_: MFMailComposeViewController, didFinishWith: MFMailComposeResult, error: Error?) {
        dismiss(animated: true)
    }
    
    func option(_ index: Int) {
        switch index {
        case 0:
            present(Privacy(), animated: true)
        case 1:
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
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
        case 3:
            UIApplication.shared.open(URL(string: "https://twitter.com/holboxapp")!)
        case 4:
            UIApplication.shared.open(URL(string: "itms-apps://itunes.apple.com/\(Locale.current.regionCode!.lowercased())/app/holbox/id1484470903")!)
        default: break
        }
    }
    
    @objc func check(_ check: Option.Check) {
        check.on.toggle()
        app.session.spell(check.on)
        app.main.refresh()
    }
}
