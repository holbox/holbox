import AppKit

final class Privacy: Modal {
    init() {
        super.init(500, 480)
        let label = Label([(.key("Privacy.title") + "\n\n", 24, .bold, NSColor(named: "haze")!),
                           (.key("Privacy.label"), 14, .regular, .white)])
        contentView!.addSubview(label)
        
        let done = Control(.key("Privacy.done"), self, #selector(close), .clear, NSColor(named: "haze")!)
        contentView!.addSubview(done)
        
        label.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 50).isActive = true
        label.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 50).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: contentView!.rightAnchor, constant: -50).isActive = true
        
        done.widthAnchor.constraint(equalToConstant: 140).isActive = true
        done.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -40).isActive = true
        done.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
    }
}
