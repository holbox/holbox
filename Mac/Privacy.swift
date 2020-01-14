import AppKit

final class Privacy: Modal {
    init() {
        super.init(400, 360)
        
        let title = Label(.key("Privacy.title"), .bold(16), .haze())
        contentView!.addSubview(title)
        
        let label = Label(.key("Privacy.label"), .regular(16), .white)
        contentView!.addSubview(label)
        
        let border = Border.horizontal(1)
        contentView!.addSubview(border)
        
        title.centerYAnchor.constraint(equalTo: contentView!.topAnchor, constant: 24).isActive = true
        title.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 80).isActive = true
        
        label.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 20).isActive = true
        label.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 25).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: contentView!.rightAnchor, constant: -25).isActive = true
        
        border.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20).isActive = true
        border.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 1).isActive = true
        border.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -1).isActive = true
    }
}
