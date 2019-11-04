import AppKit

class Resize {
    final class Both: Resize {
        private let lines: Int
        private let width: CGFloat
        private let height: CGFloat
        
        init(_ width: CGFloat, _ height: CGFloat, lines: Int) {
            self.width = width
            self.height = height
            self.lines = lines
            super.init()
        }
        
        override func configure(_ text: Text) {
            w = text.widthAnchor.constraint(equalToConstant: 0)
            text.textContainer!.size.width = width
            text.textContainer!.size.height = height
            text.textContainer!.maximumNumberOfLines = lines
            super.configure(text)
        }
        
        override func update(_ text: Text) {
            super.update(text)
            layout(text)
        }
        
        override func layout(_ text: Text) {
            super.layout(text)
            w.constant = max(text.layoutManager!.usedRect(for: text.textContainer!).size.width + 20, 60)
        }
    }
    
    final class Vertical: Resize {
        private let width: CGFloat
        
        init(_ width: CGFloat) {
            self.width = width
            super.init()
        }
        
        override func configure(_ text: Text) {
            w = text.widthAnchor.constraint(lessThanOrEqualToConstant: 0)
            text.textContainer!.size.height = 10000
            super.configure(text)
        }
        
        override func update(_ text: Text) {
            super.update(text)
            layout(text)
        }
        
        override func layout(_ text: Text) {
            text.textContainer!.size.width = max(min(width, text.superview!.frame.width) - 20, 60)
            w.constant = max(text.layoutManager!.usedRect(for: text.textContainer!).size.width + 20, 60)
            print(w.constant)
            super.layout(text)
        }
    }
    
    private weak var w: NSLayoutConstraint!
    private weak var h: NSLayoutConstraint!
    
    private init() { }
    
    func configure(_ text: Text) {
        h = text.heightAnchor.constraint(equalToConstant: 0)
        h.isActive = true
        w.isActive = true
    }
    
    func update(_ text: Text) {
        text.layoutManager!.ensureLayout(for: text.textContainer!)
    }
    
    func layout(_ text: Text) {
        h.constant = text.layoutManager!.usedRect(for: text.textContainer!).size.height + 20
    }
}
