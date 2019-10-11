import AppKit

final class Detail: NSView {
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        
        let image = Image("detail.\(main.mode.rawValue)")
        addSubview(image)
        
        let title = Label(.key("Detail.title.\(main.mode.rawValue)"))
        title.font = .systemFont(ofSize: 25, weight: .bold)
        title.textColor = .white
        addSubview(title)
        
        image.widthAnchor.constraint(equalToConstant: 300).isActive = true
        image.heightAnchor.constraint(equalToConstant: 200).isActive = true
        image.topAnchor.constraint(equalTo: topAnchor, constant: 50).isActive = true
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        title.leftAnchor.constraint(equalTo: leftAnchor, constant: 40).isActive = true
        title.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 40).isActive = true
    }
}
