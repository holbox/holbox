import AppKit

final class Privacy: Modal {
    init() {
        super.init(500, 400)
        let label = Label([(.key("Privacy.title") + "\n\n", .bold(16), .haze()),
                           (.key("Privacy.label"), .regular(14), .white)])
        contentView!.addSubview(label)
        
        label.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 50).isActive = true
        label.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 50).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: contentView!.rightAnchor, constant: -50).isActive = true
        
        addClose()
    }
}
