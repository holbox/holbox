import AppKit

protocol Resize {
    func configure(_ text: Text)
    func update(_ text: Text)
}

final class Bothways: Resize {
    private weak var w: NSLayoutConstraint!
    private weak var h: NSLayoutConstraint!
    private let lines: Int
    private let width: CGFloat
    private let height: CGFloat
    
    init(_ width: CGFloat, _ height: CGFloat, lines: Int) {
        self.width = width
        self.height = height
        self.lines = lines
    }
    
    func configure(_ text: Text) {
        text.textContainer!.size.width = width
        text.textContainer!.size.height = height
        text.textContainer!.maximumNumberOfLines = lines
        w = text.widthAnchor.constraint(equalToConstant: 0)
        h = text.heightAnchor.constraint(equalToConstant: 0)
        h.isActive = true
        w.isActive = true
    }
    
    func update(_ text: Text) {
        text.layoutManager!.ensureLayout(for: text.textContainer!)
        w.constant = max(text.layoutManager!.usedRect(for: text.textContainer!).size.width + 20, 60)
        h.constant = text.layoutManager!.usedRect(for: text.textContainer!).size.height + 20
    }
}

final class Vertically: Resize {
    private weak var h: NSLayoutConstraint!
    private let width: CGFloat
    
    init(_ width: CGFloat) {
        self.width = width
    }
    
    func configure(_ text: Text) {
        text.textContainer!.size.height = 10000
        h = text.heightAnchor.constraint(equalToConstant: 0)
        h.isActive = true
    }
    
    func update(_ text: Text) {
        text.textContainer!.size.width = max(min(text.superview!.frame.width - 20, width), 60)
        text.layoutManager!.ensureLayout(for: text.textContainer!)
        h.constant = text.layoutManager!.usedRect(for: text.textContainer!).size.height + 20
    }
}
