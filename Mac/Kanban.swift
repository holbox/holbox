import AppKit

final class Kanban: NSView, NSTextViewDelegate {
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
        (0 ..< app.session.lists(app.project)).forEach {
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
        name.string = app.session.name(app.project)
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
            $0.centerYAnchor.constraint(equalTo: name.centerYAnchor, constant: 2).isActive = true
        }

        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        scroll.documentView!.rightAnchor.constraint(greaterThanOrEqualTo: name.rightAnchor, constant: 90).isActive = true
        scroll.documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: name.bottomAnchor, constant: 60).isActive = true
        
        _card.leftAnchor.constraint(equalTo: name.rightAnchor, constant: 20).isActive = true
        _more.leftAnchor.constraint(equalTo: _card.rightAnchor, constant: 20).isActive = true
        
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
        app.session.name(app.project, name: name.string)
    }
    
    override func mouseDown(with: NSEvent) {
        window!.makeFirstResponder(nil)
    }
    
    @objc private func card() {
        app.session.add(app.project, list: 0)
        app.main.project(app.project)
        (app.main.base!.subviews.first as! Kanban).scroll.documentView!.subviews
        .compactMap { $0 as? Column }.first { $0.index == 0 }!.subviews
        .compactMap { $0 as? Card }.first { $0.index == 0 }!.edit()
    }
    
    @objc private func more() {
        app.runModal(for: More())
    }
}
