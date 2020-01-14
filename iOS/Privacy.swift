import UIKit

final class Privacy: Modal {
    override func viewDidLoad() {
        super.viewDidLoad()
        addClose()
        
        let scroll = Scroll()
        view.addSubview(scroll)
        
        let title = Label(.key("Privacy.title"), .bold(16), .haze())
        view.addSubview(title)
        
        let label = Label(.key("Privacy.label"), .regular(16), .white)
        scroll.add(label)
        
        let border = Border.horizontal(1)
        view.addSubview(border)
        
        scroll.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        scroll.bottom.constraint(equalTo: label.bottomAnchor, constant: 40).isActive = true
        scroll.right.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        title.centerYAnchor.constraint(equalTo: _close.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: _close.rightAnchor).isActive = true
        
        border.topAnchor.constraint(equalTo: _close.bottomAnchor).isActive = true
        border.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        label.topAnchor.constraint(equalTo: scroll.top, constant: 20).isActive = true
        label.leftAnchor.constraint(equalTo: scroll.left, constant: 20).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: scroll.right, constant: -20).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 400).isActive = true
    }
}
