import UIKit

final class Privacy: Modal {
    override func viewDidLoad() {
        super.viewDidLoad()
        let scroll = Scroll()
        view.addSubview(scroll)
        
        let label = Label([(.key("Privacy.title"), 24, .bold, .init(white: 1, alpha: 0.4)),
                           (.key("Privacy.label"), 14, .regular, .white)])
        scroll.add(label)
        
        let done = Control(.key("Privacy.done"), self, #selector(close), UIColor(named: "haze")!, .black)
        scroll.add(done)
        
        scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1).isActive = true
        scroll.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        scroll.bottom.constraint(equalTo: done.bottomAnchor, constant: 30).isActive = true
        scroll.right.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        label.topAnchor.constraint(equalTo: scroll.top, constant: 50).isActive = true
        label.leftAnchor.constraint(equalTo: scroll.left, constant: 40).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: scroll.right, constant: -40).isActive = true
        label.widthAnchor.constraint(lessThanOrEqualToConstant: 400).isActive = true
        
        done.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20).isActive = true
        done.centerXAnchor.constraint(equalTo: scroll.centerX).isActive = true
        done.widthAnchor.constraint(equalToConstant: 140).isActive = true
    }
}
