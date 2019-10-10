import AppKit

final class Detail: NSView {
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let image = Image("detail.\(main.mode.rawValue)")
        addSubview(image)
        
        image.widthAnchor.constraint(equalToConstant: 300).isActive = true
        image.heightAnchor.constraint(equalToConstant: 200).isActive = true
        image.topAnchor.constraint(equalTo: topAnchor, constant: 100).isActive = true
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
}
