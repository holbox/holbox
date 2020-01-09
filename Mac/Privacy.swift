import AppKit

final class Privacy: Modal {
    init() {
        super.init(400, 310)
        
        let title = Label(.key("Privacy.title"), .medium(14), .haze())
        contentView!.addSubview(title)
        
        let label = Label(.key("Privacy.label"), .regular(14), .white)
        contentView!.addSubview(label)
        
        title.centerYAnchor.constraint(equalTo: contentView!.topAnchor, constant: 24).isActive = true
        title.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 40).isActive = true
        
        label.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 60).isActive = true
        label.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 25).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: contentView!.rightAnchor, constant: -25).isActive = true
    }
}
