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
            name.font = .monospacedSystemFont(ofSize: 20, weight: .bold)
            name.string = session.name(main.project, list: index)
            name.textContainer!.size.width = 400
            name.textContainer!.size.height = 45
            addSubview(name)
            self.name = name
            
            addSubview(name)
            
            var top: NSLayoutYAxisAnchor?
            (0 ..< session.cards(main.project, list: index)).forEach {
                let card = Card($0, column: index)
                addSubview(card)
                
                if top == nil {
                    card.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 40).isActive = true
                } else {
                    card.topAnchor.constraint(equalTo: top!, constant: 20).isActive = true
                }
                
                card.leftAnchor.constraint(equalTo: leftAnchor, constant: 80).isActive = true
                rightAnchor.constraint(greaterThanOrEqualTo: card.rightAnchor, constant: 80).isActive = true
                bottomAnchor.constraint(greaterThanOrEqualTo: card.bottomAnchor, constant: 20).isActive = true
                top = card.bottomAnchor
            }
            
            rightAnchor.constraint(greaterThanOrEqualTo: name.rightAnchor, constant: 70).isActive = true
            bottomAnchor.constraint(greaterThanOrEqualTo: name.bottomAnchor, constant: 50).isActive = true
            name.leftAnchor.constraint(equalTo: leftAnchor, constant: 70).isActive = true
            name.topAnchor.constraint(equalTo: topAnchor, constant: 120).isActive = true
            name.didChangeText()
            name.delegate = self
        }
        
        func textDidEndEditing(_: Notification) {
            session.name(main.project, list: index, name: name.string)
        }
    }
    
    private final class Card: NSView, NSTextViewDelegate {
        private weak var content: Text!
        private let index: Int
        private let column: Int
        
        required init?(coder: NSCoder) { nil }
        init(_ index: Int, column: Int) {
            self.index = index
            self.column = column
            super.init(frame: .zero)
            self.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            translatesAutoresizingMaskIntoConstraints = false
            wantsLayer = true
            layer!.cornerRadius = 8
            layer!.borderWidth = 1
            layer!.borderColor = .black
            
            let content = Text()
            content.font = .monospacedSystemFont(ofSize: 16, weight: .regular)
            content.string = session.content(main.project, list: column, card: index)
            content.tab = true
            content.intro = true
            content.standby = 0.8
            content.textContainer!.size.width = 360
            content.textContainer!.size.height = 5000
            addSubview(content)
            self.content = content
            
            addSubview(content)
            
            rightAnchor.constraint(equalTo: content.rightAnchor, constant: 10).isActive = true
            bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: 10).isActive = true
            content.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
            content.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
            content.didChangeText()
            content.delegate = self
        }
        
        func textDidChange(_: Notification) {
            session.content(main.project, list: column, card: index, content: content.string)
        }
        
        func textDidBeginEditing(_: Notification) {
            layer!.borderColor = .haze
            layer!.borderWidth = 2
        }
        
        func textDidEndEditing(_: Notification) {
            layer!.borderColor = .black
            layer!.borderWidth = 1
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
        
        let border = NSView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.wantsLayer = true
        border.layer!.backgroundColor = .black
        scroll.documentView!.addSubview(border)
        
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
            scroll.documentView!.rightAnchor.constraint(greaterThanOrEqualTo: column.rightAnchor, constant: 50).isActive = true
            scroll.documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: column.bottomAnchor, constant: 50).isActive = true
            left = column.rightAnchor
        }
        
        let name = Text()
        name.font = .systemFont(ofSize: 30, weight: .bold)
        name.string = session.name(main.project)
        name.textContainer!.size.width = 500
        name.textContainer!.size.height = 55
        scroll.documentView!.addSubview(name)
        self.name = name
        
        let _card = Button("card", target: self, action: #selector(card))
        
        let _more = Button("more", target: self, action: #selector(more))
        
        [_card, _more].forEach {
            scroll.documentView!.addSubview($0)
            $0.widthAnchor.constraint(equalToConstant: 40).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
            $0.centerYAnchor.constraint(equalTo: name.centerYAnchor, constant: 4).isActive = true
        }

        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        scroll.documentView!.rightAnchor.constraint(greaterThanOrEqualTo: name.rightAnchor, constant: 90).isActive = true
        scroll.documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: name.bottomAnchor, constant: 60).isActive = true
        
        _card.leftAnchor.constraint(equalTo: name.rightAnchor).isActive = true
        _more.leftAnchor.constraint(equalTo: _card.rightAnchor).isActive = true
        
        border.leftAnchor.constraint(equalTo: scroll.documentView!.leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: scroll.documentView!.rightAnchor).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.topAnchor.constraint(equalTo: scroll.documentView!.topAnchor, constant: 180).isActive = true
        
        name.topAnchor.constraint(equalTo: scroll.documentView!.topAnchor, constant: 30).isActive = true
        name.leftAnchor.constraint(equalTo: scroll.documentView!.leftAnchor, constant: 70).isActive = true
        name.didChangeText()
        name.delegate = self
    }
    
    func textDidEndEditing(_: Notification) {
        session.name(main.project, name: name.string)
    }
    
    @objc private func card() {
        session.add(main.project, list: 0)
        main.project(main.project)
    }
    
    @objc private func more() {
        app.runModal(for: More())
    }
}
