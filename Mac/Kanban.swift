import AppKit

final class Kanban: NSView, NSTextViewDelegate {
    private weak var drag: Card?
    private weak var scroll: Scroll!
    private weak var name: Text!
    override var mouseDownCanMoveWindow: Bool { drag == nil }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        
        let scroll = Scroll()
        addSubview(scroll)
        self.scroll = scroll
        
        let border = Border()
        scroll.add(border)
        
        var left: NSLayoutXAxisAnchor?
        (0 ..< app.session.lists(app.project)).forEach { list in
            let column = Column(list)
            scroll.add(column)
            
            var top: Card?
            (0 ..< app.session.cards(app.project, list: list)).forEach {
                let card = Card($0, column: list)
                scroll.add(card)
                
                if top == nil {
                    card.top = card.topAnchor.constraint(equalTo: column.bottomAnchor, constant: 40)
                } else {
                    card.top = card.topAnchor.constraint(equalTo: top!.bottomAnchor, constant: 20)
                    top!.child = card
                }
                
                scroll.bottom.constraint(greaterThanOrEqualTo: card.bottomAnchor, constant: 80).isActive = true
                card.right = column.rightAnchor.constraint(greaterThanOrEqualTo: card.rightAnchor)
                card.left = card.leftAnchor.constraint(equalTo: column.leftAnchor, constant: 60)
                top = card
            }
            
            if left == nil {
                column.leftAnchor.constraint(equalTo: scroll.left).isActive = true
            } else {
                column.leftAnchor.constraint(equalTo: left!).isActive = true
            }
            
            column.topAnchor.constraint(equalTo: scroll.top, constant: 120).isActive = true
            scroll.bottom.constraint(greaterThanOrEqualTo: column.bottomAnchor, constant: 70).isActive = true
            left = column.rightAnchor
        }
        
        if left != nil {
            scroll.right.constraint(greaterThanOrEqualTo: left!, constant: 70).isActive = true
        }
        
        let name = Text()
        name.setAccessibilityLabel(.key("Kanban.project"))
        name.font = .systemFont(ofSize: 30, weight: .bold)
        name.string = app.session.name(app.project)
        name.textContainer!.size.width = 500
        name.textContainer!.size.height = 55
        scroll.add(name)
        self.name = name
        
        let _card = Button("card", target: self, action: #selector(card))
        let _more = Button("more", target: self, action: #selector(more))
        
        [_card, _more].forEach {
            scroll.add($0)
            $0.widthAnchor.constraint(equalToConstant: 40).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
            $0.centerYAnchor.constraint(equalTo: name.centerYAnchor, constant: 2).isActive = true
        }

        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        scroll.right.constraint(greaterThanOrEqualTo: _more.rightAnchor, constant: 40).isActive = true
        scroll.bottom.constraint(greaterThanOrEqualTo: name.bottomAnchor, constant: 60).isActive = true
        
        _card.leftAnchor.constraint(equalTo: name.rightAnchor, constant: 20).isActive = true
        _more.leftAnchor.constraint(equalTo: _card.rightAnchor).isActive = true
        
        border.leftAnchor.constraint(equalTo: scroll.left).isActive = true
        border.rightAnchor.constraint(equalTo: scroll.right).isActive = true
        border.topAnchor.constraint(equalTo: scroll.top, constant: 180).isActive = true
        
        name.topAnchor.constraint(equalTo: scroll.top, constant: 30).isActive = true
        name.leftAnchor.constraint(equalTo: scroll.left, constant: 70).isActive = true
        name.didChangeText()
        name.delegate = self
    }
    
    func textDidEndEditing(_: Notification) {
        app.session.name(app.project, name: name.string)
    }
    
    override func mouseDown(with: NSEvent) {
        super.mouseDown(with: with)
        window!.makeFirstResponder(nil)
    }
    
    override func mouseDragged(with: NSEvent) {
        super.mouseDragged(with: with)
        if let drag = self.drag {
            drag.drag(with.deltaX, with.deltaY)
        } else if let view = hitTest(with.locationInWindow) {
            drag = view as? Card ?? view.superview as? Card ?? view.superview?.superview as? Card
        }
    }
    
    override func mouseUp(with: NSEvent) {
        super.mouseUp(with: with)
        drag?.stop(with.locationInWindow.x + scroll.documentVisibleRect.origin.x, scroll.documentVisibleRect.height - with.locationInWindow.y + scroll.documentVisibleRect.origin.y)
        drag = nil
    }
    
    @objc private func card() {
        app.session.add(app.project, list: 0)
        app.main.project(app.project)
        (app.main.base!.subviews.first as! Kanban).scroll.views.compactMap { $0 as? Card }.first { $0.index == 0 && $0.column == 0 }!.edit()
    }
    
    @objc private func more() {
        app.runModal(for: More.Project())
    }
}
