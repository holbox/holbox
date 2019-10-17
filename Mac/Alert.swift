import AppKit

final class Alert: Modal {
    init(_ title: String, message: String) {
        super.init(500, 70)
        setFrameOrigin(.init(x: NSScreen.main!.frame.midX - 250, y: NSScreen.main!.frame.maxY - 120))
        
        let ribbon = NSView()
        ribbon.translatesAutoresizingMaskIntoConstraints = false
        ribbon.wantsLayer = true
        ribbon.layer!.backgroundColor = .haze
        contentView!.addSubview(ribbon)
        
        let label = Label()
        label.attributedStringValue = {
            $0.append(.init(string: title + "\n", attributes: [.font: NSFont.systemFont(ofSize: 16, weight: .bold), .foregroundColor: NSColor.white]))
            $0.append(.init(string: message, attributes: [.font: NSFont.systemFont(ofSize: 14, weight: .light), .foregroundColor: NSColor(white: 1, alpha: 0.8)]))
            return $0
        } (NSMutableAttributedString())
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        contentView!.addSubview(label)
        
        ribbon.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        ribbon.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        ribbon.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        ribbon.widthAnchor.constraint(equalToConstant: 25).isActive = true
        
        label.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 35).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: contentView!.rightAnchor, constant: -25).isActive = true
        label.centerYAnchor.constraint(equalTo: contentView!.centerYAnchor).isActive = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in self?.close() }
    }
    
    override func mouseDown(with: NSEvent) {
        close()
        super.mouseDown(with: with)
    }
}
