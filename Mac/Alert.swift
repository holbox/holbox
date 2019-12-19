import AppKit

final class Alert: Modal {
    init(_ title: String, message: String) {
        super.init(400, 80)
        setFrameOrigin(.init(x: NSScreen.main!.frame.midX - 200, y: NSScreen.main!.frame.maxY - 150))
        
        let label = Label([(title + "\n", .bold(16), .white), (message, .regular(14), .white)])
        contentView!.addSubview(label)
        
        label.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 35).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: contentView!.rightAnchor, constant: -35).isActive = true
        label.centerYAnchor.constraint(equalTo: contentView!.centerYAnchor).isActive = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in self?.close() }
    }
    
    override func mouseDown(with: NSEvent) {
        close()
    }
}
