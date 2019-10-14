import holbox
import AppKit

final class Kanban: NSView, NSTextViewDelegate {
    private final class Column: NSView, NSTextViewDelegate {
        private weak var name: Text!
        private let index: Int
        
        required init?(coder: NSCoder) { nil }
        init(_ index: Int) {
            self.index = index
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            let name = Text()
            name.textColor = .white
            name.font = .monospacedSystemFont(ofSize: 20, weight: .bold)
            name.string = session.name(main.project, list: index)
            name.textContainer!.size.width = 400
            name.textContainer!.size.height = 45
            name.delegate = self
            addSubview(name)
            self.name = name
            
            addSubview(name)
            
            name.leftAnchor.constraint(equalTo: leftAnchor, constant: 60).isActive = true
            name.topAnchor.constraint(equalTo: topAnchor, constant: 90).isActive = true
            name.heightAnchor.constraint(equalToConstant: 45).isActive = true
            
            rightAnchor.constraint(greaterThanOrEqualTo: name.rightAnchor, constant: 60).isActive = true
            bottomAnchor.constraint(greaterThanOrEqualTo: name.bottomAnchor, constant: 40).isActive = true
            
            name.didChangeText()
        }
        
        func textDidEndEditing(_: Notification) {
            session.name(main.project, list: index, name: name.string)
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
                name.edit = true
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
    private weak var name: Text!
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let name = Text()
        name.textColor = .white
        name.font = .systemFont(ofSize: 30, weight: .bold)
        name.string = session.name(main.project)
        name.textContainer!.size.width = 500
        name.textContainer!.size.height = 55
        name.delegate = self
        self.name = name
        
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
            scroll.documentView!.rightAnchor.constraint(greaterThanOrEqualTo: column.rightAnchor, constant: 40).isActive = true
            scroll.documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: column.bottomAnchor, constant: 40).isActive = true
            left = column.rightAnchor
        }
        
        scroll.documentView!.addSubview(name)

        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        scroll.documentView!.rightAnchor.constraint(greaterThanOrEqualTo: name.rightAnchor, constant: 90).isActive = true
        scroll.documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: name.bottomAnchor, constant: 60).isActive = true
        
        name.topAnchor.constraint(equalTo: scroll.documentView!.topAnchor, constant: 20).isActive = true
        name.leftAnchor.constraint(equalTo: scroll.documentView!.leftAnchor, constant: 60).isActive = true
        name.heightAnchor.constraint(equalToConstant: 55).isActive = true
        name.didChangeText()
    }
    
    func textDidEndEditing(_: Notification) {
        session.name(main.project, name: name.string)
    }
}
