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
        title.font = .systemFont(ofSize: 20, weight: .bold)
        title.textColor = .white
        addSubview(title)
        
        let border = NSView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.wantsLayer = true
        border.layer!.backgroundColor = .black
        addSubview(border)
        
        let scroll = Scroll()
        addSubview(scroll)
        
        if session.projects(main.mode).isEmpty {
            let empty = Label(.key("Detail.empty.\(main.mode.rawValue)"))
            empty.font = .systemFont(ofSize: 14, weight: .light)
            empty.textColor = .init(white: 1, alpha: 0.4)
            addSubview(empty)
            
            empty.topAnchor.constraint(equalTo: border.bottomAnchor, constant: 20).isActive = true
            empty.leftAnchor.constraint(equalTo: leftAnchor, constant: 40).isActive = true
        }
        
        image.widthAnchor.constraint(equalToConstant: 300).isActive = true
        image.heightAnchor.constraint(equalToConstant: 200).isActive = true
        image.topAnchor.constraint(equalTo: topAnchor, constant: 50).isActive = true
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        title.leftAnchor.constraint(equalTo: leftAnchor, constant: 40).isActive = true
        title.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 40).isActive = true
        
        border.leftAnchor.constraint(equalTo: leftAnchor, constant: 40).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor, constant: -40).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10).isActive = true
        
        scroll.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
    }
}
