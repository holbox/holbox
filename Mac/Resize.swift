import AppKit

protocol Resize {
    func configure(_ text: Text)
    func update(_ text: Text)
}

final class Bothways: Resize {
    private let width: CGFloat
    private let height: CGFloat
    
    init(_ width: CGFloat, _ height: CGFloat) {
        self.width = width
        self.height = height
    }
    
    func configure(_ text: Text) {
        text.textContainer!.size.width = 300
        text.textContainer!.size.height = 6000
    }
    
    func update(_ text: Text) {
        text.layoutManager!.ensureLayout(for: text.textContainer!)
        text.width.constant = max(text.layoutManager!.usedRect(for: text.textContainer!).size.width + 20, 60)
        text.height.constant = text.layoutManager!.usedRect(for: text.textContainer!).size.height + 20
    }
}

final class Vertically: Resize {
    func configure(_ text: Text) {
        
    }
    
    func update(_ text: Text) {
        
    }
}
