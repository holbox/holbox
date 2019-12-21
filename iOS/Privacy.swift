import UIKit

final class Privacy: Modal {
    override func viewDidLoad() {
        super.viewDidLoad()
        let scroll = Scroll()
        view.addSubview(scroll)
        
        let label = Label([(.key("Privacy.title") + "\n\n", .medium(16), .haze()),
                           (.key("Privacy.label"), .regular(14), .white)])
        scroll.add(label)
        
        scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1).isActive = true
        scroll.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        scroll.bottom.constraint(equalTo: label.bottomAnchor, constant: 40).isActive = true
        scroll.right.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        label.topAnchor.constraint(equalTo: scroll.top, constant: 70).isActive = true
        label.leftAnchor.constraint(equalTo: scroll.left, constant: 40).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: scroll.right, constant: -40).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 400).isActive = true
        
        addClose()
    }
}
