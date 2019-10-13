import holbox
import AppKit

final class Kanban: NSView {
    private final class Column: NSView, NSTextViewDelegate {
        private weak var name: Text!
        private weak var width: NSLayoutConstraint!
        private let index: Int
        
        required init?(coder: NSCoder) { nil }
        init(_ index: Int) {
            self.index = index
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            let name = Text()
            name.textColor = .init(white: 1, alpha: 0.5)
            name.font = .systemFont(ofSize: 16, weight: .bold)
            name.textContainer!.lineBreakMode = .byTruncatingTail
            name.string = session.name(main.project, list: index)
            name.textContainer!.size.width = 240
            name.textContainer!.size.height = 40
            name.delegate = self
            name.accepts = true
            addSubview(name)
            self.name = name
            
            addSubview(name)
            
            name.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
            name.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
            name.heightAnchor.constraint(equalToConstant: 40).isActive = true
            width = name.widthAnchor.constraint(equalToConstant: 0)
            width.isActive = true
            
            rightAnchor.constraint(greaterThanOrEqualTo: name.rightAnchor, constant: 30).isActive = true
            bottomAnchor.constraint(greaterThanOrEqualTo: name.bottomAnchor, constant: 30).isActive = true
            
            name.layoutManager!.ensureLayout(for: name.textContainer!)
            update()
        }
        
        func textDidChange(_: Notification) {
            update()
        }
        
        private func update() {
            width.constant = name.layoutManager!.usedRect(for: name.textContainer!).size.width + 20
        }
    }
    
    private final class Card: NSView, NSTextViewDelegate {
            private weak var name: Text!
            private weak var width: NSLayoutConstraint!
            private weak var height: NSLayoutConstraint!
            private let index: Int
            
            required init?(coder: NSCoder) { nil }
            init(_ index: Int) {
                self.index = index
                super.init(frame: .zero)
                translatesAutoresizingMaskIntoConstraints = false
                wantsLayer = true
                layer!.backgroundColor = .black
                
                let name = Text()
                name.string = session.name(main.project, list: index)
    //            name.textContainer!.widthTracksTextView = true
                name.isHorizontallyResizable = true
                name.textContainer!.size.width = 200
    //            name.isVerticallyResizable = true
    //            name.textContainer!.widthTracksTextView = true
    //            name.textContainer!.heightTracksTextView = true
                name.delegate = self
                name.accepts = true
                addSubview(name)
                self.name = name
                
                addSubview(name)
                
                name.leftAnchor.constraint(equalTo: leftAnchor, constant: 40).isActive = true
                name.topAnchor.constraint(equalTo: topAnchor, constant: 40).isActive = true
                width = name.widthAnchor.constraint(equalToConstant: 50)
                height = name.heightAnchor.constraint(equalToConstant: 50)
                width.isActive = true
                height.isActive = true
                
                rightAnchor.constraint(greaterThanOrEqualTo: name.rightAnchor, constant: 40).isActive = true
                bottomAnchor.constraint(greaterThanOrEqualTo: name.bottomAnchor, constant: 40).isActive = true
            }
            
            func textDidChange(_: Notification) {
    //            name.textContainer!.size.width = 200//min(name.frame.width - 20, 200)
    //            name.layoutManager!.ensureLayout(for: name.textContainer!)
                width.constant = max(name.layoutManager!.usedRect(for: name.textContainer!).size.width + 20, 50)
                height.constant = max(name.layoutManager!.usedRect(for: name.textContainer!).size.height + 20, 50)
            }
        }
    
    private weak var scroll: Scroll!
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        var left: NSLayoutXAxisAnchor?
        (0 ..< session.lists(main.project)).forEach {
            let column = Column($0)
            scroll.documentView!.addSubview(column)
            
            if left == nil {
                column.leftAnchor.constraint(equalTo: scroll.documentView!.leftAnchor).isActive = true
            } else {
                column.leftAnchor.constraint(equalTo: left!).isActive = true
            }
            
            column.topAnchor.constraint(equalTo: scroll.documentView!.topAnchor).isActive = true
            scroll.documentView!.rightAnchor.constraint(greaterThanOrEqualTo: column.rightAnchor).isActive = true
            scroll.documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: column.bottomAnchor).isActive = true
            left = column.rightAnchor
        }
        
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
    }
}
