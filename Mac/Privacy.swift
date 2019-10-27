import AppKit

final class Privacy: Window.Modal {
    init() {
        super.init(600, 560)
        let label = Label([(.key("Privacy.title"), 24, .bold, .init(white: 1, alpha: 0.4)),
                           (.key("Privacy.label"), 14, .regular, .white)])
        contentView!.addSubview(label)
        
        let done = Control(.key("Privacy.done"), self, #selector(close), NSColor(named: "haze")!.cgColor, .black)
        contentView!.addSubview(done)
        
        label.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 60).isActive = true
        label.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 70).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: contentView!.rightAnchor, constant: -70).isActive = true
        
        done.widthAnchor.constraint(equalToConstant: 140).isActive = true
        done.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -50).isActive = true
        done.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
    }
}
